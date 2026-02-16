---
title: Tela de Sign In
status: concluido
last_updated_at: 2026-02-16
---

# 1. Objetivo
Implementar a tela de `Sign In` do Equiny com formulario validado, integracao real ao endpoint `POST /auth/sign-in`, persistencia da sessao e redirecionamento automatico para `Routes.onboarding` ou `Routes.home` conforme status de onboarding do owner, mantendo o padrao `MVP + Riverpod + Signals` e reaproveitando componentes ja existentes de autenticacao.

# 2. Escopo

## 2.1 In-scope
- Criacao da tela `sign_in_screen` com `View` + `Presenter` + formulario dedicado.
- Integracao do fluxo de login com `AuthService.signIn` na camada `rest`.
- Persistencia de `CacheKeys.accessToken` e `CacheKeys.onboardingCompleted` apos sucesso.
- Redirecionamento pos-login com base em `ProfilingService.fetchOwner()`.
- Substituicao da rota placeholder de `Routes.signIn` no `GoRouter`.
- Reuso dos componentes de cabecalho/rodape ja existentes para evitar duplicacao visual.

## 2.2 Out-of-scope
- Recuperacao de senha (`forgot password`).
- Login social (`Google`, `Apple`) e MFA.
- Alteracao de contratos de dominio alem do necessario para login.
- Refatoracao ampla de tema ou design system fora do fluxo de `auth`.

# 3. Requisitos

## 3.1 Funcionais
- Permitir autenticacao com `email` + `password`.
- Validar email e senha antes de enviar (`required`, `email`, limites minimos de tamanho).
- Permitir `toggle` de visibilidade da senha.
- Exibir estado de carregamento e bloquear multiplos submits.
- Exibir erro generico para credenciais invalidas e erro geral para falhas de rede/servidor.
- Mapear campos do formulario para payload da API conforme contrato `BodySchema` (`email`, `password`).
- Salvar token em cache e decidir destino pos-login:
  - `hasCompletedOnboarding = false` -> `Routes.onboarding`
  - `hasCompletedOnboarding = true` -> `Routes.home`
- Disponibilizar CTA secundario para navegar para `Routes.signUp`.

## 3.2 Nao funcionais
- Manter separacao de camadas: `View -> Presenter -> Provider -> Service -> RestClient -> API`.
- Nao colocar regra de negocio na `View`.
- Reaproveitar componentes existentes quando possivel, evitando duplicacao.
- Preservar navegacao declarativa com `GoRouter` e DI via `Riverpod`.
- Manter mensagens de erro claras para UX e seguras para autenticacao.

# 4. O que ja existe (inventario)

> Inclui apenas itens diretamente relevantes para a implementacao do `Sign In`.

## 4.1 UI (`lib/ui/`)
- **`SignUpScreenPresenter`** (`lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart`) - referencia de orquestracao de auth, persistencia em cache e redirecionamento por onboarding.
- **`SignUpScreenView`** (`lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_view.dart`) - referencia de estrutura visual (card central, estado de erro, submit/loading).
- **`SignUpHeaderView`** (`lib/ui/auth/widgets/screens/sign_up_screen/sign_up_header/sign_up_header_view.dart`) - cabecalho reutilizavel por `title`, `subtitle` e `iconData`.
- **`SignUpFooterView`** (`lib/ui/auth/widgets/screens/sign_up_screen/sign_up_footer/sign_up_footer_view.dart`) - base para CTA de alternancia entre login/cadastro.
- **`AppTheme`** (`lib/ui/shared/theme/app_theme.dart`) - tokens de cor, espacamento e borda usados nas telas de autenticacao.

## 4.2 Core (`lib/core/`)
- **`AuthService`** (`lib/core/auth/interfaces/auth_service.dart`) - contrato ja contem `signIn(...)` e `signUp(...)`.
- **`JwtDto`** (`lib/core/auth/dtos/jwt_dto.dart`) - DTO de sucesso de autenticacao (`accessToken` + `owner`).
- **`ProfilingService`** (`lib/core/profiling/interfaces/profiling_service.dart`) - contrato com `fetchOwner()` para obter `hasCompletedOnboarding`.
- **`CacheKeys`** (`lib/core/shared/constants/cache_keys.dart`) - chaves de sessao (`accessToken`, `onboardingCompleted`).
- **`Routes`** (`lib/core/shared/constants/routes.dart`) - destinos de navegacao (`signIn`, `signUp`, `onboarding`, `home`).
- **`RestResponse`** (`lib/core/shared/responses/rest_response.dart`) - wrapper padrao para tratamento de sucesso/falha.

## 4.3 REST (`lib/rest/`)
- **`AuthService` (impl REST)** (`lib/rest/auth/services/auth_service.dart`) - implementa `signUp`, mas ainda nao implementa `signIn`.
- **`JwtMapper`** (`lib/rest/auth/mappers/jwt_mapper.dart`) - mapper de resposta de auth para `JwtDto`.
- **`authServiceProvider`** (`lib/rest/services.dart`) - provider central para injetar `AuthService` na UI.
- **`ProfilingService` (impl REST)** (`lib/rest/profiling/services/profiling_service.dart`) - usado para `fetchOwner` apos autenticacao.

