---
title: Tela de Chat (Thread de Conversa)
prd: documentation/features/conversation/chat-screen/prd.md
status: em progresso
last_updated_at: 2026-02-22
---

# 1. Objetivo

Implementar a tela de `chat` do `equiny_mobile` com fluxo completo de thread por `chatId`: carregamento paginado do historico via `REST`, recebimento de mensagens em tempo real via `WebSocket`, envio de mensagem de texto, header com dados do participant e `last presence` (via `fetchOwnerPresence`), estados de tela (sem mensagens vs com mensagens), e input fixo no rodape com botao de anexos **desabilitado**. A implementacao deve seguir `MVP` na `UI`, `Riverpod + signals` para estado, e o fluxo arquitetural `View -> Presenter -> Provider -> Service -> RestClient -> API`.

# 2. Escopo

## 2.1 In-scope

- Substituir placeholder atual de `ChatScreen` por thread funcional baseada em `chatId`.
- Carregar dados do chat (`recipient`) via `ConversationService.fetchChat`.
- Carregar mensagens via `ConversationService.fetchMessagesList` com paginacao por cursor.
- Ordenar/renderizar mensagens por data com separadores (`HOJE`, `ONTEM`, `DD DE <MES>`).
- Registrar listener no canal `WebSocket` compartilhado da sessao autenticada.
- Receber mensagens em tempo real e atualizar lista sem recarregar tela.
- Enviar mensagem de texto via `WebSocket` (`ConversationChannel.sendMessage`).
- Header com avatar/nome do recipient e status (`Online agora` ou `Visto por ultimo ...`) usando `ProfilingService.fetchOwnerPresence`.
- Estado vazio da thread com sugestoes rapidas **estaticas** (hardcoded) para primeira mensagem.
- Input bottom bar com:
  - botao `+` visivel e **desabilitado**,
  - campo de texto,
  - botao de envio.
- Botao `Ver perfil` como **placeholder sem acao**.
- Ignorar renderizacao de `attachments` no MVP (somente texto).

## 2.2 Out-of-scope

- Upload/envio de anexos (`attachments`).
- Reacao, edicao, delecao e encaminhamento de mensagens.
- Confirmacao de entrega/leitura com duplo check em tempo real.
- Indicador de digitacao.
- Acao real para `Ver perfil`.
- Busca dentro da conversa.
- Push notifications.

# 3. Requisitos

## 3.1 Funcionais

- **RF-01:** abrir thread por `chatId` recebido em `Routes.chat`.
- **RF-02:** buscar metadados do chat via `fetchChat(chatId)`.
- **RF-03:** buscar primeira pagina de mensagens via `fetchMessagesList(chatId, limit, cursor)`.
- **RF-04:** permitir carregar mensagens mais antigas (scroll para cima) usando `nextCursor`.
- **RF-05:** exibir mensagens agrupadas por dia, com separador visual entre grupos.
- **RF-06:** registrar callback de mensagens ao entrar na tela e liberar estado local ao sair.
- **RF-07:** ao receber evento de nova mensagem no socket, inserir no fim da lista mantendo ordenacao.
- **RF-08:** enviar mensagem de texto pelo socket quando tocar em enviar.
- **RF-09:** mostrar estado "Inicie a conversa" quando nao houver mensagens.
- **RF-10:** exibir 3 chips de sugestao estatica no estado vazio, preenchendo/enviando texto ao toque.
- **RF-11:** exibir status de presenca do recipient com base em `fetchOwnerPresence(ownerId)`.
- **RF-12:** exibir botao de anexos visivel e desabilitado.

## 3.2 Nao funcionais

- **RNF-01:** respeitar arquitetura em camadas; UI nao chama `RestClient` diretamente.
- **RNF-02:** estado reativo no presenter com `signals`, DI com `Riverpod`.
- **RNF-03:** evitar duplicidade de mensagens (dedupe por `message.id` quando presente).
- **RNF-04:** scroll e renderizacao estaveis para historico longo (lazy + pagina).
- **RNF-05:** manter padrao visual de tema atual (`AppThemeColors`, `AppSpacing`, `AppRadius`).

