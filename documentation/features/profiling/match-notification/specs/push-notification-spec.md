---
title: Integracao de Push Notification com OneSignal no fluxo de autenticacao
prd: documentation/features/profiling/match-notification/prd.md
status: concluido
last_updated_at: 2026-03-01
---

# 1. Objetivo

Implementar a base tecnica de `push notification` com `OneSignal` no `equiny_mobile`, garantindo que, apos autenticacao valida, o app execute **inicializacao do SDK**, **solicitacao de permissao de notificacao** e **vinculo do usuario via `OneSignal.login(ownerId)`**. A entrega deve seguir a arquitetura em camadas do projeto (Core/Drivers/UI), com orquestracao centralizada no ponto de sessao autenticada para evitar duplicidade de logica entre telas.

# 2. Escopo

## 2.1 In-scope
- Adicionar dependencia `onesignal_flutter` ao app Flutter.
- Criar contrato de infraestrutura para push em `core` e implementacao concreta em `drivers`.
- Inicializar OneSignal quando houver sessao autenticada valida (`accessToken` + `ownerId`).
- Solicitar permissao de push apenas apos onboarding concluido.
- Executar `OneSignal.login(ownerId)` apos autenticacao valida.
- Executar `OneSignal.logout()` ao encerrar sessao autenticada no app.
- Garantir idempotencia basica para nao repetir inicializacao/login desnecessariamente no mesmo `ownerId`.

## 2.2 Out-of-scope
- Criacao/edicao de templates de notificacao no painel OneSignal.
- Deep links a partir de notificacao clicada.
- Tratamento de foreground/click events na UI.
- Segmentacao por tags/aliases no OneSignal.
- Alteracoes de regras de negocio de match/chat.

# 3. Requisitos

## 3.1 Funcionais
- **RF-01**: Com usuario autenticado, o app deve inicializar o OneSignal com `appId` vindo de ambiente.
- **RF-02**: Com usuario autenticado e onboarding concluido, o app deve solicitar permissao de push via `OneSignal.Notifications.requestPermission(true)` (respeitando o estado de permissao para evitar prompt redundante).
- **RF-03**: Com `ownerId` disponivel, o app deve chamar `OneSignal.login(ownerId)`.
- **RF-04**: Ao perder autenticacao (logout/token invalido), o app deve chamar `OneSignal.logout()`.
- **RF-05**: O fluxo deve funcionar para `sign-in`, `sign-up` e reentrada com sessao persistida.

## 3.2 Nao funcionais
- **RNF-01**: A integracao nao deve adicionar dependencia direta do SDK OneSignal na camada `ui`.
- **RNF-02**: O contrato de push deve ficar isolado na camada `core` e implementado em `drivers`.
- **RNF-03**: A sincronizacao de sessao push deve ser resiliente a rebuilds de `App` (idempotente por `ownerId`).
- **RNF-04**: Falhas de permissao/login de push nao devem bloquear navegacao/autenticacao principal.

# 4. O que ja existe (inventario)

> Inclua apenas itens realmente relevantes para implementar a mudanca.

## 4.1 UI (`lib/ui/`)
- **`SignInScreenPresenter`** (`lib/ui/auth/widgets/screens/sign_in_screen/sign_in_screen_presenter.dart`) - ja persiste `accessToken` e `ownerId`, sendo um gatilho de sessao autenticada.
- **`SignUpScreenPresenter`** (`lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart`) - autentica apos cadastro, mas precisa alinhar persistencia de `ownerId` para o fluxo de push.
- **`ProfileScreenPresenter`** (`lib/ui/profiling/widgets/screens/profile_screen/profile_screen_presenter.dart`) - realiza logout; ponto relevante para encerrar sessao push.
- **`App` (`_AppState`)** (`lib/app.dart`) - centraliza sincronizacao de sessao (`auth`, `cache`, lifecycle); melhor ponto para orquestrar push.

## 4.2 Core (`lib/core/`)
- **`EnvKeys`** (`lib/core/shared/constants/env_keys.dart`) - concentra chaves de ambiente; faltando chave de `OneSignal App ID`.
- **`CacheKeys`** (`lib/core/shared/constants/cache_keys.dart`) - contem `ownerId` e `accessToken` usados no vinculo de usuario.
- **`EnvDriver`** (`lib/core/shared/interfaces/env_driver.dart`) - leitura de variaveis de ambiente para obter `OneSignal App ID`.

