---
title: Tela de Inbox (Lista de Conversas)
prd: documentation\features\conversation\inbox\prd.md
status: concluido
last_updated_at: 2026-02-21
---

# 1. Objetivo

Implementar a tela de **Inbox** no app mobile, exibindo a lista de conversas iniciadas (com >= 1 mensagem) do usuario autenticado. A tela deve apresentar cada conversa com avatar do recipient, nome, preview da ultima mensagem, timestamp relativo e badge de nao lidas, alem de estados de carregamento, erro e vazio. O fluxo arquitetural segue `View -> Presenter -> Provider -> Service -> RestClient -> API`, reaproveitando padroes ja consolidados na `matches_screen` (header com contador, lista de itens, estados, `bottom dialog`) e nos DTOs existentes em `lib/core/conversation/`.

# 2. Escopo

## 2.1 In-scope

- Listagem de conversas com >= 1 mensagem, ordenadas por atividade mais recente.
- Item de lista: avatar do recipient (dono), nome do recipient, preview da ultima mensagem (1 linha), timestamp relativo, badge de nao lidas.
- Header com titulo "Conversas" e contador de conversas com mensagens nao lidas.
- Estado de carregamento (skeleton/spinner).
- Estado de erro com botao "Tentar novamente".
- Estado vazio com microcopy educativa e CTA "Ir para Matches".
- Tap no item navega diretamente para a tela de chat (thread) — **sem** `bottom dialog`.
- Recarregamento automatico da lista ao retornar da thread (atualizacao de preview, nao lidas, reordenacao).
- `Presenter` com `signals` para estado reativo.
- `Provider` Riverpod para DI.
- `REST Service` implementando `ConversationService.fetchChats()`.
- `Mapper` para converter JSON da API em `ChatDto`.

## 2.2 Out-of-scope

- Iniciar nova conversa pela Inbox.
- Tela de thread/chat (sera spec separada).
- Busca e filtros de conversas.
- Arquivar, silenciar ou bloquear conversas.
- Envio de midia, audios ou anexos.
- Indicadores de digitacao.
- Notificacoes push.
- Paginacao/infinite scroll (MVP carrega lista completa; paginacao pode ser adicionada depois).

# 3. Requisitos

## 3.1 Funcionais

- **RF-01:** Carregar lista de conversas do usuario autenticado via `GET /conversation/chats`.
- **RF-02:** Exibir apenas conversas com >= 1 mensagem (filtro feito pela API).
- **RF-03:** Ordenar por `lastMessage.sentAt` descendente (mais recente primeiro).
- **RF-04:** Exibir avatar, nome, preview da ultima mensagem truncado em 1 linha, timestamp relativo e badge de nao lidas por item.
- **RF-05:** Ao tocar em um item, navegar para a rota `Routes.chat` passando o `chatId` como parametro.
- **RF-06:** Ao retornar da thread, recarregar a lista para refletir alteracoes (nova mensagem, leitura, reordenacao).
- **RF-07:** Exibir estado vazio com CTA "Ir para Matches" quando lista estiver vazia.
- **RF-08:** Exibir estado de erro com botao "Tentar novamente" em caso de falha.
- **RF-09:** Exibir estado de carregamento durante fetch inicial.

## 3.2 Nao funcionais

- **RNF-01:** Avatars com lazy-load (`NetworkImage`).
- **RNF-02:** Contraste adequado seguindo `AppThemeColors` (dark theme).
- **RNF-03:** Responsivo em diferentes tamanhos de tela mobile.
- **RNF-04:** Sem flicker ao retornar da thread (atualizar in-place).

# 4. O que ja existe (inventario)

## 4.1 UI (`lib/ui/`)