# 4. O que ja existe (inventario)

> Inclui apenas componentes relevantes para a implementacao da thread.

## 4.1 UI (`lib/ui/`)

- **`ChatScreenView`** (`lib/ui/conversation/widgets/screens/chat_screen/chat_screen_view.dart`) - placeholder atual da rota de chat.
- **`InboxScreenPresenter`** (`lib/ui/conversation/widgets/screens/inbox_screen/inbox_screen_presenter.dart`) - referencia de padrao `signals` + `Provider.autoDispose` + navegacao.
- **`InboxChatListItemPresenter`** (`lib/ui/conversation/widgets/screens/inbox_screen/inbox_chat_list/inbox_chat_list_item/inbox_chat_list_item_presenter.dart`) - referencia de formatacao de preview/estado de item.
- **`AppThemeColors/AppSpacing/AppRadius`** (`lib/ui/shared/theme/app_theme.dart`) - tokens visuais que devem ser reutilizados.

## 4.2 Core (`lib/core/`)

- **`ConversationService`** (`lib/core/conversation/interfaces/conversation_service.dart`) - contrato de `fetchChats`, `fetchChat`, `fetchMessagesList`.
- **`ConversationChannel`** (`lib/core/conversation/interfaces/conversation_channel.dart`) - contrato para envio e recebimento de mensagens do chat (`listen(onMessageReceived:)`, `emitMessageSentEvent`).
- **`ChatDto`** (`lib/core/conversation/dtos/entities/chat_dto.dart`) - dados da conversa com `recipient`, `lastMessage`, `unreadCount`.
- **`MessageDto`** (`lib/core/conversation/dtos/entities/message_dto.dart`) - mensagem com `content`, `senderId`, `receiverId`, `sentAt`, `attachments`.
- **`RecipientDto`** (`lib/core/conversation/dtos/entities/recipient_dto.dart`) - dados do participant com `lastPresenceAt`.
- **`ProfilingService.fetchOwnerPresence`** (`lib/core/profiling/interfaces/profiling_service.dart`) - contrato para presenca do owner.
- **`OwnerPresenceDto`** (`lib/core/profiling/dtos/structures/owner_presence_dto.dart`) - estrutura de presenca (`ownerId`, `isOnline`).

## 4.3 REST (`lib/rest/`)

- **`ConversationService`** (`lib/rest/services/conversation_service.dart`) - implementa `fetchChats/fetchChat`; precisa evoluir para mensagens paginadas.
- **`ChatMapper`** (`lib/rest/mappers/conversation/chat_mapper.dart`) - mapeia chat da API para `ChatDto`.
- **`MessageMapper`** (`lib/rest/mappers/conversation/message_mapper.dart`) - mapeia mensagens e JSON de envio.
- **`RecipientMapper`** (`lib/rest/mappers/conversation/recipient_mapper.dart`) - mapeia recipient (precisa incluir `last_presence_at`).
- **`ProfilingService`** (`lib/rest/services/profiling_service.dart`) - implementacao existente, ainda sem `fetchOwnerPresence`.
- **`RestClient`/`DioRestClient`** (`lib/core/shared/interfaces/rest_client.dart`, `lib/rest/dio/dio_rest_client.dart`) - base para chamadas HTTP.

## 4.4 Drivers (`lib/drivers/`)

- **`DotEnvDriver`** (`lib/drivers/env-driver/dto-env/dot_env_driver.dart`) - leitura de `EQUINY_SERVICE_URL`.
- **`GoRouterNavigationDriver`** (`lib/drivers/navigation-driver/go-router/go_router_navigation_driver.dart`) - navegacao de ida/volta.
- **`SharedPreferencesCacheDriver`** (`lib/drivers/cache-driver/shared-prefences/shared_preferences_cache_driver.dart`) - token para auth no `Service` base.

