---
title: Modal full-screen "Deu match!"
prd: documentation/features/profiling/match-notification/prd.md
status: concluido
last_updated_at: 2026-02-28
---

# 1. Objetivo

Implementar uma **modal full-screen** exibida automaticamente sempre que o usuario logado receber um evento de match via WebSocket (`profiling/horse.match.notified`). A modal apresenta titulo "Deu match!", subtitulo com o nome do cavalo correspondente, foto do cavalo com anel decorativo e icone de coracao, e dois CTAs: **"Ir para o chat"** (cria o chat via API e navega) e **"Continuar deslizando"** (fecha a modal). A modal deve funcionar sobre qualquer tela do app enquanto em foreground, suportar fila de multiplos matches e incluir animacao de confete.

# 2. Escopo

## 2.1 In-scope
- Exibicao automatica da modal ao receber `HorseMatchNotifiedEvent` via WebSocket (foreground).
- Fila sequencial de matches (exibe um por vez, sem limite).
- CTA "Ir para o chat": cria chat via `ConversationService.createChat`, navega para `Routes.chat`.
- CTA "Continuar deslizando" / icone X / swipe-down: fecha a modal e retorna ao contexto anterior.
- Animacao: fade-in da modal + efeito confete via `Lottie` (`assets/lotties/confetti.json`).
- Integracao do `HorseMatchNotifiedEvent` no `ProfilingChannel` concreto (WebSocket).
- Listener global no `App` para escutar eventos de match e disparar a modal.

## 2.2 Out-of-scope
- Push notifications e deep links.
- Deduplicacao por `matchId` (aceito reexibicao no MVP).
- Exibicao de matches pendentes ao retornar do background (resumed) via REST.
- Telemetria/analytics.
- Alteracoes no algoritmo de match ou envio/recebimento de mensagens.

# 3. Requisitos

## 3.1 Funcionais
- **RF-01**: Ao receber evento `profiling/horse.match.notified`, exibir a modal imediatamente se o app estiver em foreground.
- **RF-02**: A modal deve ser full-screen, bloqueando interacao com a tela anterior.
- **RF-03**: Exibir titulo "Deu match!", subtitulo "Voce e {ownerHorseName} curtiram um ao outro.", foto do cavalo (`ownerHorseImage`) com anel circular roxo e icone de coracao.
- **RF-04**: Se nao houver foto, usar placeholder padrao.
- **RF-05**: CTA "Ir para o chat" chama `ConversationService.createChat` com `senderId` (do cache) e `recipientId` (do DTO), navega para `/chat` com o `chatId` retornado.
- **RF-06**: Durante loading do CTA, o botao exibe spinner e fica desabilitado. Timeout de 8 segundos, exibindo mensagem de erro em caso de falha.
- **RF-07**: CTA "Continuar deslizando", icone X (canto superior direito) e swipe-down fecham a modal.
- **RF-08**: Se houver multiplos matches na fila, ao fechar um, exibir o proximo sem retornar ao contexto anterior.
- **RF-09**: Animacao de confete ao exibir a modal.

## 3.2 Nao funcionais
- **RNF-01**: A modal nao deve interferir com o ciclo de vida do WebSocket gerenciado pelo `App`.
- **RNF-02**: O presenter da modal deve ser `autoDispose` para evitar leaks.
- **RNF-03**: Contraste e legibilidade adequados; botoes com area minima de toque.

# 4. O que ja existe (inventario)