- **`InboxScreenView`** (`lib/ui/conversation/widgets/screens/inbox_screen/inbox_screen_view.dart`) — tela implementada com orquestracao de estados (loading/error/empty/content) via `InboxScreenPresenter`.
- **`index.dart`** (`lib/ui/conversation/widgets/screens/inbox_screen/index.dart`) — barrel file com `typedef InboxScreen = InboxScreenView`. Permanece inalterado.
- **`MatchesScreenPresenter`** (`lib/ui/matches/widgets/screens/matches_screen/matches_screen_presenter.dart`) — referencia de padrao MVP com `signals`, `computed`, estados de loading/error/empty, `Provider.autoDispose`. **Base de referencia**.
- **`MatchesScreenContentView`** (`lib/ui/matches/widgets/screens/matches_screen/matches_screen_content_view.dart`) — referencia de como orquestrar estados (loading, error, empty, content) usando `Watch`. **Base de referencia**.
- **`MatchesHeaderView`** (`lib/ui/matches/widgets/screens/matches_screen/matches_header/matches_header_view.dart`) — header com titulo + badge de contagem. **Pode ser reutilizado ou replicado** com adaptacao para "Conversas".
- **`MatchesListItemView`** / **`MatchesListItemPresenter`** (`lib/ui/matches/widgets/screens/matches_screen/matches_list/matches_list_item/`) — item de lista com avatar, nome, timestamp relativo. `formatRelativeTime` e `buildOwnerInitials` no presenter. **Logica de formatacao sera reaproveitada**.
- **`MatchesScreenLoadingStateView`**, **`MatchesScreenErrorStateView`**, **`MatchesScreenEmptyStateView`** (`lib/ui/matches/widgets/screens/matches_screen/matches_screen_state/`) — views de estado. **Padrao a replicar**.
- **`AppThemeColors`**, **`AppSpacing`**, **`AppFontSize`**, **`AppRadius`** (`lib/ui/shared/theme/app_theme.dart`) — constantes de tema. **Usar obrigatoriamente**.

## 4.2 Core (`lib/core/`)

- **`ChatDto`** (`lib/core/conversation/dtos/entities/chat_dto.dart`) — DTO com `id`, `recipient` (`RecipientDto`), `lastMessage` (`MessageDto`). **Sera modificado** para adicionar `unreadCount`.
- **`MessageDto`** (`lib/core/conversation/dtos/entities/message_dto.dart`) — DTO com `id`, `content`, `senderId`, `receiverId`, `sentAt`, `attachments`. **Reutilizado como esta**.
- **`RecipientDto`** (`lib/core/conversation/dtos/entities/recipient_dto.dart`) — DTO com `id`, `name`, `avatar` (`ImageDto?`). **Reutilizado como esta**.
- **`AttachmentDto`** (`lib/core/conversation/dtos/structures/attachment_dto.dart`) — DTO de anexo. **Reutilizado como esta** (presente em `MessageDto.attachments`).
- **`ConversationService`** (`lib/core/conversation/interfaces/conversation_service.dart`) — interface com `fetchChats()`, `fetchChat()`, `sendMessage()`. **Reutilizada como esta**.
- **`ImageDto`** (`lib/core/profiling/dtos/structures/image_dto.dart`) — DTO de imagem com `key`, `name`. Usado por `RecipientDto.avatar`. **Reutilizado como esta**.
- **`RestResponse<T>`** (`lib/core/shared/responses/rest_response.dart`) — wrapper de resposta. **Reutilizado como esta**.
- **`RestClient`** (`lib/core/shared/interfaces/rest_client.dart`) — interface HTTP. **Reutilizada como esta**.
- **`Routes`** (`lib/core/shared/constants/routes.dart`) — constantes de rotas. **Sera modificado** para adicionar `Routes.chat`.

## 4.3 REST (`lib/rest/`)

- **`Service`** (`lib/rest/services/service.dart`) — classe base com `restClient`, `cacheDriver`, `setAuthHeader()`. **Sera estendida** pelo novo `ConversationService`.
- **`services.dart`** (`lib/rest/services.dart`) — providers de servicos. **Sera modificado** para adicionar `conversationServiceProvider`.
- **`ImageMapper`** (`lib/rest/mappers/profiling/image_mapper.dart`) — mapper de `ImageDto`. **Reutilizado** pelo `ChatMapper`.

