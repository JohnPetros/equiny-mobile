---
title: Atualizacoes em Tempo Real da Inbox
prd: documentation\features\conversation\inbox\prd.md
status: concluido
last_updated_at: 2026-02-26
---

# 1. Objetivo

Implementar um fluxo de atualizacao em tempo real da `InboxScreen` no `equiny_mobile`, sem recarga manual da tela, para refletir novas mensagens e alteracoes de presenca (`online/offline`) dos recipients das conversas. Tecnicamente, a entrega reutiliza o socket ja conectado no app e passa a sincronizar estado da lista de chats no `Presenter` via eventos de `ConversationChannel` e `ProfilingChannel`, mantendo o fluxo principal `View -> Presenter -> Provider -> Service -> RestClient -> API` para carga inicial e fallback.

# 2. Escopo

## 2.1 In-scope
- Atualizar lista de conversas da `InboxScreen` em tempo real ao receber evento de mensagem.
- Reordenar automaticamente a lista por ultima atividade apos cada evento recebido.
- Atualizar preview da ultima mensagem e contador de nao lidas sem reload completo da tela.
- Buscar detalhes do chat via `fetchChat(chatId)` quando chegar evento de chat ainda nao presente na lista local.
- Exibir status de presenca em tempo real (`online/offline`) para cada recipient da lista.
- Conectar/desconectar listeners de socket com ciclo de vida seguro do `Presenter` (sem vazamento de callback).

## 2.2 Out-of-scope
- Alterar contratos HTTP existentes (`/conversation/chats`, `/conversation/chats/{id}`, `/profiling/owners/{id}/presence`).
- Criar push notifications, badge de app icon, ou sincronizacao em background.
- Implementar digitacao em tempo real (`typing`), entrega/leitura por mensagem em tempo real, ou busca de conversas.
- Redesenhar layout completo da inbox (mantem estrutura atual; apenas adiciona sinalizacao de presenca no item).

# 3. Requisitos

## 3.1 Funcionais
- **RF-01:** carregar lista inicial de conversas via `ConversationService.fetchChats()` como baseline do estado.
- **RF-02:** iniciar listener de `ConversationChannel.listen(...)` ao abrir a inbox e finalizar listener ao descartar o presenter.
- **RF-03:** ao receber `conversation/message.received`, atualizar `lastMessage` do chat correspondente e mover o item para o topo da lista.
- **RF-04:** quando o `chatId` do evento nao existir na lista local, buscar `fetchChat(chatId)` e inserir na lista.
- **RF-05:** recalcular `unreadCount` localmente para evento recebido de outro owner (`+1`) e manter sem incremento quando a mensagem for do owner atual.
- **RF-06:** iniciar listener de `ProfilingChannel.listen(...)` para eventos `profiling/owner.presence.registered` e `profiling/owner.presence.unregistered`.
- **RF-07:** refletir alteracao de presenca por recipient em tempo real na UI do item da inbox (indicador visual no avatar).
- **RF-08:** manter estados `loading/error/empty/content` atuais sem regressao funcional.

## 3.2 Nao funcionais
- **RNF-01:** evitar `memory leak` com limpeza explicita dos callbacks (`unsubscribe`) no `dispose` do presenter/provider.
- **RNF-02:** nao duplicar listeners para o mesmo canal durante o ciclo de vida da tela.
- **RNF-03:** manter separacao de camadas (UI sem parse de evento bruto; parse nos canais da camada `drivers`).
- **RNF-04:** atualizacao visual sem `flicker` e sem recarregar a tela inteira para cada evento.
- **RNF-05:** preservar padrao visual atual (`AppThemeColors`, `AppSpacing`, tipografia e estrutura de item existente).

# 4. O que ja existe (inventario)

> Inclui apenas componentes relevantes para entregar atualizacao em tempo real da inbox.

## 4.1 UI (`lib/ui/`)
- **`InboxScreenPresenter`** (`lib/ui/conversation/widgets/screens/inbox_screen/inbox_screen_presenter.dart`) - ja faz carga inicial de chats, ordenacao e navegacao; sera estendido para estado realtime e presenca.
- **`InboxScreenView`** (`lib/ui/conversation/widgets/screens/inbox_screen/inbox_screen_view.dart`) - ja orquestra estados da tela; sera mantido com ajustes minimos.
- **`InboxChatListItemView`** (`lib/ui/conversation/widgets/screens/inbox_screen/inbox_chat_list/inbox_chat_list_item/inbox_chat_list_item_view.dart`) - renderiza avatar/nome/preview/badge; recebera indicador de presenca.
- **`ChatHeaderView`** (`lib/ui/conversation/widgets/screens/chat_screen/chat_header/chat_header_view.dart`) - referencia interna de indicador visual de presenca no avatar.