# 5. O que deve ser criado

> Lista somente de arquivos novos necessarios para entregar a thread de chat.

## 5.1 UI

### 5.1.1 Presenters/Stores

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_screen_presenter.dart`
  - **Responsabilidade:** orquestrar ciclo da tela, paginacao, socket, envio de mensagem, estado de presenca e estados visuais.
  - **Dependencias:** `ConversationService`, `ConversationChannel`, `ProfilingService`, `NavigationDriver`, `CacheDriver`.
  - **Estado (`signals`/providers):**
    - `Signal<ChatDto?> chat`
    - `Signal<List<MessageDto>> messages`
    - `Signal<bool> isLoadingInitial`
    - `Signal<bool> isLoadingMore`
    - `Signal<bool> isSending`
    - `Signal<bool> isSocketConnected`
    - `Signal<String> draft`
    - `Signal<String?> nextCursor`
    - `Signal<String?> errorMessage`
    - `Signal<bool> isRecipientOnline`
  - **Computeds:**
    - `hasMessages`
    - `showEmptyState`
    - `canLoadMore`
    - `canSend`
    - `groupedMessages` (lista de secoes por data para render)
    - `headerSubtitle` (`Online agora` ou `Visto por ultimo ...`)
  - **Metodos:**
    - `init(String chatId)`
    - `loadChat()`
    - `loadInitialMessages()`
    - `loadMoreMessages()`
    - `connectSocket()` / `disconnectSocket()`
    - `onDraftChanged(String value)`
    - `sendMessage({String? content})`
    - `sendSuggestedMessage(String content)`
    - `refreshPresence()`
    - `onBack()`

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_messages_list/date_separator/date_separator_presenter.dart`
  - **Responsabilidade:** regras de apresentacao do separador de data (label uppercase, fallback por data).
  - **Dependencias:** nenhuma externa.
  - **Estado (`signals`/providers):** nao obrigatorio.
  - **Computeds:** nao aplicavel.
  - **Metodos:** `formatLabel(DateTime date)`, `isToday`, `isYesterday`.

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_bubble_presenter.dart`
  - **Responsabilidade:** regras de apresentacao da bolha (lado, cor, timestamp curto).
  - **Dependencias:** nenhuma externa.
  - **Estado (`signals`/providers):** nao obrigatorio.
  - **Computeds:** nao aplicavel.
  - **Metodos:** `isMine`, `formatTime`, `bubbleBackground`, `textColor`.

### 5.1.2 Views

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_screen_view.dart` (arquivo existente sera reescrito)
  - **Responsabilidade:** compor header, corpo da thread e barra inferior; reagir aos estados do presenter.
  - **Props:** `String chatId`.
  - **Dependencias de UI:** `signals_flutter`, tema compartilhado, widgets internos da pasta `chat_screen`.

### 5.1.3 Widgets

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/chat_screen/chat_header/`
  - **Responsabilidade:** header com back, avatar, nome, `last presence`, botao `Ver perfil` placeholder.
  - **Props:** `recipientName`, `recipientAvatarUrl`, `subtitle`, `onBack`, `onOpenProfile`.

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/chat_screen/chat_messages_list/`
  - **Responsabilidade:** lista invertida com grupos por data + bolhas.
  - **Props:** `sections`, `onReachTop`.
  - **Widgets internos:** `date_separator` e `message_bubble`, ambos seguindo `MVP` (View + Presenter).

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/chat_screen/chat_messages_list/date_separator/`
  - **Responsabilidade:** renderizar separador de data da thread (`HOJE`, `ONTEM`, `DD DE <MES>`), com regra no presenter.
  - **Props:** `DateTime date`.
  - **Widgets internos:** nenhum.

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/`
  - **Responsabilidade:** renderizar bolha de mensagem de texto (sem attachment).
  - **Props:** `message`, `isMine`, `timeLabel`.
  - **Widgets internos:** nenhum.

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/chat_screen/chat_empty_state/`
  - **Responsabilidade:** estado vazio conforme Stitch (icone + titulo + texto + 3 chips de sugestao).
  - **Props:** `onSuggestionTap(String text)`.

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/chat_screen/chat_input_bar/`
  - **Responsabilidade:** barra fixa inferior com `+` desabilitado, campo e envio.
  - **Props:** `draft`, `isSending`, `onChanged`, `onSend`.

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/chat_screen/chat_loading_state/`
  - **Responsabilidade:** loading inicial centralizado.
  - **Props:** nenhuma.

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/chat_screen/chat_error_state/`
  - **Responsabilidade:** erro de carregamento com acao de retry.
  - **Props:** `message`, `onRetry`.