## 4.4 Drivers (`lib/drivers/`)

- **`NavigationDriver`** / **`GoRouterNavigationDriver`** (`lib/drivers/navigation-driver/`) — navegacao. **Reutilizado** pelo `InboxScreenPresenter`.
- **`FileStorageDriver`** (`lib/drivers/file-storage-driver/`) — resolve URL de imagem via `getFileUrl(key)`. **Reutilizado** para resolver avatar URL.
- **`CacheDriver`** (`lib/drivers/cache-driver/`) — cache local. **Reutilizado** pelo `Service` base.

# 5. O que deve ser criado

## 5.1 UI

### 5.1.1 Presenters

- **Arquivo:** `lib/ui/conversation/widgets/screens/inbox_screen/inbox_screen_presenter.dart` **(novo)**
  - **Responsabilidade:** Orquestra carregamento de chats, gerencia estados (loading, error, empty, content), formata dados para exibicao e trata navegacao.
  - **Dependencias:** `ConversationService` (core interface), `NavigationDriver`, `FileStorageDriver`.
  - **Estado (`signals`):**
    - `Signal<List<ChatDto>> chats` — lista de conversas carregadas.
    - `Signal<bool> isLoadingInitial` — flag de carregamento inicial.
    - `Signal<String?> errorMessage` — mensagem de erro.
  - **Computeds:**
    - `ReadonlySignal<List<ChatDto>> sortedChats` — chats ordenados por `lastMessage.sentAt` desc.
    - `ReadonlySignal<int> unreadConversationsCount` — total de conversas com `unreadCount > 0`.
    - `ReadonlySignal<bool> isEmptyState` — `true` quando nao esta carregando, nao tem erro e lista esta vazia.
    - `ReadonlySignal<bool> hasError` — `true` quando `errorMessage != null`.
  - **Metodos:**
    - `void init()` — dispara `loadChats()` via `unawaited`.
    - `Future<void> loadChats()` — chama `ConversationService.fetchChats()`, atualiza signals.
    - `Future<void> retry()` — alias para `loadChats()`.
    - `String formatRelativeTimestamp(DateTime sentAt)` — formata timestamp relativo ("14:32", "Ontem", "Segunda", "Domingo"). Logica: mesmo dia -> `HH:mm`; ontem -> "Ontem"; mesma semana -> dia da semana; outro -> `dd/MM`.
    - `String buildRecipientInitials(String name)` — extrai iniciais (mesmo algoritmo de `MatchesListItemPresenter.buildOwnerInitials`).
    - `String resolveAvatarUrl(ImageDto? avatar)` — usa `FileStorageDriver.getFileUrl` se houver key.
    - `void openChat(ChatDto chat)` — navega para `Routes.chat` passando `chat.id` como data.
    - `void goToMatches()` — navega para `Routes.matches`.
  - **Provider:**
    ```dart
    final inboxScreenPresenterProvider =
        Provider.autoDispose<InboxScreenPresenter>((ref) {
          final presenter = InboxScreenPresenter(
            ref.watch(conversationServiceProvider),
            ref.watch(navigationDriverProvider),
            ref.watch(fileStorageDriverProvider),
          );
          presenter.init();
          return presenter;
        });
    ```

### 5.1.2 Views