## 4.2 Core (`lib/core/`)
- **`ConversationChannel`** (`lib/core/conversation/interfaces/conversation_channel.dart`) - contrato de recepcao/envio de eventos de conversa; ja retorna `unsubscribe`.
- **`MessageReceivedEvent`** (`lib/core/conversation/events/message_received_event.dart`) - evento com `chatId` e `message`; base para update da inbox.
- **`ProfilingChannel`** (`lib/core/profiling/interfaces/profiling_channel.dart`) - contrato de canal de presenca; sera ajustado para suportar limpeza de listener.
- **`OwnerPresenceRegisteredEvent`** (`lib/core/profiling/events/owner_presence_registered_event.dart`) - evento de entrada online.
- **`OwnerPresenceUnregisteredEvent`** (`lib/core/profiling/events/owner_presence_unregistered_event.dart`) - evento de saida offline.
- **`ChatDto`** (`lib/core/conversation/dtos/entities/chat_dto.dart`) - estrutura da conversa com `lastMessage` e `unreadCount`.
- **`RecipientDto`** (`lib/core/conversation/dtos/entities/recipient_dto.dart`) - contem `id` e `lastPresenceAt`; usado como fallback inicial de presenca.

## 4.3 REST (`lib/rest/`)
- **`ConversationService.fetchChats`** (`lib/rest/services/conversation_service.dart`) - baseline inicial da inbox.
- **`ConversationService.fetchChat`** (`lib/rest/services/conversation_service.dart`) - fallback para hidratar chat nao presente localmente.
- **`ProfilingService.fetchOwnerPresence`** (`lib/rest/services/profiling_service.dart`) - endpoint de presenca existente (fallback pontual, sem polling continuo).

## 4.4 Drivers (`lib/drivers/`)
- **`ConversationChannel`** (`lib/websocket/channels/conversation_channel.dart`) - adaptador websocket de eventos de mensagem.
- **`ProfilingChannel`** (`lib/websocket/channels/profiling_channel.dart`) - arquivo existente, ainda sem implementacao funcional de parse/listen.
- **`channels.dart`** (`lib/websocket/channels.dart`) - provider atual de `conversationChannel`; sera expandido para incluir `profilingChannelProvider`.
- **`WebSocketClient`** (`lib/core/shared/interfaces/websocket_client.dart`) - contrato com `onData` retornando callback de unsubscribe.
- **`websocketClientProvider`** (`lib/websocket/websocket_client.dart`) - instancia compartilhada de socket para canais.
- **`CacheDriver`** (`lib/drivers/cache-driver/index.dart`) - fonte de `ownerId` atual para regra de `unreadCount` local.

# 5. O que deve ser criado

> Nesta iteracao, a entrega pode ser feita apenas com evolucao de arquivos existentes.

## 5.1 UI
- Nenhum **novo arquivo** obrigatorio.

## 5.2 Core
- Nenhum **novo arquivo** obrigatorio.

## 5.3 REST
- Nenhum **novo arquivo** obrigatorio.

## 5.4 Drivers
- Nenhum **novo arquivo** obrigatorio.

# 6. O que deve ser modificado

> Lista somente de arquivos existentes impactados por esta implementacao.

- **Arquivo:** `lib/ui/conversation/widgets/screens/inbox_screen/inbox_screen_presenter.dart`
  - **Mudanca:** incluir dependencias de realtime (`ConversationChannel`, `ProfilingChannel`, `CacheDriver`), adicionar sinais de presenca por owner (`Signal<Map<String, bool>>`) e callbacks de subscription (`void Function()?`), implementar metodos de `connectRealtime()`, `disconnectRealtime()`, `_onMessageReceived(...)`, `_onOwnerPresenceRegistered(...)`, `_onOwnerPresenceUnregistered(...)`, `isRecipientOnline(...)` e merge de chat sem recarga completa.
  - **Justificativa:** centralizar sincronizacao de eventos de mensagem/presenca na camada de apresentacao, mantendo UI declarativa.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/conversation/widgets/screens/inbox_screen/inbox_chat_list/inbox_chat_list_item/inbox_chat_list_item_view.dart`
  - **Mudanca:** adicionar indicador visual de presenca (dot) no avatar usando estado exposto pelo `InboxScreenPresenter`.
  - **Justificativa:** tornar online/offline visivel na lista de conversas sem alterar o layout macro da tela.
  - **Camada:** `ui`

- **Arquivo:** `lib/core/profiling/interfaces/profiling_channel.dart`
  - **Mudanca:** ajustar assinatura de `listen(...)` para retornar `void Function()` (unsubscribe), alinhando com contrato de `WebSocketClient.onData(...)`.
  - **Justificativa:** permitir lifecycle seguro dos listeners e evitar vazamento ao sair da inbox.
  - **Camada:** `core`

- **Arquivo:** `lib/websocket/channels/profiling_channel.dart`
  - **Mudanca:** implementar `ProfilingChannel` concreto com parse de eventos, mapeamento para `OwnerPresenceRegisteredEvent`/`OwnerPresenceUnregisteredEvent` e envio de `OwnerEnteredEvent` quando aplicavel.
  - **Justificativa:** encapsular protocolo websocket de presenca no adapter de `drivers`, evitando parse bruto na UI.
  - **Camada:** `drivers`

- **Arquivo:** `lib/websocket/channels.dart`
  - **Mudanca:** expor `profilingChannelProvider` alem de `conversationChannelProvider`.
  - **Justificativa:** disponibilizar canal de presenca via DI (`Riverpod`) para o presenter da inbox.
  - **Camada:** `drivers`

- **Arquivo:** `lib/ui/conversation/widgets/screens/inbox_screen/inbox_screen_view.dart`
  - **Mudanca:** garantir chamada unica de inicializacao realtime via presenter/provider (sem listeners duplicados em rebuild).
  - **Justificativa:** evitar multiplas inscricoes de socket causadas por reconstrucoes da view.
  - **Camada:** `ui`

# 7. O que deve ser removido

- Nenhuma remocao obrigatoria nesta iteracao.

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)
```text
Carga inicial
View -> Presenter -> Provider -> Service -> RestClient -> API