## 4.1 UI (`lib/ui/`)
- **`MatchesScreenPresenter`** (`lib/ui/matches/widgets/screens/matches_screen/matches_screen_presenter.dart`) — contem logica de `createChat` + navegacao para `/chat` que sera referencia para o CTA "Ir para o chat".
- **`MatchOptionDialogView`** (`lib/ui/matches/widgets/screens/matches_screen/match_option_dialog/match_option_dialog_view.dart`) — exemplo de modal bottom sheet com avatar, pode servir de referencia visual.
- **`AppTheme` / `AppThemeColors`** (`lib/ui/shared/theme/app_theme.dart`) — cores `primary` (#B79BFF), `primaryDark` (#9775EA), `background` (#0B0B0D), `textMain`, `textSecondary`, spacing e radii.
- **`TabNavigationView`** (`lib/shared/widgets/components/tab_navigation/tab_navigation_view.dart`) — shell de navegacao, contexto sobre o qual a modal sera exibida.

## 4.2 Core (`lib/core/`)
- **`HorseMatchNotifiedEvent`** (`lib/core/profiling/events/horse_match_notified_event.dart`) — evento com payload `HorseMatchDto`, nome `'profiling/horse.match.notified'`.
- **`HorseMatchDto`** (`lib/core/profiling/dtos/structures/horse_match_dto.dart`) — DTO com `ownerId`, `ownerName`, `ownerHorseId`, `ownerHorseName`, `ownerHorseImage` (`ImageDto?`), `ownerAvatar` (`ImageDto?`), `ownerLocation`, `isViewed`, `createdAt`.
- **`ImageDto`** (`lib/core/profiling/dtos/structures/image_dto.dart`) — DTO com `key` e `name`.
- **`ProfilingChannel` (interface)** (`lib/core/profiling/interfaces/profiling_channel.dart`) — ja declara callback `onHorseMatchNotified` no metodo `listen`.
- **`ConversationService` (interface)** (`lib/core/conversation/interfaces/conversation_service.dart`) — `createChat(recipientId, senderId, recipientHorseId, senderHorseId)`.
- **`NavigationDriver` (interface)** (`lib/core/shared/interfaces/navigation_driver.dart`) — `goTo(route, {data})`, `goBack()`.
- **`Routes`** (`lib/core/shared/constants/routes.dart`) — constantes de rotas: `Routes.chat`, `Routes.feed`, etc.
- **`CacheKeys`** (`lib/core/shared/constants/cache_keys.dart`) — `CacheKeys.ownerId` para obter o `senderId`.

## 4.3 REST (`lib/rest/`)
- **`conversationServiceProvider`** (`lib/rest/services.dart`) — provider do `ConversationService`.
- **`profilingServiceProvider`** (`lib/rest/services.dart`) — provider do `ProfilingService`.

## 4.4 Drivers (`lib/drivers/`)
- **`fileStorageDriverProvider`** (`lib/drivers/file-storage-driver/index.dart`) — resolve URL de imagem via `getFileUrl(key)`.
- **`cacheDriverProvider`** (`lib/drivers/cache-driver/index.dart`) — acesso a `CacheKeys.ownerId`.
- **`navigationDriverProvider`** (`lib/drivers/navigation-driver/index.dart`) — provider do `NavigationDriver`.

## 4.5 WebSocket (`lib/websocket/`)
- **`ProfilingChannel` (concreto)** (`lib/websocket/channels/profiling_channel.dart`) — implementa `Channel`, **nao** trata `HorseMatchNotifiedEvent` ainda.
- **`Channel` (base)** (`lib/websocket/channels/channel.dart`) — `parseEvent(data)` retorna `(name, payload)`.
- **`profilingChannelProvider`** (`lib/websocket/channels.dart`) — provider do canal.

## 4.6 App (`lib/app.dart`)
- **`_AppState`** — `ConsumerState` com `WidgetsBindingObserver`, gerencia ciclo de vida do WebSocket. Ponto de integracao para listener global de matches.

# 5. O que deve ser criado

## 5.1 UI

### 5.1.1 Presenters

- **Arquivo:** `lib/ui/profiling/match_notification/widgets/screens/match_notification_modal/match_notification_modal_presenter.dart`
  - **Responsabilidade:** Gerenciar estado da modal: fila de matches, loading do CTA, erro, navegacao para chat.
  - **Dependencias:** `ConversationService`, `NavigationDriver`, `CacheDriver`, `FileStorageDriver`.
  - **Estado (`signals`):**
    - `queue` (`Signal<List<HorseMatchDto>>`) — fila de matches pendentes.
    - `isCreatingChat` (`Signal<bool>`) — loading do CTA "Ir para o chat".
    - `chatError` (`Signal<String?>`) — mensagem de erro ao criar chat.
  - **Computeds:**
    - `currentMatch` (`ReadonlySignal<HorseMatchDto?>`) — primeiro item da fila.
    - `hasNext` (`ReadonlySignal<bool>`) — se ha proximo match na fila.
    - `horseImageUrl` (`ReadonlySignal<String?>`) — URL resolvida da foto do cavalo do match atual.
  - **Metodos:**
    - `enqueue(HorseMatchDto match)` — adiciona match ao fim da fila.
    - `Future<void> handleGoToChat()` — cria chat via `ConversationService.createChat` (com timeout de 8s), navega para `Routes.chat` com `chatId`. Em caso de falha, seta `chatError`.
    - `void handleContinue()` — remove o match atual da fila. Se fila vazia, fecha a modal (via callback).
    - `void handleClose()` — mesma acao de `handleContinue()`.
  - **Provider:** `matchNotificationModalPresenterProvider` (`Provider.autoDispose`).

### 5.1.2 Views

- **Arquivo:** `lib/ui/profiling/match_notification/widgets/screens/match_notification_modal/match_notification_modal_view.dart`
  - **Responsabilidade:** Renderizar a modal full-screen com titulo, subtitulo, foto do cavalo com anel, CTAs e animacao de confete.
  - **Props:** Nenhuma (usa presenter via Riverpod).
  - **Dependencias de UI:** `shadcn_flutter`, `flutter_animate`, `lottie` (confete via `assets/lotties/confetti.json`), `AppThemeColors`, `AppFontSize`, `AppSpacing`.
  - **Comportamento:**
    - Fundo: `AppThemeColors.background` com opacidade ou gradiente escuro.
    - Titulo: "Deu match!" em `AppFontSize.xxxxl`, bold, `AppThemeColors.textMain`.
    - Subtitulo: "Voce e {ownerHorseName} curtiram um ao outro." em `AppFontSize.md`, `AppThemeColors.textSecondary`.
    - Foto do cavalo: `CircleAvatar` grande com borda/anel em gradiente roxo (`AppThemeColors.primary` / `AppThemeColors.primaryDark`). Icone de coracao sobreposto (canto inferior esquerdo).
    - Botao primario: "Ir para o chat" com icone de chat, cor `AppThemeColors.primary`. Loading state com spinner + desabilitado.
    - Botao secundario: "Continuar deslizando" com borda, estilo outline.
    - Icone X no canto superior direito.
    - Swipe-down via `GestureDetector` ou `Dismissible` para fechar.
    - Animacao de confete: overlay via `Lottie` com asset `assets/lotties/confetti.json`.
    - Transicao entre matches da fila: fade curto.

- **Arquivo:** `lib/ui/profiling/match_notification/widgets/screens/match_notification_modal/index.dart`
  - **Responsabilidade:** Barrel export.
  - **Conteudo:** `typedef MatchNotificationModal = MatchNotificationModalView;`

### 5.1.3 Widgets internos

- **Pasta:** `lib/ui/profiling/match_notification/widgets/screens/match_notification_modal/match_horse_avatar/`
  - **Responsabilidade:** Widget do avatar circular do cavalo com anel decorativo roxo e icone de coracao.
  - **Props:** `String? imageUrl`, `double size`.
  - **Arquivos:**
    - `match_horse_avatar_view.dart` — renderiza `Container` circular com borda gradiente, `Image.network` com fallback placeholder, icone de coracao posicionado.
    - `index.dart` — barrel export.

- **Pasta:** `lib/ui/profiling/match_notification/widgets/screens/match_notification_modal/confetti_overlay/`
  - **Responsabilidade:** Overlay de animacao de confete exibido ao abrir a modal.
  - **Props:** nenhuma.
  - **Arquivos:**
    - `confetti_overlay_view.dart` — widget com animacao de confete via `Lottie` usando asset `assets/lotties/confetti.json`.
    - `index.dart` — barrel export.

- **Estrutura de pastas (ASCII):**
```text
lib/ui/profiling/match_notification/
  widgets/
    screens/
      match_notification_modal/
        match_notification_modal_view.dart
        match_notification_modal_presenter.dart
        index.dart
        match_horse_avatar/
          match_horse_avatar_view.dart
          index.dart
        confetti_overlay/
          confetti_overlay_view.dart
          index.dart
```

## 5.2 Core

Nenhum arquivo novo necessario. Os DTOs, eventos e interfaces ja existem.

## 5.3 REST

Nenhum arquivo novo necessario. O `ConversationService.createChat` ja existe.

## 5.4 Drivers

Nenhum arquivo novo necessario.

# 6. O que deve ser modificado

- **Arquivo:** `lib/websocket/channels/profiling_channel.dart`
  - **Mudanca:** Adicionar tratamento do evento `HorseMatchNotifiedEvent.name` (`'profiling/horse.match.notified'`) no `switch` do metodo `listen`. Parsear o payload para criar `HorseMatchDto` e invocar o callback `onHorseMatchNotified`.
  - **Justificativa:** A interface `ProfilingChannel` ja declara o callback `onHorseMatchNotified`, mas a implementacao concreta nao trata o evento.
  - **Camada:** `websocket`
  - **Detalhes:**
    - Adicionar `import` de `HorseMatchNotifiedEvent`, `HorseMatchDto` e `HorseMatchMapper`.
    - Adicionar parametro `required void Function(HorseMatchNotifiedEvent event) onHorseMatchNotified` na assinatura de `listen`.
    - No `switch`, adicionar `case HorseMatchNotifiedEvent.name:` que converte `payload` em `HorseMatchDto` usando `HorseMatchMapper.toDto(payload)` (ja existente em `lib/rest/mappers/profiling/horse_match_mapper.dart`) e chama `onHorseMatchNotified(HorseMatchNotifiedEvent(horseMatch: dto))`.

- **Arquivo:** `lib/app.dart`
  - **Mudanca:** Adicionar listener global do `ProfilingChannel` para escutar `onHorseMatchNotified` e exibir a modal full-screen. Gerenciar a fila de matches e o lifecycle do listener.
  - **Justificativa:** A modal deve ser exibida sobre qualquer tela do app. O `App` e o ponto mais alto da arvore de widgets com acesso ao `BuildContext` de navegacao e aos providers.
  - **Camada:** `ui` (raiz)
  - **Detalhes:**
    - Ao conectar o WebSocket com sucesso (apos `_connectAndNotifyOwnerEntered`), registrar listener via `profilingChannel.listen(onHorseMatchNotified: _handleMatchNotified, ...)`.
    - Armazenar o `unsubscribe` retornado para cancelar ao desconectar.
    - `_handleMatchNotified(HorseMatchNotifiedEvent event)`:
      - Se a modal ja esta visivel, usar o presenter para enfileirar (`enqueue`).
      - Se nao, abrir a modal via `showGeneralDialog` (full-screen, `barrierDismissible: false`, fundo escuro) passando o `HorseMatchDto` inicial.
    - Usar `GlobalKey<NavigatorState>` ou `navigatorKey` do `GoRouter` para exibir a modal independente da rota atual.

- **Arquivo:** `lib/core/conversation/interfaces/conversation_service.dart`
  - **Mudanca:** Simplificar assinatura de `createChat` removendo `recipientHorseId` e `senderHorseId`, mantendo apenas `recipientId` e `senderId`.
  - **Justificativa:** Conforme definido pelo usuario, apenas `sender_id` e `recipient_id` sao necessarios.
  - **Camada:** `core`

- **Arquivo:** `lib/rest/services/conversation_service.dart`
  - **Mudanca:** Atualizar implementacao de `createChat` para refletir a nova assinatura (remover `recipientHorseId` e `senderHorseId` do body da requisicao).
  - **Justificativa:** Alinhamento com a mudanca na interface.
  - **Camada:** `rest`

- **Arquivo:** `lib/ui/matches/widgets/screens/matches_screen/matches_screen_presenter.dart`
  - **Mudanca:** Atualizar chamada a `_conversationService.createChat` no metodo `handleTapSendMessage` para usar a nova assinatura (sem `recipientHorseId` e `senderHorseId`).
  - **Justificativa:** Ajuste necessario apos simplificacao da interface `ConversationService.createChat`.
  - **Camada:** `ui`

# 7. O que deve ser removido

Nenhuma remocao necessaria.

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)