- **Arquivo:** `lib/ui/conversation/widgets/screens/inbox_screen/inbox_screen_view.dart` **(existente, reescrito)**
  - **Responsabilidade:** Orquestra os estados da tela (loading, error, empty, content) e renderiza o `InboxScreenContent`.
  - **Tipo:** `ConsumerWidget`.
  - **Dependencias de UI:** `InboxScreenPresenter`, `InboxScreenContentView`, estados.

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/inbox_screen/inbox_screen_content/` **(novo)**
  - **Arquivos:** `inbox_screen_content_view.dart`, `index.dart`
  - **Responsabilidade:** Renderiza o conteudo principal — header + lista de chats. Usa `Watch` para reatividade.
  - **Props:** `InboxScreenPresenter presenter`, `void Function(ChatDto) onTapItem`.
  - **Dependencias de UI:** `InboxHeader`, `InboxChatList`, estados.

### 5.1.3 Widgets

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/inbox_screen/inbox_header/` **(novo)**
  - **Arquivos:** `inbox_header_view.dart`, `index.dart`
  - **Responsabilidade:** Header com titulo "Conversas" e badge de contagem de conversas nao lidas.
  - **Props:** `String title`, `int unreadCount`.
  - **Widgets internos:** nenhum.
  - **Referencia:** Replica padrao de `MatchesHeaderView` com ajustes visuais.

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/inbox_screen/inbox_chat_list/` **(novo)**
  - **Arquivos:** `inbox_chat_list_view.dart`, `index.dart`
  - **Responsabilidade:** Renderiza `ListView` de `InboxChatListItem`.
  - **Props:** `List<ChatDto> items`, `void Function(ChatDto) onTapItem`.
  - **Widgets internos:** `InboxChatListItem`.

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/inbox_screen/inbox_chat_list/inbox_chat_list_item/` **(novo)**
  - **Arquivos:** `inbox_chat_list_item_view.dart`, `inbox_chat_list_item_presenter.dart`, `index.dart`
  - **Responsabilidade:** Renderiza um item da lista: avatar circular, nome do recipient, preview da mensagem (1 linha, truncado com ellipsis), timestamp relativo, badge de nao lidas, icone de check (mensagem lida/enviada).
  - **Props:** `ChatDto chat`, `VoidCallback onTap`, `String avatarUrl`, `String initials`, `String formattedTimestamp`.
  - **Presenter (`InboxChatListItemPresenter`):**
    - `String truncatePreview(String content, {int maxLength = 35})` — trunca com "..." se necessario.
    - `bool shouldShowUnreadBadge(int unreadCount)` — retorna `true` se `unreadCount > 0`.
    - `bool shouldShowReadCheck(ChatDto chat, String currentUserId)` — retorna `true` se a ultima mensagem foi enviada pelo usuario e `unreadCount == 0`.

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/inbox_screen/inbox_screen_state/` **(novo)**
  - **Arquivos:**
    - `inbox_screen_loading_state_view.dart` — `CircularProgressIndicator` centralizado.
    - `inbox_screen_error_state_view.dart` — mensagem de erro + botao "Tentar novamente". Props: `String message`, `Future<void> Function() onRetry`.
    - `inbox_screen_empty_state_view.dart` — microcopy "Sem conversas ainda" + texto educativo + CTA "Ir para Matches". Props: `VoidCallback onGoToMatches`.
    - `index.dart` — barrel file exportando os tres.
  - **Referencia:** Replica padrao de `matches_screen_state/`.

- **Estrutura de pastas (ASCII):**
```text
inbox_screen/
  inbox_screen_view.dart          (existente, reescrito)
  inbox_screen_presenter.dart     (novo)
  index.dart                      (existente, inalterado)
  inbox_screen_content/
    inbox_screen_content_view.dart  (novo)
    index.dart                      (novo)
  inbox_header/
    inbox_header_view.dart        (novo)
    index.dart                    (novo)
  inbox_chat_list/
    inbox_chat_list_view.dart     (novo)
    index.dart                    (novo)
    inbox_chat_list_item/
      inbox_chat_list_item_view.dart       (novo)
      inbox_chat_list_item_presenter.dart  (novo)
      index.dart                           (novo)
  inbox_screen_state/
    inbox_screen_loading_state_view.dart   (novo)
    inbox_screen_error_state_view.dart     (novo)
    inbox_screen_empty_state_view.dart     (novo)
    index.dart                             (novo)
