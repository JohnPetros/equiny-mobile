# Regras da Camada WebSocket

Estas regras definem responsabilidades, limites e padroes para a camada `lib/websocket/`. O objetivo e entregar realtime (chat, presenca, eventos) sem que a UI dependa do protocolo WebSocket nem de bibliotecas concretas.

## Escopo

### Objetivo

- Fornecer comunicacao em tempo real via WebSocket, com contratos definidos no Core e implementacoes isoladas em `lib/websocket/`.

### Responsabilidades

- Implementar o contrato `WebSocketClient` do Core: [`lib/core/shared/interfaces/websocket_client.dart`](../../lib/core/shared/interfaces/websocket_client.dart).
- Implementar canais/adaptadores que traduzem mensagens (JSON) em eventos/DTOs do Core (ex.: `ConversationChannel`, `ProfilingChannel`).
- Expor providers (Riverpod) para DI do client e dos canais.

### Fora de escopo (limites)

- Nao conter logica de UI (widgets/presenters), nem regras de negocio.
- Nao fazer chamadas REST nem persistence.
- Nao gerenciar sessao/autenticacao diretamente; a orquestracao de conexao/sessao pertence ao app: [`lib/app.dart`](../../lib/app.dart).

## Estrutura

### Pastas

- `lib/websocket/` (facade/providers)
- `lib/websocket/wsc/` (implementacao concreta do client)
- `lib/websocket/channels/` (canais/adaptadores por feature)

### Arquivos (referencia rapida)

- [`lib/websocket/websocket_client.dart`](../../lib/websocket/websocket_client.dart)
  - Provider `websocketClientProvider` cria/compartilha o `WebSocketClient` e garante `disconnect()` via `ref.onDispose`.
- [`lib/websocket/wsc/wsc_websocket_client.dart`](../../lib/websocket/wsc/wsc_websocket_client.dart)
  - `WscWebSocketClient` (adapter) baseado em `web_socket_channel`.
- [`lib/websocket/channels/channel.dart`](../../lib/websocket/channels/channel.dart)
  - Base utilitaria (parse do envelope: `name/payload` com fallback `event/data`).
- [`lib/websocket/channels/conversation_channel.dart`](../../lib/websocket/channels/conversation_channel.dart)
  - Implementa o contrato [`lib/core/conversation/interfaces/conversation_channel.dart`](../../lib/core/conversation/interfaces/conversation_channel.dart).
- [`lib/websocket/channels/profiling_channel.dart`](../../lib/websocket/channels/profiling_channel.dart)
  - Implementa o contrato [`lib/core/profiling/interfaces/profiling_channel.dart`](../../lib/core/profiling/interfaces/profiling_channel.dart).
- [`lib/websocket/channels.dart`](../../lib/websocket/channels.dart)
  - Providers dos canais (`conversationChannelProvider`, `profilingChannelProvider`).

### Convencoes

- Arquivos e diretorios seguem `snake_case` (ver [`documentation/rules/code-conventions-rules.md`](./code-conventions-rules.md)).
- Novo canal deve viver em `lib/websocket/channels/` e ser exposto por provider em `lib/websocket/channels.dart`.

## Contratos e envelopes

### Contrato do client

- O Core define `WebSocketClient` e a camada WebSocket implementa.
- `WebSocketClient.onData(...)` deve retornar `void Function()` para permitir `unsubscribe` (contrato em [`lib/core/shared/interfaces/websocket_client.dart`](../../lib/core/shared/interfaces/websocket_client.dart)).

### Envelope de evento

- Mensagens trafegadas devem ser tratadas como envelope (padrao):

```json
{"name":"<string>","payload":{}}
```

- O parse deve aceitar fallbacks ja suportados por `Channel.parseEvent(...)`:
  - `event` como nome
  - `data` como payload

### Parse defensivo (obrigatorio)

- Evento desconhecido: ignorar sem exception.
- Payload ausente: tratar como `{}`.
- Acesso a campos do payload: sempre defensivo (evitar assumir shape fixo).

## Regras de dependencia

### Pode depender

- `lib/core/...` (contratos, eventos, DTOs, tipos compartilhados).
- Mappers puros em `lib/rest/mappers/...` quando forem somente conversores `Json -> DTO` (ex.: `MessageMapper`).

### Nao pode depender

- `lib/ui/...` (widgets/presenters).
- `lib/rest/services/...` (nao misturar REST e realtime dentro de canais).
- `lib/drivers/...` para ler estado (token/env/cache).

### Vazamento de tipos de terceiros

- Tipos de `web_socket_channel` nao podem aparecer fora de `lib/websocket/wsc/`.

## Lifecycle e uso correto

### Conectar/desconectar

- O app conecta quando autenticado e com lifecycle ativo (ver [`lib/app.dart`](../../lib/app.dart)).
- URL atual de conexao (referencia em [`lib/app.dart`](../../lib/app.dart)):

```text
$webSocketBaseUrl/websocket/$ownerId?token=$accessToken
```

### Listen/unsubscribe

- Metodos `listen(...)` dos canais devem retornar `void Function()`.
- A UI/presenter deve sempre chamar `unsubscribe` no `dispose`.
- Exemplo aplicado: [`lib/ui/conversation/widgets/screens/inbox_screen/inbox_screen_presenter.dart`](../../lib/ui/conversation/widgets/screens/inbox_screen/inbox_screen_presenter.dart).

### Exemplos (referencias)

- Recebimento: `ConversationChannel.listen(...)` converte `payload` em `MessageDto` (ver [`lib/websocket/channels/conversation_channel.dart`](../../lib/websocket/channels/conversation_channel.dart)).
- Envio: `ConversationChannel.emitMessageSentEvent(...)` envia `{name, payload}` (ver [`lib/websocket/channels/conversation_channel.dart`](../../lib/websocket/channels/conversation_channel.dart)).

## Checklist para novas features

- Existe contrato no Core (interface/event name/DTO) antes de implementar em `lib/websocket/`.
- Canal implementa contrato do Core e expoe `listen(...) -> unsubscribe`.
- Provider do canal foi adicionado/atualizado em [`lib/websocket/channels.dart`](../../lib/websocket/channels.dart).
- Eventos desconhecidos nao quebram o stream (parse defensivo).
- Nenhum tipo de biblioteca externa vazou fora de `lib/websocket/wsc/`.

## Sinais de alerta

- Listener registrado em `build()` (gera multiplas inscricoes em rebuild).
- `unsubscribe` nao chamado no `dispose` (vazamento e duplicidade de updates).
- Canal importando `flutter/*` ou lendo `CacheDriver/EnvDriver`.