- **Estrutura de pastas (ASCII):**
```text
chat_screen/
  chat_screen_view.dart
  chat_screen_presenter.dart
  index.dart
  chat_header/
    chat_header_view.dart
    index.dart
  chat_messages_list/
    chat_messages_list_view.dart
    index.dart
    date_separator/
      date_separator_view.dart
      date_separator_presenter.dart
      index.dart
    message_bubble/
      message_bubble_view.dart
      message_bubble_presenter.dart
      index.dart
  chat_empty_state/
    chat_empty_state_view.dart
    index.dart
  chat_input_bar/
    chat_input_bar_view.dart
    index.dart
  chat_loading_state/
    chat_loading_state_view.dart
    index.dart
  chat_error_state/
    chat_error_state_view.dart
    index.dart
```

## 5.2 Core

- **Uso de tipo existente:** `PaginationResponse<MessageDto>` (`lib/core/shared/responses/pagination_response.dart`)
  - **Tipo:** `response`
  - **Contratos/assinaturas:** `items`, `nextCursor`, `limit`
  - **Responsabilidade:** representar pagina de mensagens no `ConversationService.fetchMessagesList` sem criar DTO adicional.

- **Arquivo:** `lib/core/conversation/dtos/structures/chat_date_section_dto.dart`
  - **Tipo:** `dto`
  - **Contratos/assinaturas:**
    - `final DateTime date`
    - `final String label`
    - `final List<MessageDto> messages`
  - **Responsabilidade:** estrutura intermediaria para agrupamento por data no presenter.

## 5.3 REST

- **Arquivo:** `lib/rest/mappers/conversation/messages_pagination_mapper.dart`
  - **Service/Client:** mapper para pagina de mensagens.
  - **Metodos:** `toPagination(Json json)`.
  - **Entrada/Saida:** `Json` da API -> `PaginationResponse<MessageDto>`.

## 5.4 Drivers

- **Arquivo:** `lib/websocket/channels/conversation_channel.dart`
  - **Adapter/Driver:** implementacao concreta de `ConversationChannel`.
  - **Responsabilidade:** serializar envio de mensagem e mapear evento recebido para `MessageDto`.
  - **Dependencias:** `WebSocketClient`, `MessageMapper`.

- **Arquivo:** `lib/websocket/channels.dart`
  - **Adapter/Driver:** provider `conversationChannelProvider` (`Provider<ConversationChannel>`).
  - **Responsabilidade:** disponibilizar canal de conversa para DI no presenter.
  - **Dependencias:** `websocketClientProvider`.

# 6. O que deve ser modificado

> Lista somente arquivos existentes.

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_screen_view.dart`
  - **Mudanca:** substituir placeholder por composicao da thread completa usando `chat_screen_presenter.dart`.
  - **Justificativa:** habilitar fluxo real de conversa.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/index.dart`
  - **Mudanca:** manter `typedef`, ajustar import se necessario.
  - **Justificativa:** preservar barrel pattern.
  - **Camada:** `ui`

- **Arquivo:** `lib/core/conversation/interfaces/conversation_service.dart`
  - **Mudanca:** alinhar contrato para thread:
    - manter `fetchChat` e `fetchMessagesList`,
    - reintroduzir `sendMessage` apenas se necessario para fallback HTTP (opcional),
    - definir assinatura de `fetchMessagesList` com `limit` e `cursor`.
  - **Justificativa:** eliminar inconsistencia atual entre interface e implementacao REST.
  - **Camada:** `core`