```

## 5.2 Core

Nenhum arquivo novo. Apenas modificacoes (secao 6).

## 5.3 REST

- **Arquivo:** `lib/rest/services/conversation_service.dart` **(novo)**
  - **Service:** `ConversationService extends Service implements conversation_service.ConversationService`
  - **Metodos:**
    - `fetchChats()` — `GET /conversation/chats` com auth header. Retorna `RestResponse<List<ChatDto>>` via `ChatMapper.toDtoList`.
    - `fetchChat({required String chatId})` — `GET /conversation/chats/{chatId}` com auth header. Retorna `RestResponse<ChatDto>` via `ChatMapper.toDto`.
    - `sendMessage({required MessageDto message})` — `POST /conversation/messages` com auth header e body via `MessageMapper.toJson`. Retorna `RestResponse<MessageDto>` via `MessageMapper.toDto`.
  - **Entrada/Saida:** JSON da API (`snake_case`) convertido para DTOs via mappers.

- **Arquivo:** `lib/rest/mappers/conversation/chat_mapper.dart` **(novo)**
  - **Mapper:** `ChatMapper`
  - **Metodos estaticos:**
    - `static ChatDto toDto(Json json)` — converte JSON em `ChatDto`, usando `RecipientMapper.toDto`, `MessageMapper.toDto`.
    - `static List<ChatDto> toDtoList(Json json)` — converte lista JSON (`json['items']`) em `List<ChatDto>`.

- **Arquivo:** `lib/rest/mappers/conversation/recipient_mapper.dart` **(novo)**
  - **Mapper:** `RecipientMapper`
  - **Metodos estaticos:**
    - `static RecipientDto toDto(Json json)` — converte JSON em `RecipientDto`, usando `ImageMapper.toDto` para avatar.

- **Arquivo:** `lib/rest/mappers/conversation/message_mapper.dart` **(novo)**
  - **Mapper:** `MessageMapper`
  - **Metodos estaticos:**
    - `static MessageDto toDto(Json json)` — converte JSON em `MessageDto`, parseando `sent_at` como `DateTime`.
    - `static Json toJson(MessageDto dto)` — converte `MessageDto` em JSON para envio.

## 5.4 Drivers

Nenhum arquivo novo. Drivers existentes sao reutilizados.

# 6. O que deve ser modificado

- **Arquivo:** `lib/core/conversation/dtos/entities/chat_dto.dart`
  - **Mudanca:** Adicionar campo `final int unreadCount` ao `ChatDto`. Valor default `0`. Adicionar parametro `this.unreadCount = 0` no construtor.
  - **Justificativa:** O layout exige badge de mensagens nao lidas por conversa. A API retornara esse valor.
  - **Camada:** `core`

- **Arquivo:** `lib/core/shared/constants/routes.dart`
  - **Mudanca:** Adicionar `static const String chat = '/chat';` na classe `Routes`.
  - **Justificativa:** Rota necessaria para navegacao do item da Inbox para a tela de chat/thread.
  - **Camada:** `core`

- **Arquivo:** `lib/rest/services.dart`
  - **Mudanca:** Adicionar `conversationServiceProvider` seguindo o padrao dos outros providers:
    ```dart
    final conversationServiceProvider = Provider<conversation_service.ConversationService>((ref) {
      return conversation_service_impl.ConversationService(
        ref.watch(restClientProvider),
        ref.watch(cacheDriverProvider),
      );
    });
    ```
  - **Justificativa:** Registrar o servico de conversas no grafo de DI do Riverpod.
  - **Camada:** `rest`

- **Arquivo:** `lib/ui/conversation/widgets/screens/inbox_screen/inbox_screen_view.dart`
  - **Mudanca:** Reescrito como `ConsumerWidget`, com `InboxScreenPresenter` via `ref.watch(inboxScreenPresenterProvider)` e orquestracao de estados delegando para `InboxScreenContentView`.
  - **Justificativa:** Substituir placeholder pela implementacao real.
  - **Camada:** `ui`

- **Arquivo:** `lib/router.dart`
  - **Mudanca:** Adicionada rota `Routes.chat` com `ChatScreen` (`state.extra` como `chatId`).
  - **Justificativa:** Evitar navegação quebrada ao tocar em item da Inbox durante a fase atual, mantendo o fluxo de ida/volta para Inbox.
  - **Camada:** `ui/navigation`

- **Arquivo:** `lib/rest/mappers/profiling/image_mapper.dart`
  - **Mudanca:** Adicionado método `ImageMapper.toDto(Json)`.
  - **Justificativa:** Reuso em `RecipientMapper` para mapear avatar sem duplicação de regra.
  - **Camada:** `rest`

# 7. O que deve ser removido

Nenhuma remocao necessaria. O conteudo do placeholder de `inbox_screen_view.dart` sera substituido in-place (secao 6).

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)

```text
InboxScreenView (ConsumerWidget)
  |-> ref.watch(inboxScreenPresenterProvider)
        |-> InboxScreenPresenter
              |-> ConversationService.fetchChats()  [core interface]
                    |-> REST ConversationService     [rest implementation]
                          |-> RestClient.get('/conversation/chats')
                                |-> DioRestClient -> Equiny Server API
                          |<- RestResponse<Json>
                          |-> ChatMapper.toDtoList(json)
                    |<- RestResponse<List<ChatDto>>
              |-> atualiza signals (chats, isLoadingInitial, errorMessage)
        |-> InboxScreenContentView renderiza via Watch()
              |-> InboxHeader (titulo + badge unreadCount)
              |-> InboxChatList
                    |-> InboxChatListItem (avatar, nome, preview, timestamp, badge)
                          |-> onTap -> presenter.openChat(chat)
                                |-> NavigationDriver.goTo(Routes.chat, data: chatId)
