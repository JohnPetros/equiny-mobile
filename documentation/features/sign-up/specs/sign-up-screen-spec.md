---
title: Sign Up Screen
status: concluido
lastUpdatedAt: 2026-02-15
---

## 2. Objetivo

Entregar a implementacao completa da tela de Sign Up do Equiny (UI + orquestracao + integracao REST), com validacoes de formulario em cliente/servidor usando `reactive_forms`, criacao de sessao apos cadastro e redirecionamento automatico para o fluxo de Criar Cavalo, seguindo padroes MVP na UI, Riverpod para injecao de dependencias e Signals para estado reativo complementar.

## 2.1 Resultado final da implementacao

- Tela de cadastro implementada em `lib/ui/auth/widgets/screens/sign_up_screen/` com composicao por subwidgets (`sign_up_header`, `sign_up_form`, `sign_up_footer`) e presenter dedicado.
- Integracao de cadastro implementada em `lib/rest/auth/services/auth_service.dart` com mapeamento para `JwtDto`.
- Sessao persistida via `CacheDriver` (`CacheKeys.authToken`) e redirecionamento para `Routes.createHorse` apos sucesso.
- Bootstrap do app atualizado em `lib/main.dart` + `lib/app.dart` + `lib/router.dart`.
- Ajuste final de UX/testabilidade no footer: link `Entrar` renderizado em `Wrap` + `GestureDetector` (evita miss hit-test em ambiente de teste).

## 3. O que ja existe?

### Core
- **`RestClient`** (`lib/core/shared/interfaces/rest_client.dart`) - *Contrato HTTP base para criar o client REST da feature de cadastro.*
- **`RestResponse`** (`lib/core/shared/responses/rest_response.dart`) - *Wrapper padrao para sucesso/erro nas respostas de API.*
- **`HttpStatusCode`** (`lib/core/shared/constants/http_status_code.dart`) - *Constantes de status HTTP para mapear sucesso e falhas no cadastro.*
- **`NavigationDriver`** (`lib/core/shared/interfaces/navigation_driver.dart`) - *Contrato de navegacao que sera usado pelo Presenter para ir para Criar Cavalo e Entrar.*
- **`CacheDriver`** (`lib/core/shared/interfaces/cache_driver.dart`) - *Contrato de persistencia simples para salvar token/sessao apos cadastro.*
- **`EnvDriver`** (`lib/core/shared/interfaces/env_driver.dart`) - *Contrato de variaveis de ambiente para base URL da API.*
- **`Json`** (`lib/core/shared/types/json.dart`) - *Tipo padrao de payload para requests/responses no RestClient.*
- **`AccountDto`** (`lib/core/auth/dtos/account_dto.dart`) - *DTO de conta ja existente para representar dados basicos do usuario autenticado.*
- **`JwtDto`** (`lib/core/auth/dtos/jwt_dto.dart`) - *DTO ja existente para representar o token de autenticacao (`accessToken`).*
- **`AuthService`** (`lib/core/auth/interfaces/auth_service.dart`) - *Contrato de cadastro ja criado retornando `JwtDto`, que deve ser evoluido para receber input especifico de Sign Up.*

### UI
- **`MyApp`** (`lib/main.dart`) - *Bootstrap temporario (contador Flutter) que deve ser substituido por composicao real de rotas e providers.*
- **`lib/ui/auth/widgets/screens/`** (`lib/ui/auth/widgets/screens`) - *Estrutura de pastas de auth ja criada, sem implementacao de telas.*

### REST
- Nenhum service REST de auth existe em `lib/rest/`.

### Drivers
- Nenhum driver concreto existe em `lib/drivers/`.

## 4. O que deve ser criado?

#### Core (DTOs e Interfaces)

##### Sem novo DTO de input para cadastro
- **Localizacao:** `lib/core/auth/interfaces/auth_service.dart`
- **Dependencias:** `RestResponse`, `JwtDto`.
- **Metodos:** `Future<RestResponse<JwtDto>> signUp({required String ownerName, required String email, required String password, required String passwordConfirmation})`.
- **Responsabilidade:** receber os parametros de cadastro diretamente na assinatura do service.