Atualizacao realtime (mensagens)
WebSocket -> ConversationChannel -> InboxScreenPresenter -> signals -> InboxChatListItemView

Atualizacao realtime (presenca)
WebSocket -> ProfilingChannel -> InboxScreenPresenter -> signals -> InboxChatListItemView
```

## 8.2 Layout/hierarquia visual (ASCII)
```text
InboxScreen
  |- Header
  `- ChatList
      `- ChatListItem
          |- Avatar
          |   `- PresenceDot (online)
          |- RecipientName + Timestamp
          `- LastMessagePreview + UnreadBadge
```

## 8.3 Referencias internas
- `lib/ui/conversation/widgets/screens/inbox_screen/inbox_screen_presenter.dart` (estado atual da inbox)
- `lib/websocket/channels/conversation_channel.dart` (parse de evento de mensagem)
- `lib/core/profiling/interfaces/profiling_channel.dart` (contrato de presenca)
- `lib/ui/conversation/widgets/screens/chat_screen/chat_header/chat_header_view.dart` (referencia de indicador de presenca)

## 8.4 Referencias de tela (quando houver)
- **Google Stitch screen id:** nao informado
- **Decisoes de UI extraidas:**
  - Manter layout atual da inbox e adicionar apenas indicador discreto de presenca no avatar.
  - Reaproveitar linguagem visual ja aplicada no `chat_header` para online/offline.

# 9. Perguntas em aberto

- O payload oficial dos eventos de presenca no socket e sempre `payload.owner_id`? **Assumido nesta spec:** sim, com fallback para string vazia quando ausente.
- A regra de `unreadCount` local para mensagem recebida do proprio owner deve permanecer inalterada ou zerar? **Assumido nesta spec:** manter inalterada e delegar reconciliacao final ao backend no proximo `fetchChats`.
- O status offline deve exibir texto no item da inbox ou apenas dot visual? **Assumido nesta spec:** apenas dot para online (sem label textual), para manter densidade visual atual.

# 10. Consolidacao final da entrega

## 10.1 Conferencia de implementacao vs spec

- **RF-01:** concluido com `loadChats()` usando `ConversationService.fetchChats()` como baseline.
- **RF-02:** concluido com `connectRealtime()` no `init()` e `disconnectRealtime()` no `dispose` (`ref.onDispose`).
- **RF-03:** concluido em `_onMessageReceived(...)`, atualizando `lastMessage` e reordenando via `sortedChats`.
- **RF-04:** concluido com `_fetchMissingChat(chatId)` chamando `fetchChat` para chat ausente.
- **RF-05:** concluido com incremento local de `unreadCount` somente para mensagens recebidas de outro owner.
- **RF-06:** concluido com listener de `ProfilingChannel.listen(...)` para eventos de presenca registrada/removida.
- **RF-07:** concluido com `isRecipientOnline(...)` no presenter e `PresenceDot` em `InboxChatListItemView`.
- **RF-08:** concluido mantendo estados de `loading/error/empty/content` na `InboxScreenView`.

## 10.2 Validacao tecnica

- `dart format .`: executado, com formatacao aplicada.
- `flutter analyze`: executado sem issues.
- `flutter test`: suite da inbox validada (`inbox_screen_presenter_test.dart` e `inbox_screen_view_test.dart`) com sucesso.
- `flutter test` completo: identificado erro preexistente fora do escopo desta spec em `test/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_tab_view_test.dart` por dependencia de `dotenv`/`fileStorageDriverProvider` sem override de teste.

## 10.3 Atualizacao de documentacao relacionada

- PRD associado (`documentation/features/conversation/inbox/prd.md`) mantido como ponte para milestone.
- Milestone GitHub `https://github.com/JohnPetros/equiny/milestone/8` atualizada com status consolidado da entrega.
- Nenhum novo padrao arquitetural foi introduzido alem dos ja cobertos em `documentation/rules/*.md`; nao houve necessidade de nova rule.
