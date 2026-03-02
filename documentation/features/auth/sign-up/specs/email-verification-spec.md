---
title: Confirmacao de envio de email no Sign Up
prd: documentation/features/auth/sign-up/prd.md
status: concluido
last_updated_at: 2026-03-01
---

# 1. Objetivo
Entregar o fluxo de pos-cadastro do `Sign Up` orientado a verificacao de email: apos `signUp` com sucesso, a tela deve informar claramente que um email de verificacao foi enviado e direcionar o usuario para `Sign In`, removendo do `SignUpScreenPresenter` a dependencia de `WebSocket` (`OwnerCreatedEvent`) e a consulta `fetchOwner`, para manter a responsabilidade do cadastro restrita a criacao de conta.

# 2. Escopo

## 2.1 In-scope
- Ajustar o `SignUpScreenPresenter` para encerrar o fluxo em estado de sucesso de verificacao de email, sem autenticar sessao.
- Exibir mensagem de sucesso na tela de cadastro apos resposta `success` do endpoint `POST /auth/sign-up`.
- Direcionar usuario para `Routes.signIn` apos confirmacao explicita (CTA) no estado de sucesso.
- Remover do fluxo de `Sign Up` o listener de `ProfilingChannel` e a chamada `ProfilingService.fetchOwner()`.
- Alinhar contrato REST de `signUp` para retorno de dados de conta (sem uso de `accessToken` no cadastro).

## 2.2 Out-of-scope
- Alterar layout estrutural da tela de `Sign Up` (header, campos e footer existentes).
- Implementar reenvio de email de verificacao.
- Alterar fluxo de `Sign In` alem de receber navegacao de retorno.
- Alterar regras de onboarding e inicializacao de sessao websocket no `App`.

# 3. Requisitos

## 3.1 Funcionais
- Quando `AuthService.signUp(...)` retornar sucesso, o presenter deve:
- limpar `generalError`;
- marcar estado de sucesso de verificacao (`emailVerificationSent`);
- nao salvar `CacheKeys.accessToken`, `CacheKeys.ownerId` ou `CacheKeys.onboardingCompleted`;
- nao chamar `AuthStateNotifier.setAuthenticated(true)`.
- O estado de sucesso deve apresentar copy orientativa de verificacao de email e CTA para ir a `Sign In`.
- O usuario deve conseguir navegar para `Routes.signIn` a partir da propria tela apos sucesso.
- Em falha de API, manter tratamento atual de erros de campo (`email`) e erro geral.

## 3.2 Nao funcionais
- Manter padrao `MVP`: regra de negocio no presenter, `View` apenas renderiza estado.
- Manter fluxo de dados em camadas: `View -> Presenter -> Provider -> Service -> RestClient -> API`.
- Evitar regressao nos consumers de realtime (`App`, `Inbox`, `Chat`) ao remover dependencia websocket somente do `Sign Up`.
- Seguir convencoes de nomenclatura e organizacao do projeto (`snake_case`, `index.dart`, imports por camada).

# 4. O que ja existe (inventario)

> Inclui apenas itens relevantes para implementar a mudanca.

## 4.1 UI (`lib/ui/`)
- **`SignUpScreenPresenter`** (`lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart`) - hoje mistura cadastro com autenticacao/sessao e fluxo realtime; sera simplificado para verificacao de email.
- **`SignUpScreenView`** (`lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_view.dart`) - renderiza estados de erro/loading e composicao com `sign_up_header`, `sign_up_form`, `sign_up_footer`.
- **`SignUpFormView`** (`lib/ui/auth/widgets/screens/sign_up_screen/sign_up_form/sign_up_form_view.dart`) - formulario de cadastro com validacoes client-side.

## 4.2 Core (`lib/core/`)
- **`AuthService`** (`lib/core/auth/interfaces/auth_service.dart`) - contrato de autenticacao com `signUp`.
- **`AccountDto`** (`lib/core/auth/dtos/account_dto.dart`) - DTO de conta que representa dados de cadastro sem sessao.
- **`Routes`** (`lib/core/shared/constants/routes.dart`) - rota `signIn` usada no redirecionamento.
- **`CacheKeys`** (`lib/core/shared/constants/cache_keys.dart`) - chaves de sessao que nao devem ser persistidas no fluxo de verificacao.