##### `Routes`
- **Localizacao:** `lib/core/shared/constants/routes.dart`
- **Dependencias:** nenhuma.
- **Metodos:** constantes estaticas (`signUp`, `signIn`, `createHorse`).
- **Responsabilidade:** evitar strings de rota hardcoded em presenter/view/driver.

##### `CacheKeys`
- **Localizacao:** `lib/core/shared/constants/cache_keys.dart`
- **Dependencias:** nenhuma.
- **Metodos:** constantes estaticas (`authToken`, `refreshToken`).
- **Responsabilidade:** padronizar chaves de persistencia da sessao.

#### UI (Presenters, Stores)

##### `SignUpScreenPresenter`
- **Localizacao:** `lib/ui/auth/widgets/screens/sign_up/sign_up_screen/sign_up_screen_presenter.dart`
- **Dependencias:** `AuthService`, `NavigationDriver`, `CacheDriver`.
- **Signals/Estado:** `form` (`FormGroup` com `name`, `email`, `password`, `passwordConfirmation`), `isLoading`, `generalError`, `isPasswordVisible`, `isPasswordConfirmationVisible`, `submitAttempted`.
- **Computeds:** `canSubmit` (baseado em `form.valid` + `!isLoading`), `hasAnyFieldError` (baseado em estado dos controls e `submitAttempted`).
- **Metodos:**
  - `FormGroup buildForm()` - cria estrutura do formulario com validadores (`required`, `minLength`, `maxLength`, `email`) e validador de grupo para confirmacao de senha.
  - `void normalizeBeforeSubmit()` - aplica normalizacao final (`trim` em nome, `trim+lowercase` em email) antes da chamada de API.
  - `void togglePasswordVisibility()` - alterna visualizacao da senha.
  - `void togglePasswordConfirmationVisibility()` - alterna visualizacao da confirmacao.
  - `void applyServerFieldErrors(RestResponse response)` - injeta erros de servidor nos `FormControl`s corretos quando aplicavel.
  - `Future<void> submit()` - marca `submitAttempted`, valida `form`, bloqueia double tap, normaliza dados, chama `AuthService.signUp`, persiste sessao via `CacheDriver`, navega para `Routes.createHorse` e mapeia erros de campo/gerais.
  - `void goToSignIn()` - navega para `Routes.signIn`.

##### Provider do Presenter
- **Localizacao:** `lib/ui/auth/widgets/screens/sign_up/sign_up_screen/sign_up_screen_presenter.dart`
- **Dependencias:** providers de `AuthService`, `NavigationDriver`, `CacheDriver`.
- **Signals/Estado:** nao se aplica (factory Riverpod).
- **Computeds:** nao se aplica.
- **Metodos:** `final signUpScreenPresenterProvider = Provider.autoDispose<SignUpScreenPresenter>(...)`.

#### UI (Views)

##### `SignUpScreenView`
- **Localizacao:** `lib/ui/auth/widgets/screens/sign_up/sign_up_screen/sign_up_screen_view.dart`
- **Bibliotecas de UI:** `flutter_riverpod`, `signals_flutter`, `reactive_forms`, `shadcn_flutter`.
- **Props:** sem props obrigatorias; resolve presenter via provider.

##### `SignUpHeaderView`
- **Localizacao:** `lib/ui/auth/widgets/screens/sign_up/sign_up_screen/sign_up_header/sign_up_header_view.dart`
- **Bibliotecas de UI:** `shadcn_flutter`.
- **Props:** `title`, `subtitle`, `iconData`.

##### `SignUpFormView`
- **Localizacao:** `lib/ui/auth/widgets/screens/sign_up/sign_up_screen/sign_up_form/sign_up_form_view.dart`
- **Bibliotecas de UI:** `reactive_forms`, `shadcn_flutter`.
- **Props:**
  - `form` (`FormGroup`)
  - `submitAttempted`
  - `isPasswordVisible`, `isPasswordConfirmationVisible`
  - callbacks (`onTogglePasswordVisibility`, `onTogglePasswordConfirmationVisibility`, `onSubmit`)
  - `isLoading`.