## 4.3 REST (`lib/rest/`)
- **`authServiceProvider` / `profilingServiceProvider`** (`lib/rest/services.dart`) - suportam o fluxo de autenticacao/recuperacao do owner sem necessidade de novo endpoint para esta entrega.

## 4.4 Drivers (`lib/drivers/`)
- **`DotEnvDriver`** (`lib/drivers/env-driver/dto-env/dot_env_driver.dart`) - resolve `appId` via `.env`.
- **`cacheDriverProvider`** (`lib/drivers/cache-driver/index.dart`) - fonte de `ownerId` e `accessToken` usados no binding do OneSignal.

# 5. O que deve ser criado

> Liste apenas arquivos novos. Para cada arquivo, detalhe assinatura, responsabilidade, dependencias e estado quando aplicavel.

## 5.1 UI

### 5.1.1 Presenters/Stores

Nenhum arquivo novo.

### 5.1.2 Views

Nenhum arquivo novo.

### 5.1.3 Widgets

Nenhum arquivo novo.

## 5.2 Core
- **Arquivo (novo):** `lib/core/shared/interfaces/push_notification_driver.dart`
  - **Tipo:** `interface`
  - **Contratos/assinaturas:**
    - `Future<bool> requestPermission({bool fallbackToSettings = true});`
    - `Future<void> register({required String ownerId});`
    - `Future<void> unregister();`
  - **Responsabilidade:** definir contrato agnostico para ciclo de vida de push (`requestPermission`, vinculo e desvinculo de usuario).

## 5.3 REST

Nenhum arquivo novo na camada REST.

## 5.4 Drivers
- **Arquivo (novo):** `lib/drivers/push-notification-driver/one-signal/one_signal_push_notification_driver.dart`
  - **Adapter/Driver:** implementacao de `PushNotificationDriver` usando `onesignal_flutter`.
  - **Responsabilidade:** encapsular chamadas do SDK (`OneSignal.initialize`, `OneSignal.Notifications.requestPermission`, `OneSignal.login`, `OneSignal.logout`) com idempotencia por sessao/owner.
  - **Dependencias:** `onesignal_flutter`, `lib/core/shared/interfaces/push_notification_driver.dart`.

- **Arquivo (novo):** `lib/drivers/push-notification-driver/index.dart`
  - **Adapter/Driver:** provider Riverpod da abstracao de push.
  - **Responsabilidade:** expor `pushNotificationDriverProvider` retornando `PushNotificationDriver`.
  - **Dependencias:** `flutter_riverpod`, `one_signal_push_notification_driver.dart`, interface do Core.

# 6. O que deve ser modificado

> Liste apenas arquivos existentes. Mudancas em arquivo novo ficam na secao 5.

- **Arquivo:** `pubspec.yaml`
  - **Mudanca:** adicionar dependencia `onesignal_flutter`.
  - **Justificativa:** habilitar SDK OneSignal no app Flutter.
  - **Camada:** `drivers`

- **Arquivo:** `.env`
  - **Mudanca:** adicionar chave `ONESIGNAL_APP_ID=<valor>`.
  - **Justificativa:** permitir inicializacao do SDK sem `hardcode`.
  - **Camada:** `drivers`

- **Arquivo:** `lib/core/shared/constants/env_keys.dart`
  - **Mudanca:** adicionar constante `oneSignalAppId` (ex.: `ONESIGNAL_APP_ID`).
  - **Justificativa:** padronizar acesso a variavel de ambiente.
  - **Camada:** `core`

