---
title: Widget de Icebreaker com IA no Chat
prd: documentation/features/profiling/icebreaker/prd.md
status: concluido
last_updated_at: 2026-03-12
---

# 1. Objetivo

Concluir o fluxo de `icebreaker` no estado vazio do `chat` para gerar uma primeira mensagem personalizada via `ProfilingService.generateIcebreaker`, preencher o `draft` do `ChatInputBar` para revisao manual e manter o envio real apenas quando o owner tocar em enviar. A solucao final centraliza o estado no `ChatScreenPresenter`, reutiliza apenas `senderId` e `recipientId` para a chamada HTTP e substitui o comportamento anterior dos chips estaticos, que enviavam a mensagem automaticamente, por preenchimento manual do campo. O CTA de `icebreaker` permanece disponivel enquanto o `chat` nao tiver nenhuma mensagem enviada de nenhum lado.

# 2. Escopo

## 2.1 In-scope

- Exibir o botao `Gerar mensagem quebra-gelo` apenas no estado vazio do `chat`.
- Preencher o `draft` do `ChatInputBar` com a mensagem retornada pela API, sem envio automatico.
- Exibir `loading` no CTA durante a geracao e erro inline em caso de falha.
- Manter o CTA visivel enquanto `messages.isEmpty`, inclusive apos gerar sugestoes que ainda nao foram enviadas.
- Ocultar os chips estaticos apos geracao bem-sucedida do `icebreaker`.
- Alterar os chips estaticos para apenas preencher o `draft`, exigindo envio manual.
- Resolver apenas `senderId` e `recipientId` no mobile para acionar a geracao do `icebreaker`.
- Implementar a chamada `REST` de `generateIcebreaker` com retorno tipado via `IcebreakerDto`, suportando modo `draft` antes do envio.

## 2.2 Out-of-scope

- Enviar a mensagem de `icebreaker` automaticamente via `WebSocket`.
- Exibir multiplas sugestoes geradas por IA.
- Persistir historico local das mensagens geradas e descartadas.
- Alterar fluxo de `chat` com mensagens existentes.
- Expandir cadastro/edicao de perfil do cavalo ou exigir contexto adicional alem de `senderId` e `recipientId` para a geracao.

# 3. Requisitos

## 3.1 Funcionais

- **RF-01:** exibir o CTA `Gerar mensagem quebra-gelo` somente quando `messages.isEmpty`, o `chat` estiver carregado e houver `senderId` e `recipientId` disponiveis.
- **RF-02:** obter `senderId` a partir do owner autenticado ja persistido no app (`CacheKeys.ownerId`).
- **RF-03:** obter `recipientId` a partir de `chat.recipient.id` carregado no `ChatScreenPresenter`.
- **RF-04:** ao tocar no CTA, chamar `ProfilingService.generateIcebreaker` sempre que o `chat` continuar vazio e nao houver requisicao em andamento, enviando apenas `senderId` e `recipientId`.
- **RF-05:** enquanto a geracao estiver em andamento, desabilitar o CTA e exibir indicador visual de `loading`.
- **RF-06:** em sucesso, preencher `draft` com a mensagem retornada em `IcebreakerDto`, manter o texto editavel e nao enviar nada automaticamente.
- **RF-07:** em sucesso, preencher `draft`, ocultar apenas os chips estaticos e manter o CTA visivel; o `chat` continua em estado vazio ate o owner enviar a mensagem.
- **RF-08:** em falha, exibir erro inline no estado vazio e manter o CTA disponivel para nova tentativa enquanto o `chat` continuar vazio.
- **RF-09:** os chips estaticos devem deixar de usar `sendMessage` e passar a apenas preencher o `draft` do input.
- **RF-10:** o envio da mensagem gerada ou de um chip continua acontecendo exclusivamente pelo fluxo ja existente `ChatInputBar -> ChatScreenPresenter.sendMessage -> ConversationChannel.emitMessageSentEvent`.
- **RF-11:** `chats` com pelo menos uma mensagem nunca exibem CTA nem chips de `icebreaker`.

## 3.2 Nao funcionais

- **RNF-01:** manter o fluxo em camadas `View -> Presenter -> Provider -> Service -> RestClient -> API`, sem chamadas HTTP na `View`.
- **RNF-02:** concentrar o estado da feature em `signals` dentro de `ChatScreenPresenter`, evitando `setState` para regra de negocio.
- **RNF-03:** reutilizar componentes existentes do `chat` e evitar criar uma segunda fonte de verdade para `draft`, `messages` ou contexto do `chat`.
- **RNF-04:** preservar o comportamento atual de envio manual por `WebSocket`; a geracao de `icebreaker` e apenas um prefill de texto.
- **RNF-05:** manter compatibilidade com `Inbox` e `Matches`, evitando quebrar o fluxo atual de abrir `chat` por `recipientId`.
- **RNF-06:** a visibilidade do CTA deve ser derivada do estado do `chat` (`messages.isEmpty`) e nao de estado efemero de sessao local.

# 4. O que ja existe (inventario)

> Inclua apenas itens realmente relevantes para implementar a mudanca.