```text
WebSocket Server
  |
  | evento: profiling/horse.match.notified (JSON)
  v
WscWebSocketClient.onData()
  |
  v
ProfilingChannel.listen() -> parseEvent() -> switch -> onHorseMatchNotified(HorseMatchNotifiedEvent)
  |
  v
App._handleMatchNotified(event)
  |
  |-- modal NAO visivel? -> showGeneralDialog(MatchNotificationModal) com match inicial
  |-- modal JA visivel?  -> presenter.enqueue(match)
  v
MatchNotificationModalPresenter
  |
  |-- handleGoToChat()
  |     |-> CacheDriver.get(CacheKeys.ownerId)  // senderId
  |     |-> ConversationService.createChat(senderId, recipientId)
  |     |-> NavigationDriver.goTo(Routes.chat, data: chatId)
  |     `-> Navigator.pop() // fecha modal
  |
  `-- handleContinue() / handleClose()
        |-> remove match da fila
        |-- fila vazia? -> Navigator.pop() // fecha modal
        `-- fila nao vazia? -> atualiza currentMatch (proximo da fila)
```

## 8.2 Layout/hierarquia visual (ASCII)

```text
MatchNotificationModal (full-screen, fundo escuro)
  |
  |- ConfettiOverlay (animacao, ignorePointer)
  |
  |- CloseButton (icone X, canto superior direito)
  |
  |- Column (center)
  |   |- Text "Deu match!" (titulo, bold, branco, xxxl)
  |   |- SizedBox (spacing sm)
  |   |- Text "Voce e {name} curtiram um ao outro." (subtitulo, secondary)
  |   |- SizedBox (spacing xl)
  |   |- MatchHorseAvatar
  |   |   |- Container (circular, borda gradiente primary/primaryDark)
  |   |   |- Image.network (foto do cavalo) ou placeholder
  |   |   `- Positioned (coracao, inferior esquerdo)
  |   |       `- CircleAvatar (icone coracao roxo)
  |   |- SizedBox (spacing xxl)
  |   |- ElevatedButton "Ir para o chat" (primario, icone chat, loading state)
  |   |- SizedBox (spacing md)
  |   `- OutlinedButton "Continuar deslizando" (secundario)
```