- **Arquivo:** `lib/app.dart`
  - **Mudanca:** integrar sincronizacao de sessao push em paralelo ao ciclo de sessao websocket:
    - ler `PushNotificationDriver` e `EnvDriver`.
    - solicitar permissao (`requestPermission`) somente quando `CacheKeys.onboardingCompleted == 'true'`.
    - executar `register(ownerId)` quando `ownerId` mudar.
    - executar `unregister()` quando usuario deixar de estar autenticado.
    - acionar sincronizacao por `ref.listenManual(authStateProvider)` para evitar efeitos colaterais no `build`.
  - **Justificativa:** centralizar orquestracao no ponto unico de sessao evita duplicidade em presenters de auth.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart`
  - **Mudanca:** persistir `CacheKeys.ownerId` apos `fetchOwner()` (alinhado ao `sign-in`).
  - **Justificativa:** garantir que `ownerId` exista no primeiro ciclo autenticado apos cadastro, permitindo `OneSignal.login(ownerId)`.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_screen_presenter.dart`
  - **Mudanca:** limpar `CacheKeys.ownerId` no logout (alem de `accessToken`).
  - **Justificativa:** evitar identidade stale em reautenticacoes e simplificar sincronizacao de sessao push.
  - **Camada:** `ui`

# 7. O que deve ser removido

> Remocoes precisam ser seguras (sem quebrar fluxo, import ou contrato publico). Se houver substituicao, aponte o novo caminho.

Nenhuma remocao necessaria.

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)
```text
SignIn/SignUp -> Presenter -> Cache(ownerId/accessToken) -> authState
  -> App(_syncPushSession) -> PushNotificationDriver
  -> OneSignal SDK -> OneSignal Cloud/APNs-FCM
```

## 8.2 Layout/hierarquia visual (ASCII)
```text
App Session Layer
  |- Authenticated State Detected
  |- OS Push Permission Prompt (system modal)
  `- User returns to app flow (Feed/Onboarding)
```

## 8.3 Referencias internas
- `lib/app.dart` (orquestracao de sessao em nivel de app)
- `lib/ui/auth/widgets/screens/sign_in_screen/sign_in_screen_presenter.dart` (persistencia de owner autenticado)
- `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart` (fluxo de autenticacao via cadastro)
- `lib/drivers/cache-driver/index.dart` (padrao de provider para drivers)
- `lib/core/shared/interfaces/env_driver.dart` (contrato de leitura de ambiente)

## 8.4 Referencias de tela (quando houver)
- **Google Stitch screen id:** `nao se aplica`
- **Decisoes de UI extraidas:**
  - Sem nova tela no app.
  - Prompt de permissao e nativo do sistema operacional.

# 9. Perguntas em aberto

Sem perguntas em aberto no momento.

# 10. Consolidacao final (concluida)

## 10.1 Validacao de qualidade
- `dart format .` executado no projeto.
- `flutter analyze` executado sem issues remanescentes.
- `flutter test` executado com suite verde (`All tests passed!`).

## 10.2 Checklist de requisitos da spec
- **RF-01 (inicializacao com appId de ambiente):** atendido via `pushNotificationDriverProvider` + `EnvKeys.oneSignalAppId` e inicializacao lazy no driver.
- **RF-02 (permissao apos onboarding):** atendido em `lib/app.dart` ao condicionar `requestPermission()` com `CacheKeys.onboardingCompleted`.
- **RF-03 (vinculo por ownerId):** atendido por `register(ownerId)` com `OneSignal.login(ownerId)` e idempotencia por `_registeredOwnerId`.
- **RF-04 (logout push ao perder autenticacao):** atendido com `unregister()` no fluxo de sessao nao autenticada.
- **RF-05 (sign-in/sign-up/reentrada):** atendido por orquestracao central em `App` + persistencia de `ownerId` no `SignUpScreenPresenter`.
- **RNF-01/RNF-02:** atendidos (SDK isolado em `drivers`, contrato em `core`, sem dependencia de OneSignal na UI).
- **RNF-03:** atendido por controle de idempotencia (`_activePushOwnerId`, `_inFlightPushOwnerId`, `_initializeFuture`, `_registeredOwnerId`).
- **RNF-04:** atendido com tratamento de erro via `try/catch` e `debugPrint`, sem bloquear fluxo principal.

## 10.3 Diagrama ASCII atualizado
```ASCII
authState/cache change
  -> App._syncSessionsFromState()
     -> _syncWebSocketSession(...)
     -> _syncPushSession(...)
        -> if !authenticated or ownerId vazio
             -> PushNotificationDriver.unregister()
        -> else
             -> if onboardingCompleted: requestPermission()
             -> register(ownerId)
                 -> OneSignal.initialize(appId) [lazy/idempotente]
                 -> OneSignal.login(ownerId)
```