```

## 8.2 Layout/hierarquia visual (ASCII)

```text
InboxScreen (Scaffold, bg: AppThemeColors.background)
  `- SafeArea
       `- Watch()
            |- [isLoadingInitial] -> InboxScreenLoadingState
            |- [hasError]         -> InboxScreenErrorState
            |- [isEmptyState]     -> InboxScreenEmptyState
            `- [content]          -> SingleChildScrollView
                 `- Column
                      |- Padding (horizontal: AppSpacing.md)
                      |    `- InboxHeader
                      |         |- Text "Conversas" (fontSize: 24, bold)
                      |         `- Badge "{n} novas" (se unreadCount > 0)
                      `- InboxChatList (ListView.separated)
                           `- InboxChatListItem [por item]
                                `- InkWell (onTap -> openChat)
                                     `- Container (surface + border + borderRadius: 14)
                                          `- Row
                                               |- CircleAvatar (radius: 20, avatar ou iniciais)
                                               |    `- [online indicator: dot verde] (opcional futuro)
                                               |- SizedBox(width: 12)
                                               `- Expanded Column
                                                    |- Row
                                                    |    |- Expanded Text (nome, bold, 15px)
                                                    |    `- Text (timestamp, textSecondary, 12px)
                                                    `- Row
                                                         |- [check icon] (se enviada pelo usuario e lida)
                                                         |- Expanded Text (preview, textSecondary, 13px, maxLines: 1, ellipsis)
                                                         `- [Badge circular] (se unreadCount > 0, primary color)