## 4.1 UI (`lib/ui/`)

- **`ChatScreenPresenter`** (`lib/ui/conversation/widgets/screens/chat_screen/chat_screen_presenter.dart`) - ja concentra `draft`, `messages`, `showEmptyState` e o envio por `WebSocket`; e o ponto correto para receber o estado de `icebreaker`.
- **`ChatScreenView`** (`lib/ui/conversation/widgets/screens/chat_screen/chat_screen_view.dart`) - ja liga `ChatEmptyState`, `ChatMessagesList` e `ChatInputBar`; precisa apenas repassar novos estados e callbacks.
- **`ChatEmptyStateView`** (`lib/ui/conversation/widgets/screens/chat_screen/chat_empty_state/chat_empty_state_view.dart`) - hoje renderiza apenas titulo, copy e 3 chips estaticos; sera reutilizado para inserir CTA, `loading` e erro inline.
- **`ChatInputBarView`** (`lib/ui/conversation/widgets/screens/chat_screen/chat_input_bar/chat_input_bar_view.dart`) - ja sincroniza `TextEditingController` com `draft`; o prefill do `icebreaker` deve refletir sem nova logica local.
- **`CacheKeys`** (`lib/core/shared/constants/cache_keys.dart`) - ja expoe `ownerId`, que deve ser reutilizado como `senderId` da chamada de `icebreaker`.

## 4.2 Core (`lib/core/`)

- **`ProfilingService`** (`lib/core/profiling/interfaces/profiling_service.dart`) - ja declara `generateIcebreaker` com `senderId` e `recipientId`; agora o contrato precisa apenas retornar `IcebreakerDto` para suportar o modo `draft`.
- **`ConversationService`** (`lib/core/conversation/interfaces/conversation_service.dart`) - possui `fetchChats`, `fetchChat(recipientId)` e `fetchMessagesList`; o `ChatScreenPresenter` precisa garantir que `chat.recipient.id` esteja disponivel antes de habilitar o CTA.
- **`RecipientDto`** (`lib/core/conversation/dtos/entities/recipient_dto.dart`) - ja contem `id`, suficiente para montar a chamada do `icebreaker`.

## 4.3 REST (`lib/rest/`)

- **`ProfilingService`** (`lib/rest/services/profiling_service.dart`) - implementa `fetchOwner`, `fetchOwnerHorses`, `fetchOwnerPresence` e `generateIcebreaker` com `POST /profiling/icebreaker`.
- **`ConversationService`** (`lib/rest/services/conversation_service.dart`) - continua responsavel por `fetchChats`, `fetchChat(recipientId)` e mensagens; nao precisou de extensao para a entrega final.
- **`HorseMapper`** (`lib/rest/mappers/profiling/horse_mapper.dart`) - permaneceu inalterado, ja que a chamada final nao depende de contexto adicional de cavalo no app.
- **`ChatMapper` / `RecipientMapper`** (`lib/rest/mappers/conversation/chat_mapper.dart`, `lib/rest/mappers/conversation/recipient_mapper.dart`) - permaneceram inalterados; `chat.recipient.id` foi suficiente para habilitar a feature.

## 4.4 Drivers (`lib/drivers/`)

- **`ConversationChannel`** (`lib/websocket/channels/conversation_channel.dart`) - ja envia e recebe mensagens da thread; permanece como unico caminho de envio da mensagem final.
- **`conversationChannelProvider`** (`lib/websocket/channels.dart`) - provider reutilizado pelo `ChatScreenPresenter`; nao deve ser duplicado para a feature de `icebreaker`.

# 5. O que deve ser criado

> Liste apenas arquivos novos. Para cada arquivo, detalhe assinatura, responsabilidade, dependencias e estado quando aplicavel.

## 5.1 UI

- **Nenhum novo arquivo previsto na UI.** A implementacao deve reutilizar `chat_screen_presenter.dart`, `chat_screen_view.dart` e `chat_empty_state_view.dart`.

## 5.2 Core

- **Arquivo:** `lib/core/profiling/dtos/structures/icebreaker_dto.dart`
  - **Tipo:** `dto`
  - **Contratos/assinaturas:**
    - `final String content`
  - **Responsabilidade:** encapsular o retorno tipado da API de `icebreaker`, permitindo preencher o `draft` antes do envio manual.

## 5.3 REST

- **Arquivo:** `lib/rest/mappers/profiling/icebreaker_suggestion_mapper.dart`
  - **Service/Client:** mapper do retorno da API de `icebreaker`.
  - **Metodos:** `toDto(Json json)`.
  - **Entrada/Saida:** `Json` da rota `POST /profiling/icebreaker` -> `IcebreakerDto`.

## 5.4 Drivers

- **Nenhum novo arquivo previsto em drivers.** O envio final continua reutilizando `ConversationChannel` e `conversationChannelProvider`.

# 6. O que deve ser modificado