## 4.4 Drivers (`lib/drivers/`)
- **`SharedPreferencesCacheDriver`** (`lib/drivers/cache-driver/shared-prefences/shared_preferences_cache_driver.dart`) - persistencia de token e flags.
- **`GoRouterNavigationDriver`** (`lib/drivers/navigation-driver/go-router/go_router_navigation_driver.dart`) - adaptador de navegacao usado pelos presenters.

# 5. O que deve ser criado

> Apenas arquivos novos previstos para entregar o fluxo de `Sign In`.

## 5.1 UI

### 5.1.1 Presenters/Stores
- **Arquivo (novo):** `lib/ui/auth/widgets/screens/sign_in_screen/sign_in_screen_presenter.dart`
  - **Responsabilidade:** orquestrar validacao, submit de login, persistencia de sessao, decisao de rota e navegacao para cadastro.
  - **Dependencias:** `AuthService`, `ProfilingService`, `NavigationDriver`, `CacheDriver`.
  - **Estado (`signals`/providers):** `form`, `isLoading`, `generalError`, `isPasswordVisible`, `submitAttempted`.
  - **Computeds:** `canSubmit`, `hasAnyFieldError`.
  - **Metodos:** `buildForm()`, `normalizeBeforeSubmit()`, `togglePasswordVisibility()`, `applyServerFieldErrors(RestResponse response)`, `submit()`, `goToSignUp()`.

- **Arquivo (novo, mesmo arquivo acima):** provider `signInScreenPresenterProvider`
  - **Responsabilidade:** compor presenter via `Riverpod` com services e drivers existentes.

### 5.1.2 Views
- **Arquivo (novo):** `lib/ui/auth/widgets/screens/sign_in_screen/sign_in_screen_view.dart`
  - **Responsabilidade:** montar estrutura da tela e bindar estado do presenter com formulario e CTAs.
  - **Props:** sem props externas (resolve presenter via provider).
  - **Dependencias de UI:** `flutter/material.dart`, `flutter_riverpod`, `signals_flutter`, `reactive_forms`, `AppTheme`.

- **Arquivo (novo):** `lib/ui/auth/widgets/screens/sign_in_screen/sign_in_form/sign_in_form_view.dart`
  - **Responsabilidade:** renderizar campos `email`/`password`, mensagens de validacao e botao `Entrar`.
  - **Props:** `form`, `submitAttempted`, `isPasswordVisible`, `onTogglePasswordVisibility`, `onSubmit`, `isLoading`.
  - **Dependencias de UI:** `reactive_forms`, `flutter/material.dart`, `AppTheme`.

### 5.1.3 Widgets
- **Arquivo (novo):** `lib/ui/auth/widgets/screens/sign_in_screen/index.dart`
  - **Responsabilidade:** barrel export (`typedef SignInScreen = SignInScreenView`).
  - **Props:** nao se aplica.
  - **Widgets internos:** `sign_in_form`.

- **Arquivo (novo):** `lib/ui/auth/widgets/screens/sign_in_screen/sign_in_form/index.dart`
  - **Responsabilidade:** barrel export (`typedef SignInForm = SignInFormView`).
  - **Props:** nao se aplica.
  - **Widgets internos:** nenhum.

- **Estrutura de pastas (ASCII):**
```text
lib/ui/auth/widgets/screens/sign_in_screen/
  index.dart
  sign_in_screen_view.dart
  sign_in_screen_presenter.dart
  sign_in_form/
    index.dart
    sign_in_form_view.dart
```

## 5.2 Core
- Nenhum novo arquivo. Reutilizar contratos existentes em `lib/core/auth/interfaces/auth_service.dart` e `lib/core/profiling/interfaces/profiling_service.dart`.

## 5.3 REST
- Nenhum novo arquivo. A implementacao de `signIn` sera adicionada no arquivo existente `lib/rest/auth/services/auth_service.dart`.

## 5.4 Drivers
- Nenhum novo arquivo. Reutilizar `cacheDriverProvider` e `navigationDriverProvider`.

# 6. O que deve ser modificado

> Apenas arquivos existentes impactados por esta entrega.

- **Arquivo:** `lib/rest/auth/services/auth_service.dart`
  - **Mudanca:** implementar `signIn({required String accountEmail, required String accountPassword})` com chamada ao endpoint `POST /auth/sign-in`, enviando payload no formato `{'email': accountEmail, 'password': accountPassword}`, mapeando resposta com `JwtMapper` e padronizando mensagens de falha de autenticacao.
  - **Justificativa:** a interface `AuthService` ja exige `signIn`, mas a implementacao REST ainda nao cobre esse fluxo.
  - **Impacto:** `rest`