```

## 8.3 Referencias internas

- `lib/ui/matches/widgets/screens/matches_screen/` — estrutura de screen com presenter, content view, estados e widgets internos. **Principal referencia arquitetural**.
- `lib/ui/matches/widgets/screens/matches_screen/matches_list/matches_list_item/matches_list_item_presenter.dart` — `formatRelativeTime()` e `buildOwnerInitials()`. **Logica a replicar/adaptar**.
- `lib/rest/services/matching_service.dart` — padrao de implementacao de service REST. **Referencia para `ConversationService`**.
- `lib/rest/mappers/profiling/image_mapper.dart` — mapper de `ImageDto`. **Reutilizado nos mappers de conversa**.

## 8.4 Referencias de tela

- **Imagem do layout:** `.cp-images/pasted-image-2026-02-20T01-26-00-126Z.png`
- **Decisoes de UI extraidas:**
  - Fundo escuro (`AppThemeColors.background`).
  - Titulo "Conversas" grande (24px, bold) no topo esquerdo, sem badge no header original (badge sera adicionado seguindo padrao de `MatchesHeader`).
  - Cada item: avatar circular a esquerda, nome bold + timestamp a direita na mesma linha, preview + badge/check na linha abaixo.
  - Badge numerico circular em roxo (`AppThemeColors.primary`) quando ha nao lidas.
  - Icone de double-check (cinza) quando mensagem foi enviada pelo usuario e nao ha nao lidas.
  - Timestamp relativo: hora (mesmo dia), "Ontem", dia da semana (mesma semana), "dd/MM" (anterior).
  - Sem separadores explicitos entre items; espacamento vertical entre cards.
  - Sem indicador de online/presenca no MVP.

# 9. Consolidacao da Implementacao (2026-02-21)

## 9.1 Status geral

- Status: **implementacao concluida para Inbox MVP**.
- Camadas implementadas: `core`, `rest`, `ui` (drivers reutilizados, sem novos drivers).
- Fluxo principal operacional: Inbox -> abrir conversa (`Routes.chat`) -> retorno para Inbox.

## 9.2 Verificacao de qualidade

- `dart format .` executado no repositório.
- `flutter analyze` executado no repositório (sem warnings/erros).
- `flutter test` executado no repositório (suite passando).
- Diretrizes de codificação validadas com base em `documentation/rules/code-conventions-rules.md` (arquivo solicitado em `documentation/guidelines/code-conventions-guidelines.md` nao foi encontrado no repo).

## 9.3 Checklist de requisitos (Spec x Implementacao)

- **RF-01:** OK (`ConversationService.fetchChats()` -> `GET /conversation/chats`).
- **RF-02:** OK (filtro de conversas com mensagem delegado para API; Inbox consome retorno pronto).
- **RF-03:** OK (`sortedChats` ordena por `lastMessage.sentAt` desc).
- **RF-04:** OK (avatar, nome, preview truncado, timestamp relativo, badge de nao lidas no item).
- **RF-05:** OK (`openChat` navega para `Routes.chat` com `chatId`).
- **RF-06:** OK (retorno para Inbox recarrega via ciclo de inicializacao do presenter ao reentrar na rota).
- **RF-07:** OK (estado vazio com CTA "Ir para Matches" e layout final alinhado ao mock).
- **RF-08:** OK (estado de erro com retry).
- **RF-09:** OK (estado de loading inicial).

## 9.4 Fluxo final de navegacao (ASCII)

```ASCII
InboxScreenView
  -> ref.watch(inboxScreenPresenterProvider)
     -> loadChats()
        -> ConversationService.fetchChats()
           -> RestClient.get('/conversation/chats')
           -> ChatMapper.toDtoList(...)
     -> render states
        -> loading | error | empty | content

content
  -> InboxChatListItem.onTap
     -> presenter.openChat(chat)
        -> NavigationDriver.goTo(Routes.chat, data: chatId)

ChatScreen (placeholder tecnico)
  -> back action
     -> go(Routes.inbox)
        -> presenter reinicializa e recarrega a lista
```

## 9.5 Pendencias e decisoes

- **Thread completa de chat** continua fora do escopo desta spec (mantida como placeholder tecnico para viabilizar navegacao).
- **Loading state** foi implementado com spinner centralizado (nao skeleton) para manter consistencia com o padrao ja aplicado em outras telas do projeto.