- **Arquivo:** `lib/rest/services/conversation_service.dart`
  - **Mudanca:** implementar `fetchMessagesList` cursor-based e alinhar assinatura ao contrato atualizado.
  - **Justificativa:** suportar historico paginado da thread.
  - **Camada:** `rest`

- **Arquivo:** `lib/rest/mappers/conversation/recipient_mapper.dart`
  - **Mudanca:** mapear `last_presence_at` para `RecipientDto.lastPresenceAt`.
  - **Justificativa:** habilitar exibicao de `last presence` no header.
  - **Camada:** `rest`

- **Arquivo:** `lib/core/profiling/dtos/structures/owner_presence_dto.dart`
  - **Mudanca:** manter somente `isOnline` (sem `lastSeenAt`).
  - **Justificativa:** contrato de presenca simplificado e alinhado a regra de dominio atual.
  - **Camada:** `core`

- **Arquivo:** `lib/rest/services/profiling_service.dart`
  - **Mudanca:** implementar `fetchOwnerPresence({required String ownerId})`.
  - **Justificativa:** requisito funcional de presenca no header.
  - **Camada:** `rest`

- **Arquivo:** `lib/websocket/channels.dart`
  - **Mudanca:** expor provider `conversationChannelProvider` para DI do presenter.
  - **Justificativa:** centralizar instancia do canal e desacoplar UI do detalhe de socket.
  - **Camada:** `drivers`

- **Arquivo:** `lib/router.dart`
  - **Mudanca:** rota `Routes.chat` permanece, mas validar passagem obrigatoria de `chatId` e fallback seguro.
  - **Justificativa:** evitar abrir thread sem contexto.
  - **Camada:** `ui/navigation`

# 7. O que deve ser removido

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_screen_view.dart`
  - **Remocao:** bloco placeholder `Text('Thread $chatId')`.
  - **Motivo:** substituido por implementacao real da thread.
  - **Substituir por (se aplicavel):** `lib/ui/conversation/widgets/screens/chat_screen/chat_screen_view.dart` (nova composicao).

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)

```text
ChatScreenView
  -> ChatScreenPresenter.init(chatId)
    -> ConversationService.fetchChat(chatId)
    -> ProfilingService.fetchOwnerPresence(ownerId)
    -> ConversationService.fetchMessagesList(chatId, limit, cursor)
    -> ConversationChannel.listen(onMessageReceived: onMessageReceived)

Send flow:
View(chat_input_bar) -> Presenter.sendMessage -> ConversationChannel.emitMessageSentEvent -> API(WebSocket)

History flow:
View(reach top) -> Presenter.loadMoreMessages -> ConversationService.fetchMessagesList -> append oldest
```

## 8.2 Layout/hierarquia visual (ASCII)

```text
ChatScreen
  |- ChatHeader
  |   |- Back
  |   |- Avatar + Name + LastSeen
  |   `- Button "Ver perfil" (placeholder)
  |- Body
  |   |- [hasMessages] ChatMessagesList
  |   |   |- DateSeparator
  |   |   `- MessageBubble
  |   `- [empty] ChatEmptyState
  |       `- SuggestedChips (3 hardcoded)
  `- ChatInputBar (fixed)
      |- PlusButton (disabled)
      |- TextField
      `- SendButton