- **Arquivo:** `lib/rest/auth/services/auth_service.dart`
  - **Mudanca:** ao autenticar com sucesso (`signIn` e `signUp`), atualizar header `Authorization` no `RestClient` para suportar chamadas autenticadas subsequentes na mesma sessao (ex.: `fetchOwner`).
  - **Justificativa:** reduzir risco de falha em chamadas protegidas imediatamente apos login/cadastro.
  - **Impacto:** `rest`

- **Arquivo:** `lib/router.dart`
  - **Mudanca:** substituir `Scaffold` temporario da rota `Routes.signIn` pela tela real `SignInScreen` e adicionar import do novo index.
  - **Justificativa:** ativar o fluxo de autenticacao MVP na entrada do app.
  - **Impacto:** `ui`

- **Arquivo:** `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_footer/sign_up_footer_view.dart`
  - **Mudanca:** tornar o componente configuravel (`promptText`, `actionText`, `onTapAction`) mantendo compatibilidade com o uso atual do cadastro.
  - **Justificativa:** reutilizar o mesmo rodape para `Sign In` e `Sign Up`, evitando duplicacao de widget.
  - **Impacto:** `ui`

# 7. O que deve ser removido

> Remocoes seguras e restritas ao placeholder atual.

- **Arquivo:** `lib/router.dart`
  - **Remocao:** builder temporario `Scaffold(body: Center(child: Text('Entrar')))` da rota `Routes.signIn`.
  - **Motivo:** substituir placeholder por implementacao real da tela de login.
  - **Substituir por (se aplicavel):** `lib/ui/auth/widgets/screens/sign_in_screen/index.dart`

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)
```text
SignInScreenView -> SignInScreenPresenter -> authServiceProvider -> AuthService -> RestClient -> API (/auth/sign-in)
                                                                  -> profilingServiceProvider -> ProfilingService -> RestClient -> API (/profiling/owners/me)
SignInScreenPresenter -> CacheDriver -> NavigationDriver
```

## 8.2 Layout/hierarquia visual (ASCII)
```text
SignInScreen
  |- Auth Header (icone + titulo + subtitulo)
  |- Content Card
  |   |- Email Field
  |   |- Password Field (toggle)
  |   |- Error Alert (quando existir)
  |   `- Primary CTA: Entrar
  `- Footer CTA
      `- Link: Criar conta
```

## 8.3 Referencias internas
- `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart`
- `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_view.dart`
- `lib/rest/auth/services/auth_service.dart`
- `lib/router.dart`
- `documentation/architecture.md`
- `documentation/rules/rules.md`

## 8.4 Referencias de tela (quando houver)
- **Google Stitch screen id:** `projects/15865350654253776765/screens/80b0a3487b0f468b8b94f251f72d33c9`
- **Google Stitch URL:** `https://stitch.withgoogle.com/preview/15865350654253776765?node-id=80b0a3487b0f468b8b94f251f72d33c9`
- **Decisoes de UI extraidas:**
  - Preservar consistencia visual do modulo `auth` com card central, hierarquia de CTA e estado de erro explicito.
  - Manter CTA primario de entrada (`Entrar`) e CTA secundario para cadastro (`Criar conta`) no rodape.
  - Nao introduzir novos patterns visuais sem validacao de produto/layout.

---

# 9. Resumo da Implementacao

## 9.1 Status
✅ **CONCLUIDO** - Implementacao finalizada em 2026-02-16

## 9.2 Arquivos Criados (5)
1. `lib/ui/auth/widgets/screens/sign_in_screen/sign_in_screen_presenter.dart`
2. `lib/ui/auth/widgets/screens/sign_in_screen/sign_in_screen_view.dart`
3. `lib/ui/auth/widgets/screens/sign_in_screen/sign_in_form/sign_in_form_view.dart`
4. `lib/ui/auth/widgets/screens/sign_in_screen/index.dart`
5. `lib/ui/auth/widgets/screens/sign_in_screen/sign_in_form/index.dart`

## 9.3 Arquivos Modificados (4)
1. `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_footer/sign_up_footer_view.dart` - Componente tornado configuravel
2. `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_view.dart` - Atualizado uso do footer
3. `lib/rest/auth/services/auth_service.dart` - Implementado signIn() e header Authorization
4. `lib/router.dart` - Substituído placeholder pela tela real

## 9.4 Validacao de Qualidade
- ✅ `flutter analyze`: Sem erros na implementacao
- ✅ `dart format`: Todos os arquivos formatados
- ✅ Arquitetura: MVP + Riverpod + Signals conforme especificado
- ✅ Padroes: Reutilizacao de componentes existentes

## 9.5 Decisoes de Implementacao
- Mantido `SignUpHeaderView` reutilizado com titulo "Entrar" e icone `Icons.login`
- Footer configurado com texto "Nao tem uma conta? " e acao "Criar conta"
- Header Authorization atualizado automaticamente apos login/cadastro via `_setAuthorizationHeader()`
- Tratamento de erro especifico para credenciais invalidas
- Fluxo pos-login: fetchOwner() -> decisao de rota baseada em `hasCompletedOnboarding`