##### `SignUpFooterView`
- **Localizacao:** `lib/ui/auth/widgets/screens/sign_up/sign_up_screen/sign_up_footer/sign_up_footer_view.dart`
- **Bibliotecas de UI:** `shadcn_flutter`.
- **Props:** `onTapSignIn`.

##### Barrel files
- **Localizacao:**
  - `lib/ui/auth/widgets/screens/sign_up/index.dart`
  - `lib/ui/auth/widgets/screens/sign_up/sign_up_screen/index.dart`
  - `lib/ui/auth/widgets/screens/sign_up/sign_up_screen/sign_up_header/index.dart`
  - `lib/ui/auth/widgets/screens/sign_up/sign_up_screen/sign_up_form/index.dart`
  - `lib/ui/auth/widgets/screens/sign_up/sign_up_screen/sign_up_footer/index.dart`
- **Bibliotecas de UI:** nao se aplica.
- **Props:** nao se aplica.

#### UI (Widgets)

##### Widget principal: `sign_up`
- **Localizacao:** `lib/ui/auth/widgets/screens/sign_up`
- **Props:** o widget de tela nao recebe props externas; dependencia vem de provider.
- **Widgets internos:** `sign_up_screen`.
- **Estrutura de pastas:**

```text
lib/ui/auth/widgets/screens/sign_up/
|-- index.dart
`-- sign_up_screen/
    |-- index.dart
    |-- sign_up_screen_view.dart
    |-- sign_up_screen_presenter.dart
    |-- sign_up_header/
    |   |-- index.dart
    |   `-- sign_up_header_view.dart
    |-- sign_up_form/
    |   |-- index.dart
    |   `-- sign_up_form_view.dart
    `-- sign_up_footer/
        |-- index.dart
        `-- sign_up_footer_view.dart