## 4.3 REST (`lib/rest/`)
- **`AuthService`** (`lib/rest/services/auth_service.dart`) - implementacao do `POST /auth/sign-up` atualmente acoplada ao retorno de `JwtDto`.
- **`JwtMapper`** (`lib/rest/mappers/auth/jwt_mapper.dart`) - mapper existente para `signIn`; nao deve ser reutilizado para `signUp` orientado a verificacao de email.

## 4.4 Drivers (`lib/drivers/`)
- **`GoRouterNavigationDriver`** (`lib/drivers/navigation-driver/go-router/go_router_navigation_driver.dart`) - adapter de navegacao ja usado pelo presenter.
- **`SharedPreferencesCacheDriver`** (`lib/drivers/cache-driver/shared-prefences/shared_preferences_cache_driver.dart`) - permanece disponivel, sem escrita de sessao no fluxo de `Sign Up`.

# 5. O que deve ser criado

> Apenas arquivos novos necessarios para manter o fluxo claro e sem duplicacao de responsabilidade.

## 5.1 UI

### 5.1.1 Presenters/Stores
- Nenhum arquivo novo.

### 5.1.2 Views
- Nenhum arquivo novo de screen.

### 5.1.3 Widgets
- **Arquivo/Pasta:** `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_verification_notice/` (**novo arquivo**)
  - **Responsabilidade:** exibir estado de sucesso apos cadastro com copy de verificacao de email e CTA para `Sign In`.
  - **Props:** `email`, `onTapGoToSignIn`, `isLoading` (se aplicavel ao CTA).
  - **Widgets internos:** nenhum.
  - **Estrutura de pastas (ASCII):**
```text
sign_up_verification_notice/
  index.dart
  sign_up_verification_notice_view.dart
```

## 5.2 Core
- Nenhum arquivo novo.

## 5.3 REST
- **Arquivo:** `lib/rest/mappers/auth/account_mapper.dart` (**novo arquivo**)
  - **Service/Client:** usado por `lib/rest/services/auth_service.dart` no metodo `signUp`.
  - **Metodos:** `static AccountDto toDto(Json body)`.
  - **Entrada/Saida:** `Json` de resposta de cadastro -> `AccountDto`.

## 5.4 Drivers
- Nenhum arquivo novo.

# 6. O que deve ser modificado

> Mudancas em arquivos existentes; arquivos novos permanecem na secao 5.

- **Arquivo:** `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart`
  - **Mudanca:** remover dependencia de `ProfilingChannel` e `ProfilingService`; remover `_waitForOwnerCreated`, `dispose` de listener e escrita de cache/autenticacao apos `signUp`; adicionar estado de sucesso (`emailVerificationSent` + `registeredEmail`) e acao dedicada para ir a `Sign In`.
  - **Justificativa:** restringir responsabilidade do `Sign Up` ao cadastro e confirmacao de verificacao de email.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_view.dart`
  - **Mudanca:** renderizar estado de sucesso com `SignUpVerificationNotice` quando `emailVerificationSent == true`; ocultar formulario nesse estado.
  - **Justificativa:** evitar ambiguidades de UX apos sucesso e guiar o usuario para o proximo passo correto (`Sign In`).
  - **Camada:** `ui`

- **Arquivo:** `lib/rest/services/auth_service.dart`
  - **Mudanca:** ajustar retorno de `signUp` para `RestResponse<AccountDto>` e mapear payload com `AccountMapper` (sem `JwtMapper` neste fluxo).
  - **Justificativa:** fluxo de verificacao de email nao cria sessao autenticada no cadastro.
  - **Camada:** `rest`

- **Arquivo:** `lib/core/auth/interfaces/auth_service.dart`
  - **Mudanca:** confirmar/alinhar assinatura de `signUp` para `Future<RestResponse<AccountDto>>` com a implementacao REST.
  - **Justificativa:** manter contrato Core consistente com o comportamento esperado da API no cadastro.
  - **Camada:** `core`

- **Arquivo:** `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_form/sign_up_form_view.dart`
  - **Mudanca:** opcionalmente receber prop `isSuccess` para desabilitar submit caso o estado de verificacao ja esteja ativo (se o formulario continuar montado).
  - **Justificativa:** prevencao de reenvio acidental de cadastro no mesmo ciclo de tela.
  - **Camada:** `ui`

# 7. O que deve ser removido

> Remocoes seguras, sem quebrar contratos publicos.

- **Arquivo:** `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart`
  - **Remocao:** metodo privado `_waitForOwnerCreated`, estado `_unsubscribeOwnerCreated`, constante `_ownerCreatedTimeout` e imports de `OwnerCreatedEvent`, `ProfilingChannel`, `ProfilingService`, `websocket/channels.dart` e `auth_state_provider.dart` (quando nao mais usados).
  - **Motivo:** remover acoplamento de realtime/fetchOwner no cadastro.
  - **Substituir por (se aplicavel):** estado local de sucesso de verificacao (`emailVerificationSent`) no proprio presenter.

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)
```text
SignUpScreenView
  -> SignUpScreenPresenter
    -> AuthService.signUp
      -> RestClient
        -> API (/auth/sign-up)
    <- RestResponse<AccountDto>
    -> estado local emailVerificationSent=true
    -> NavigationDriver.goTo(Routes.signIn) [acao do usuario]