## 8.3 Referencias internas
- `lib/ui/matches/widgets/screens/matches_screen/matches_screen_presenter.dart` — logica de `createChat` + navegacao (metodo `handleTapSendMessage`) usada como referencia.
- `lib/ui/matches/widgets/screens/matches_screen/match_option_dialog/match_option_dialog_view.dart` — referencia de modal com avatar.
- `lib/ui/matches/widgets/screens/matches_screen/new_matches_list/new_matches_list_item/new_matches_list_item_view.dart` — referencia de como resolver URL de imagem via `fileStorageDriver.getFileUrl(key)`.
- `lib/app.dart` — ponto de integracao para listener global.

## 8.4 Referencias de tela (quando houver)
- **Screenshot de referencia:** `.cp-images/pasted-image-2026-02-28T15-20-26-060Z.png`
- **Decisoes de UI extraidas:**
  - Fundo: escuro solido (`AppThemeColors.background` ou variante com leve gradiente).
  - Titulo "Deu match!" em branco, bold, fonte grande.
  - Subtitulo em cor secundaria, fonte media.
  - Foto do cavalo em circulo grande com anel roxo duplo (borda interna mais clara, externa com glow sutil).
  - Icone de coracao em circulo escuro, posicionado no canto inferior esquerdo do avatar.
  - Botao primario roxo com bordas arredondadas.
  - Botao secundario com borda, estilo outline/ghost.
  - Sparkles/particulas douradas sutis ao redor da foto (confete).