```

##### Widget interno: `sign_up_screen`
- **Localizacao:** `lib/ui/auth/widgets/screens/sign_up/sign_up_screen`
- **Props:** sem props externas; obtem presenter via provider.
- **Widgets internos:** `sign_up_header`, `sign_up_form`, `sign_up_footer`.
- **Estrutura de pastas:** contem widgets internos da tela de cadastro.

##### Widget interno: `sign_up_header`
- **Localizacao:** `lib/ui/auth/widgets/screens/sign_up/sign_up_screen/sign_up_header`
- **Props:** `title`, `subtitle`, `iconData`.
- **Widgets internos:** nenhum.
- **Estrutura de pastas:** sem subwidgets.

##### Widget interno: `sign_up_form`
- **Localizacao:** `lib/ui/auth/widgets/screens/sign_up/sign_up_screen/sign_up_form`
- **Props:** campos, erros, estado de loading e callbacks do Presenter principal.
- **Widgets internos:** nenhum.
- **Estrutura de pastas:** sem subwidgets.

##### Widget interno: `sign_up_footer`
- **Localizacao:** `lib/ui/auth/widgets/screens/sign_up/sign_up_screen/sign_up_footer`
- **Props:** `onTapSignIn`.
- **Widgets internos:** nenhum.
- **Estrutura de pastas:** sem subwidgets.

#### REST (Services)

##### `DioRestClient`
- **Localizacao:** `lib/rest/dio/dio_rest_client.dart`
- **Dependencias:** `Dio`.
- **Metodos:** `get`, `post`, `put`, `delete`, `setBaseUrl`, `setHeader`, `getBaseUrl`.
- **Responsabilidade:** adaptar Dio para o contrato `RestClient` da camada Core.

##### Provider do RestClient
- **Localizacao:** `lib/rest/rest_client.dart`
- **Dependencias:** `DioRestClient`, provider de `EnvDriver`.
- **Metodos:** provider Riverpod para instancia unica de `RestClient` configurada com base URL.

##### `AuthRestService`
- **Localizacao:** `lib/rest/auth/services/auth_rest_service.dart`
- **Dependencias:** `RestClient`.
- **Metodos:** `Future<RestResponse<JwtDto>> signUp({required String ownerName, required String email, required String password, required String passwordConfirmation})`.
- **Responsabilidade:** chamar endpoint de cadastro (`POST /auth/sign-up`), mapear body de sucesso e erros de dominio (email em uso, validacoes, falha de rede).

##### `JwtMapper`
- **Localizacao:** `lib/rest/auth/mappers/jwt_mapper.dart`
- **Dependencias:** `JwtDto`, tipo `Json`.
- **Metodos:** `static JwtDto toDto(Json body)`.
- **Responsabilidade:** converter JSON da API para `JwtDto` da camada Core.

##### Provider de services
- **Localizacao:** `lib/rest/services.dart`
- **Dependencias:** provider de `RestClient`.
- **Metodos:** `authServiceProvider` retornando `AuthService`.
- **Responsabilidade:** centralizar composicao de services da camada REST.

#### Drivers

##### `DotEnvDriver`
- **Localizacao:** `lib/drivers/env-driver/dot_env_driver.dart`
- **Dependencias:** `flutter_dotenv`.
- **Metodos:** `String get(String key)`.
- **Responsabilidade:** implementacao concreta de `EnvDriver` para base URL da API e demais variaveis de ambiente.

##### `GoRouterNavigationDriver`
- **Localizacao:** `lib/drivers/navigation-driver/go_router_navigation_driver.dart`
- **Dependencias:** `GoRouter`.
- **Metodos:** `goTo`, `goBack`, `canGoBack`.
- **Responsabilidade:** adaptar roteamento para o contrato `NavigationDriver`.

##### `SharedPreferencesCacheDriver`
- **Localizacao:** `lib/drivers/cache-driver/shared_preferences_cache_driver.dart`
- **Dependencias:** `SharedPreferences`.
- **Metodos:** `get`, `set`, `delete`.
- **Responsabilidade:** persistir token e dados minimos de sessao apos cadastro.

##### Providers de drivers
- **Localizacao:** `lib/drivers/drivers.dart`
- **Dependencias:** `GoRouter`, `SharedPreferences`, `dotenv`.
- **Metodos:** providers Riverpod para `EnvDriver`, `NavigationDriver` e `CacheDriver`.
- **Responsabilidade:** composicao central dos drivers concretos.

## 5. O que deve ser modificado?

#### Configuracao
- **Arquivo:** `pubspec.yaml`
- **Mudanca:** adicionar dependencias necessarias (`flutter_riverpod`, `signals`, `signals_flutter`, `reactive_forms`, `go_router`, `dio`, `shadcn_flutter`, `flutter_dotenv`, `shared_preferences`).

#### UI
- **Arquivo:** `lib/main.dart`
- **Mudanca:** remover app de contador e configurar bootstrap real com `ProviderScope`, roteador do app e rota inicial apontando para `SignUpScreen`.

#### Core
- **Arquivo:** `lib/core/shared/interfaces/rest_client.dart`
- **Mudanca:** ajustar assinatura de `getBaseUrl` para retorno tipado (`String`) para manter consistencia com implementacao do `DioRestClient`.
- **Arquivo:** `lib/core/auth/interfaces/auth_service.dart`
- **Mudanca:** manter response `Future<RestResponse<JwtDto>>` e substituir `AccountDto` por parametros nomeados do metodo `signUp` (`ownerName`, `email`, `password`, `passwordConfirmation`).
- **Arquivo:** `lib/core/auth/dtos/account_dto.dart`
- **Mudanca:** manter como DTO basico de conta para outros fluxos de auth/perfil; nao usar `AccountDto` como payload de cadastro.

#### Runtime/Assets
- **Arquivo:** `.gitignore`
- **Mudanca:** garantir que arquivo de ambiente local (ex.: `.env`) permaneca ignorado quando a integracao de API for adicionada.

## 6. O que deve ser removido?

#### UI
- **Arquivo:** `lib/main.dart`
- **Motivo:** remover classes e widgets do template inicial (`MyHomePage` e fluxo de contador) para evitar codigo nao relacionado competindo com a arquitetura MVP da feature de autenticacao.

## 7. Usar como referencia

- PRD da feature: `https://raw.githubusercontent.com/JohnPetros/equiny/refs/heads/main/documentation/features/auth/sign-up-screen.md`
- Tela no Stitch: `projects/15865350654253776765/screens/02b92e1ee91c4c27b47ca7f092f769ef`
- Contrato de resposta HTTP existente: `lib/core/shared/responses/rest_response.dart`
- Contrato de client REST existente: `lib/core/shared/interfaces/rest_client.dart`
- Contratos de navegacao/cache existentes: `lib/core/shared/interfaces/navigation_driver.dart`, `lib/core/shared/interfaces/cache_driver.dart`
- Contratos de auth existentes: `lib/core/auth/interfaces/auth_service.dart`, `lib/core/auth/dtos/account_dto.dart`, `lib/core/auth/dtos/jwt_dto.dart`