```

## 8.2 Layout/hierarquia visual (ASCII)
```text
SignUpScreen
  |- Header
  |- Content
  |   |- Form (estado inicial)
  |   `- Verification Notice (estado sucesso)
  `- Footer CTA
```

## 8.3 Referencias internas
- `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart`
- `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_view.dart`
- `lib/ui/auth/widgets/screens/sign_in_screen/sign_in_screen_presenter.dart`
- `lib/core/auth/interfaces/auth_service.dart`
- `lib/core/auth/dtos/account_dto.dart`
- `lib/rest/services/auth_service.dart`
- `lib/rest/mappers/auth/jwt_mapper.dart`

## 8.4 Referencias de tela (quando houver)
- **Google Stitch screen id:** `nao informado`
- **Decisoes de UI extraidas:**
- Manter composicao visual atual da tela de cadastro.
- Introduzir apenas estado de confirmacao de verificacao sem refatorar tema/layout global.

# 9. Perguntas em aberto
- Sem pendencias.
- Decisoes fechadas:
- `POST /auth/sign-up` retorna dados de conta sem sessao autenticada; o fluxo usa `AccountDto` e nao persiste token no cadastro.
- A navegacao para `Sign In` ocorre apenas por CTA manual no estado de sucesso (sem redirecionamento automatico por tempo).

# 10. Consolidacao da entrega

## 10.1 Checklist de requisitos da spec
- `SignUpScreenPresenter` finaliza em `emailVerificationSent=true`, sem autenticar sessao e sem persistir `CacheKeys` de token/owner/onboarding.
- `SignUpScreenView` renderiza estado dedicado de sucesso (`SignUpVerificationNotice`) e oculta formulario/footer de cadastro nesse estado.
- CTA de sucesso direciona explicitamente para `Routes.signIn` via `goToSignIn`.
- Dependencias de realtime/profiling foram removidas do fluxo de cadastro (sem listener de `OwnerCreatedEvent` e sem `fetchOwner`).
- `AuthService.signUp` na camada REST retorna `RestResponse<AccountDto>` com mapeamento por `AccountMapper` (sem `JwtMapper` no cadastro).

## 10.2 Validacao final (quality gates)
- `dart format .` executado com sucesso.
- `flutter analyze` executado sem warnings/erros.
- `flutter test` executado com sucesso (`All tests passed!`).

## 10.3 Diagrama ASCII final (sequencia)
```ASCII
Usuario
  -> SignUpFormView: envia cadastro
SignUpFormView
  -> SignUpScreenPresenter.submit()
SignUpScreenPresenter
  -> AuthService.signUp(owner_name, account_email, account_password)
AuthService (REST)
  -> POST /auth/sign-up
API
  -> RestResponse<AccountDto>
SignUpScreenPresenter
  -> emailVerificationSent = true
  -> registeredEmail = account.email
SignUpScreenView
  -> exibe SignUpVerificationNotice
Usuario
  -> CTA "Ir para login"
SignUpScreenPresenter
  -> NavigationDriver.goTo(Routes.signIn)
```