# 9. Decisoes de Design Finais

## 9.1 Perguntas resolvidas

- **Confete**: Implementado com `Lottie` via asset `assets/lotties/confetti.json`. `ConfettiOverlayView` usa `SizedBox.expand()` (em vez de `Positioned.fill`) dentro do `IgnorePointer` para garantir compatibilidade como filho de Stack nao-posicionado.
- **Payload do WebSocket**: Parsing via `HorseMatchMapper.toDto(payload['horse_match'])` no `ProfilingChannel` concreto. Campos em snake_case conforme padrao da API.
- **Idempotencia do chat**: Solucao adotada — `handleGoToChat` chama `fetchChat` primeiro; se falhar, faz fallback para `createChat`. Assinatura simplificada: ambos recebem apenas `{required String recipientId}`.

## 9.2 Decisoes de implementacao

- **`matchNotificationModalPresenterProvider` nao-autoDispose**: A spec sugeria `autoDispose`, mas a implementacao adotou `Provider` nao-autoDispose + `ref.invalidate` ao fechar o dialog. Motivacao: `ref.read` em `app.dart` nao adiciona listener persistente; o autoDispose poderia descartar o provider entre o enqueue e o primeiro `ref.watch` do dialog. O `ref.invalidate` no `whenComplete` garante limpeza equivalente sem risco de race condition.
- **Componentes Material em vez de shadcn_flutter**: O codebase nao adota shadcn_flutter na pratica (nenhum arquivo `lib/ui/**` importa o pacote). A modal usa `ElevatedButton.icon`, `OutlinedButton`, `Scaffold` e `IconButton` consistentemente com o resto do projeto.
- **Swipe-down via `GestureDetector`**: `onVerticalDragEnd` com limiar de 240 px/s. Nao usa `Dismissible` para manter controle total sobre a logica de fila (nao fechar se ainda houver items).
- **Transicao entre matches**: `AnimatedSwitcher` com `ValueKey` composto (`ownerId + ownerHorseId + createdAt`) garante rebuild correto ao trocar de item na fila.