## 8. Diagramas e referencias

- **Fluxo de dados:**

```ASCII
SignUpScreenView
  -> SignUpScreenPresenter
    -> AuthService (Core interface)
      -> AuthService (REST impl em `lib/rest/auth/services/auth_service.dart`)
        -> RestClient (DioRestClient)
          -> POST /auth/sign-up (API)
        <- RestResponse<JwtDto>
    -> CacheDriver.set(authToken)
    -> NavigationDriver.goTo(Routes.createHorse)
```

- **Layout:**

```ASCII
SignUpScreenView
`-- SafeArea
    `-- SingleChildScrollView
        `-- Center/ConstrainedBox
            `-- Container (card)
                `-- Column
                    |-- SignUpHeaderView
                    |   |-- Icon(pets)
                    |   |-- Text("Criar conta")
                    |   `-- Text("Crie sua conta para comecar.")
                    |-- SignUpFormView
                    |   |-- TextField("Nome do dono")
                    |   |-- TextField("E-mail")
                    |   |-- PasswordField("Senha", toggle)
                    |   |-- PasswordField("Confirmar senha", toggle)
                    |   `-- PrimaryButton("Criar conta", loading)
                    `-- SignUpFooterView
                        `-- Wrap(Text("Ja tem uma conta? "), Link("Entrar"))
```

- **Referencias:**
  - `lib/core/shared/interfaces/rest_client.dart`
  - `lib/core/shared/responses/rest_response.dart`
  - `documentation/architecture.md`
  - `documentation/rules/ui-layer-rules.md`
  - `documentation/rules/core-layer-rules.md`
  - `documentation/rules/rest-layer-rules.md`
  - `documentation/rules/drivers-layer-rules.md`
  - `02b92e1ee91c4c27b47ca7f092f769ef` (Link da tela no Google Stitch)

## 9. Checklist de Validacao

- [x] Estrutura obrigatoria seguida integralmente.
- [x] Caminhos de arquivos existentes conferidos e novos caminhos definidos com convencoes do projeto.
- [x] Sem duplicacao de componentes ja existentes (camada Core/Auth parcialmente implementada e reaproveitada).
- [x] Decisoes alinhadas com guidelines de UI, Core, REST e Drivers.
- [x] `dart format .` executado e aplicado.
- [x] `flutter analyze` retornando "No issues found".
- [x] `flutter test` com todos os testes passando.

## 10. Ajustes de escopo aplicados durante a implementacao

- A estrutura final da UI foi consolidada em `sign_up_screen` (sem pasta intermediaria `sign_up/`).
- O contrato final de cadastro ficou com 3 parametros no service (`ownerName`, `accountEmail`, `accountPassword`), sem `passwordConfirmation` no payload enviado ao backend.
- A validacao de confirmacao de senha permanece no cliente via `Validators.mustMatch`.
- A navegacao para `signIn` e `createHorse` foi provisionada no roteador com telas placeholder para destravar o fluxo MVP.