> Liste apenas arquivos existentes. Mudancas em arquivo novo ficam na secao 5.

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_screen_presenter.dart`
  - **Mudanca:** adicionar estado de `icebreaker` (`isGeneratingIcebreaker`, `icebreakerErrorMessage`, `hasGeneratedIcebreaker`), computeds de elegibilidade baseados em `messages.isEmpty` + disponibilidade de `senderId`/`recipientId`, e metodos como `generateIcebreaker()` e `prefillDraft(String text)`; trocar o fluxo dos chips de `sendSuggestedMessage` para preenchimento de `draft`.
  - **Justificativa:** centralizar a regra de negocio da feature e manter o envio manual como comportamento unico da thread.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_screen_view.dart`
  - **Mudanca:** repassar para `ChatEmptyState` os novos estados/callbacks do `icebreaker` e manter o `ChatInputBar` controlado pelo `draft` atualizado pelo presenter.
  - **Justificativa:** integrar a feature sem mover regra de negocio para a `View`.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_empty_state/chat_empty_state_view.dart`
  - **Mudanca:** incluir CTA abaixo dos chips, `loading` no botao, erro inline e condicao para ocultar apenas os chips apos geracao bem-sucedida; ajustar callback dos chips para apenas preencher o `draft`.
  - **Justificativa:** o estado vazio passa a ser o ponto visual principal da feature.
  - **Camada:** `ui`

- **Arquivo:** `lib/core/profiling/interfaces/profiling_service.dart`
  - **Mudanca:** manter `generateIcebreaker` baseado em `senderId` e `recipientId`, ajustando o retorno para `RestResponse<IcebreakerDto>`.
  - **Justificativa:** o servidor precisa apenas dos ids dos owners, e o mobile precisa do retorno tipado para preencher o input.
  - **Camada:** `core`

- **Arquivo:** `lib/rest/services/profiling_service.dart`
  - **Mudanca:** implementar `POST /profiling/icebreaker`, enviando apenas `senderId` e `recipientId`, mapear resposta com `IcebreakerSuggestionMapper` para `IcebreakerDto` e manter `auth header` via `Service.setAuthHeader()`.
  - **Justificativa:** materializar a integracao HTTP da feature na camada correta.
  - **Camada:** `rest`

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_screen_presenter.dart`
  - **Mudanca:** reutilizar `CacheKeys.ownerId` como `senderId` e `chat.value?.recipient.id` como `recipientId`, sem depender de novos contratos de `conversation`.
  - **Justificativa:** a API do servidor nao precisa mais de contexto adicional para gerar o `icebreaker`.
  - **Camada:** `ui`

# 7. O que deve ser removido

> Remocoes precisam ser seguras (sem quebrar fluxo, import ou contrato publico). Se houver substituicao, aponte o novo caminho.

- **Nenhum arquivo deve ser removido nesta entrega.**

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)

```text
ChatScreenView
  -> ChatScreenPresenter.init()
    -> ConversationService.fetchMessagesList(chatId, limit, cursor)

Icebreaker flow:
ChatEmptyStateView.onGenerateIcebreaker
  -> ChatScreenPresenter.generateIcebreaker()
    -> ProfilingService.generateIcebreaker(senderId, recipientId)
      -> RestClient.post('/profiling/icebreaker')
        -> API
    -> draft = response.content (`IcebreakerDto`)

Send flow:
ChatInputBar.onSend
  -> ChatScreenPresenter.sendMessage()
    -> ConversationChannel.emitMessageSentEvent(...)
      -> API/WebSocket
```

## 8.2 Layout/hierarquia visual (ASCII)

```text
ChatScreen
  |- ChatHeader
  |- Body
  |   `- ChatEmptyState
  |       |- Icon + Title + Description
   |       |- SuggestionChips
   |       |- IcebreakerButton (`Gerar mensagem quebra-gelo`)
  |       `- InlineError
  `- ChatInputBar
      |- AttachmentButton
      |- DraftTextField
      `- SendButton
```

## 8.3 Referencias internas

- `lib/ui/conversation/widgets/screens/chat_screen/chat_screen_presenter.dart` (fonte atual de estado da thread)
- `lib/ui/conversation/widgets/screens/chat_screen/chat_empty_state/chat_empty_state_view.dart` (estado vazio atual a ser evoluido)
- `lib/rest/services/profiling_service.dart` (base das integracoes `profiling`)
- `lib/core/shared/constants/cache_keys.dart` (origem do `senderId` persistido)

## 8.4 Referencias de tela (quando houver)

- **Google Stitch screen id:** nao informado.
- **Decisoes de UI extraidas:**
  - manter o estado vazio existente como base visual;
  - posicionar o CTA abaixo dos chips estaticos;
  - usar o mesmo `ChatInputBar` para revisao e envio manual;
  - nao criar modal, sheet ou etapa extra para confirmar a mensagem gerada.

# 9. Resultado final

- Implementacao concluida sem introduzir novos arquivos na UI ou em drivers, reaproveitando o fluxo atual `ChatInputBar -> ChatScreenPresenter -> ConversationChannel`.
- O contrato final consumido no mobile usa `IcebreakerDto.content`, alinhado ao mapper `IcebreakerSuggestionMapper` na camada REST.
- O CTA final exibido no estado vazio usa o texto `Gerar mensagem quebra-gelo`, com `loading`, erro inline e retry enquanto `messages.isEmpty`.