```

## 8.3 Referencias internas

- `lib/ui/conversation/widgets/screens/inbox_screen/inbox_screen_presenter.dart` (padrao de presenter com `signals` e `Provider.autoDispose`).
- `lib/rest/services/conversation_service.dart` (base de integracao REST de conversa).
- `lib/core/conversation/interfaces/conversation_channel.dart` (contrato de websocket da conversa).
- `lib/core/profiling/interfaces/profiling_service.dart` (fonte de presenca via `fetchOwnerPresence`).

## 8.4 Referencias de tela (quando houver)

- **Google Stitch screen id:** `2d9b9709fd41499caf7b0ecafd8fdb1a`
- **Google Stitch screen id:** `9f25c45664fa4f5095fc19d5d6318134`
- **Decisoes de UI extraidas:**
  - Header compacto com avatar, nome e subtitulo de presenca.
  - Estado vazio com CTAs de sugestao rapida.
  - Conversa com bolhas esquerda/direita e separadores de data.
  - Input fixo com botao `+` presente.
  - `Ver perfil` visivel no header.

# 9. Perguntas em aberto

- Definir contrato exato do endpoint de mensagens paginadas (`path`, `queryParams`, formato de cursor) no `Equiny Server` para implementar `fetchMessagesList` sem divergencia.
- Definir payload oficial do `WebSocket` (evento de entrada/saida, shape do JSON) para mapear `MessageMapper` sem inferencia.
- Definir estrategia de fallback para subtitle quando `isOnline = false` e nao houver `lastPresenceAt` no `RecipientDto` (ex.: `Visto recentemente`).

# 10. Consolidacao da implementacao

## 10.1 Status geral

- Status da spec: **em progresso**.
- Implementacao principal da thread de `chat` foi aplicada em `ui`, `core`, `rest` e `websocket`.
- Fluxo base operacional previsto: abrir por `chatId` -> carregar chat -> carregar mensagens paginadas -> conectar socket -> enviar/receber mensagem.

## 10.2 Verificacao de qualidade

- `dart format .`: executado em todo o projeto.
- `flutter analyze`: executado; sem `warning`/`error` (restaram apenas 2 `info` preexistentes sobre `print` em arquivos fora do escopo desta spec).
- `flutter test`: executado; **falhou** em suite de `profile_horse_tab` por `NotInitializedError` de `DotEnv` em `GallerySlotView` (fora do escopo da feature de chat).
- Diretrizes de codigo verificadas contra `documentation/guidelines/code-conventions-guidelines.md` e `documentation/rules/code-conventions-rules.md`.

## 10.3 Checklist de requisitos (spec x codigo)

- **RF-01 a RF-08:** implementados no fluxo de tela/presenter/canal.
- **RF-09 e RF-10:** estado vazio e sugestoes rapidas implementados.
- **RF-11:** `fetchOwnerPresence` implementado e integrado no header.
- **RF-12:** botao de anexos visivel e desabilitado no `chat_input_bar`.
- Agrupamento por data e separadores (`HOJE`, `ONTEM`, `DD DE <MES>`) aplicado.
- Canal aplicado em `lib/websocket/channels/conversation_channel.dart` com `WebSocketClient` compartilhado.

## 10.4 PRD/milestone

- PRD remoto (milestone `https://github.com/JohnPetros/equiny/milestone/9`) foi lido via `gh`.
- Nao foi necessario atualizar milestone neste ciclo, pois as decisoes finais ficaram refletidas na spec tecnica local.

## 10.5 Fluxo final consolidado (ASCII)

```ASCII
ChatScreenView
  -> ChatScreenPresenter.init(chatId)
    -> ConversationService.fetchChat(chatId)
    -> ConversationService.fetchMessagesList(chatId, limit, cursor)
    -> ProfilingService.fetchOwnerPresence(ownerId)
    -> ConversationChannel.listen(onMessageReceived: onMessageReceived)

Nova mensagem
  InputBar.onSend
    -> ChatScreenPresenter.sendMessage
      -> ConversationChannel.emitMessageSentEvent(MessageSentEvent)
      -> websocket server
      -> evento recebido -> presenter._onMessageReceived -> UI atualiza

Historico antigo
  ChatMessagesList.onReachTop
    -> ChatScreenPresenter.loadMoreMessages
      -> ConversationService.fetchMessagesList(cursor)
      -> merge + dedupe + sort
```
