---
title: Tab Dono do perfil do usuario
status: em progresso
last_updated_at: 2026-02-16
---

# 1. Objetivo
Entregar a implementacao da aba `Dono` na `ProfileScreen`, substituindo o placeholder atual por uma experiencia real com carregamento de dados do owner, edicao e persistencia de `name` e `email` via `ProfilingService`, e secao informativa de confianca em modo **readonly** (`Perfil Verificado`), mantendo consistencia com o layout do Stitch e sem quebrar a aba `Cavalo` ja em producao.

# 2. Escopo

## 2.1 In-scope
- Substituir `ProfileOwnerTabPlaceholder` por uma aba `Dono` funcional com layout dedicado.
- Carregar dados atuais do owner ao abrir a aba com `GET /profiling/owners/me`.
- Permitir editar `name` e `email` com validacao de formulario e acao explicita de `Salvar`.
- Persistir alteracoes de owner via `PUT /profiling/owners/`.
- Exibir secao `Perfil Verificado` em modo **readonly** conforme referencia visual.
- Ajustar `AppBar` da `ProfileScreen` para estado contextual da aba `Dono` (titulo + CTA `Salvar`).

## 2.2 Out-of-scope
- Persistencia de `phone`, `bio` e `avatar` no backend (contrato atual nao suporta esses campos).
- Alteracoes no fluxo da aba `Cavalo` (autosave, galeria e checklist permanecem como estao).
- Mudancas em `Auth`, `Onboarding`, `Discovery`, `Matches` ou `Chat`.
- Introducao de novos `drivers` ou alteracoes de infraestrutura fora do necessario para owner profile.

# 3. Requisitos

## 3.1 Funcionais
- Ao alternar para a aba `Dono`, a UI deve carregar os dados de owner e preencher o formulario.
- O formulario deve permitir editar `Nome Completo` e `Email`.
- O botao `Salvar` deve ficar disponivel somente quando houver alteracao valida pendente.
- Ao salvar com sucesso, a UI deve refletir estado de sincronizacao concluida (ex.: feedback visual de salvo).
- Em falha de API, a UI deve exibir erro geral sem perder os dados editados localmente.
- A secao `Perfil Verificado` deve ser renderizada como bloco informativo **readonly**.
- Campos sem contrato backend nesta iteracao (`Telefone`, `Bio`) devem ser exibidos sem persistencia remota.

## 3.2 Nao funcionais
- Seguir padrao `MVP` (`View` + `Presenter`) com estado via `signals` e composicao via `Riverpod`.
- Manter fluxo em camadas: `View -> Presenter -> Provider -> Service -> RestClient -> API`.
- Reutilizar `OwnerDto`, `ProfilingService` e `OwnerMapper` existentes antes de criar novos contratos.
- Nao permitir chamada HTTP diretamente na `View`.
- Preservar compatibilidade com o fluxo atual da `ProfileScreen` e da aba `Cavalo`.

# 4. O que ja existe (inventario)

> Inclua apenas itens realmente relevantes para implementar a mudanca.

## 4.1 UI (`lib/ui/`)
- **`ProfileScreenPresenter`** (`lib/ui/profiling/widgets/screens/profile_screen/profile_screen_presenter.dart`) - controla aba ativa (`horse|owner`) e navegacao de volta.
- **`ProfileScreenView`** (`lib/ui/profiling/widgets/screens/profile_screen/profile_screen_view.dart`) - compoe `AppBar`, seletor de abas e atualmente renderiza placeholder da aba `Dono`.
- **`ProfileTabSelectorView`** (`lib/ui/profiling/widgets/screens/profile_screen/profile_tab_selector/profile_tab_selector_view.dart`) - componente reutilizavel de alternancia `Cavalo`/`Dono`.
- **`ProfileHorseTabPresenter`** (`lib/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_tab_presenter.dart`) - referencia de padrao de estado assinado com `signals` e provider `autoDispose`.
- **`SignUpScreenPresenter`** (`lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart`) - referencia de validacao de `name`/`email` e submit manual com `reactive_forms`.
- **`ProfileOwnerTabPlaceholderView`** (`lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab_placeholder/profile_owner_tab_placeholder_view.dart`) - placeholder atual a ser removido.

## 4.2 Core (`lib/core/`)
- **`OwnerDto`** (`lib/core/profiling/dtos/entities/owner_dto.dart`) - DTO atual com `id`, `name`, `email`, `accountId` e `hasCompletedOnboarding`.
- **`ProfilingService`** (`lib/core/profiling/interfaces/profiling_service.dart`) - contrato da feature; contem `fetchOwner()` e ponto para evolucao de `updateOwner`.
- **`RestResponse`** (`lib/core/shared/responses/rest_response.dart`) - encapsula sucesso/falha das operacoes de API.

## 4.3 REST (`lib/rest/`)
- **`ProfilingService`** (`lib/rest/services/profiling_service.dart`) - implementa `fetchOwner()` em `/profiling/owners/me` e deve ser estendido para update de owner.
- **`OwnerMapper`** (`lib/rest/mappers/auth/owner_mapper.dart`) - converte payload de owner em `OwnerDto`; ainda sem serializacao de update.
- **`DioRestClient`** (`lib/rest/dio/dio_rest_client.dart`) - adapter HTTP utilizado por todos os services.

## 4.4 Drivers (`lib/drivers/`)
- **`GoRouterNavigationDriver`** (`lib/drivers/navigation-driver/go-router/go_router_navigation_driver.dart`) - mantem comportamento de `goBack()` ja usado no cabecalho da tela de perfil.

# 5. O que deve ser criado

> Liste apenas arquivos novos. Para cada arquivo, detalhe assinatura, responsabilidade, dependencias e estado quando aplicavel.

## 5.1 UI

### 5.1.1 Presenters/Stores
- **Arquivo (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_tab_presenter.dart`
  - **Responsabilidade:** orquestrar carga, edicao e salvamento dos dados do owner para a aba `Dono`.
  - **Dependencias:** `ProfilingService`, `ProfileOwnerFormSectionPresenter`.
  - **Estado (`signals`/providers):** `ownerForm`, `isLoadingOwner`, `isSavingOwner`, `generalError`, `lastSavedAt`, `readOnlyPhone`, `readOnlyBio`.
  - **Computeds:** `canSave`, `hasPendingChanges`.
  - **Metodos:** `init()`, `dispose()`, `loadOwner()`, `saveOwner()`, `normalizeBeforeSave()`, `clearError()`.

- **Arquivo (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_form_section_presenter.dart`
  - **Responsabilidade:** centralizar construcao do `FormGroup` da aba `Dono` e regras de validacao.
  - **Dependencias:** `reactive_forms`.
  - **Estado (`signals`/providers):** nao se aplica.
  - **Computeds:** nao se aplica.
  - **Metodos:** `FormGroup buildForm()`.

### 5.1.2 Views
- **Arquivo (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_tab_view.dart`
  - **Responsabilidade:** montar o conteudo da aba `Dono`, conectando secao de formulario e secao `Perfil Verificado`.
  - **Props:** `form`, `isLoading`, `generalError`, `readOnlyPhone`, `readOnlyBio`.
  - **Dependencias de UI:** `flutter/material.dart`, `reactive_forms`, `AppTheme`.

- **Arquivo (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_form_section_view.dart`
  - **Responsabilidade:** renderizar campos de `Dados Pessoais` (`name`, `email`) e campos exibidos sem persistencia (`phone`, `bio`) mantendo hierarquia visual do Stitch.
  - **Props:** `form`, `readOnlyPhone`, `readOnlyBio`.
  - **Dependencias de UI:** `reactive_forms`, `flutter/material.dart`, `AppTheme`.

- **Arquivo (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_verified_section/profile_owner_verified_section_view.dart`
  - **Responsabilidade:** exibir bloco informativo `Perfil Verificado` em modo **readonly**.
  - **Props:** opcionalmente `title` e `description` para copy.
  - **Dependencias de UI:** `flutter/material.dart`, `AppTheme`.

### 5.1.3 Widgets
- **Arquivo/Pasta (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/`
  - **Responsabilidade:** agrupar implementacao completa da aba `Dono` seguindo padrao `MVP`.
  - **Props:** widget pai sem props externas; dados chegam via presenter no `ProfileScreenView`.
  - **Widgets internos:** `profile_owner_form_section`, `profile_owner_verified_section`.
  - **Estrutura de pastas (ASCII):**
```text
lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/
  index.dart
  profile_owner_tab_view.dart
  profile_owner_tab_presenter.dart
  profile_owner_form_section/
    index.dart
    profile_owner_form_section_presenter.dart
    profile_owner_form_section_view.dart
  profile_owner_verified_section/
    index.dart
    profile_owner_verified_section_view.dart
```

## 5.2 Core
- **Nenhum arquivo novo.**

## 5.3 REST
- **Nenhum arquivo novo.**

## 5.4 Drivers
- **Nenhum arquivo novo.**

# 6. O que deve ser modificado

> Liste apenas arquivos existentes. Mudancas em arquivo novo ficam na secao 5.

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_screen_view.dart`
  - **Mudanca:** substituir `ProfileOwnerTabPlaceholder` por `ProfileOwnerTab`, conectar presenter da aba `Dono`, tornar `AppBar` contextual (titulo e acao `Salvar` quando `activeTab == owner`) e manter comportamento atual da aba `Cavalo`.
  - **Justificativa:** integrar o novo fluxo de owner profile no container de tela ja existente.
  - **Impacto:** `ui`

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_screen_presenter.dart`
  - **Mudanca:** expor estado derivado para aba `Dono` (ex.: `isOwnerTab`) e metadados de cabecalho quando necessario.
  - **Justificativa:** evitar regra condicional espalhada na `View` e centralizar estado de navegacao entre abas.
  - **Impacto:** `ui`

- **Arquivo:** `lib/core/profiling/interfaces/profiling_service.dart`
  - **Mudanca:** adicionar contrato `Future<RestResponse<OwnerDto>> updateOwner({required OwnerDto owner});`.
  - **Justificativa:** habilitar persistencia dos dados editaveis do owner com contrato tipado de `core`.
  - **Impacto:** `core`

- **Arquivo:** `lib/rest/services/profiling_service.dart`
  - **Mudanca:** implementar `updateOwner(...)` com `PUT /profiling/owners/`, mapeando resposta para `OwnerDto` via `OwnerMapper`.
  - **Justificativa:** cumprir novo contrato da interface `ProfilingService` e fechar fluxo de salvamento da aba `Dono`.
  - **Impacto:** `rest`

- **Arquivo:** `lib/rest/mappers/auth/owner_mapper.dart`
  - **Mudanca:** incluir serializacao `toJson(OwnerDto owner)` para payload de update (`name`, `email`) e manter desserializacao robusta em `snake_case`.
  - **Justificativa:** evitar logica de serializacao no service e preservar padrao `Mapper` da camada `rest`.
  - **Impacto:** `rest`

# 7. O que deve ser removido

> Remocoes precisam ser seguras (sem quebrar fluxo, import ou contrato publico). Se houver substituicao, aponte o novo caminho.

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab_placeholder/profile_owner_tab_placeholder_view.dart`
  - **Remocao:** componente placeholder textual da aba `Dono`.
  - **Motivo:** substituir por implementacao funcional da aba.
  - **Substituir por (se aplicavel):** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_tab_view.dart`

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab_placeholder/index.dart`
  - **Remocao:** barrel do placeholder.
  - **Motivo:** evitar export antigo sem uso apos migracao para widget final.
  - **Substituir por (se aplicavel):** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/index.dart`

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)
```text
ProfileScreenView (tab Dono)
  -> ProfileOwnerTabPresenter
    -> profilingServiceProvider
      -> ProfilingService (REST)
        -> RestClient (Dio)
          -> GET /profiling/owners/me
          -> PUT /profiling/owners/
```

## 8.2 Layout/hierarquia visual (ASCII)
```text
ProfileScreen
  |- AppBar (back, title, salvar)
  |- ProfileTabSelector (Cavalo | Dono)
  `- ProfileOwnerTab
      |- Dados Pessoais
      |   |- Avatar (visual)
      |   |- Nome Completo (editavel)
      |   |- Email (editavel)
      |   |- Telefone (sem persistencia remota)
      |   `- Bio (sem persistencia remota)
      `- Perfil Verificado (readonly)
```

## 8.3 Referencias internas
- `lib/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_tab_presenter.dart`
- `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart`
- `lib/rest/services/profiling_service.dart`
- `lib/rest/mappers/auth/owner_mapper.dart`
- `lib/core/profiling/interfaces/profiling_service.dart`

## 8.4 Referencias de tela (quando houver)
- **Google Stitch screen id:** `projects/15865350654253776765/screens/f4cfe7687bd448bca78b5ce672360e86`
- **Decisoes de UI extraidas:**
  - `AppBar` com `arrow_back`, titulo de perfil do usuario e CTA `Salvar`.
  - Estrutura em abas com `Cavalo` e `Dono` no topo.
  - Secao `Dados Pessoais` com hierarquia clara de campos de contato.
  - Secao `Sobre Voce` com bio e contador de caracteres.
  - Bloco `Perfil Verificado` deve permanecer informativo e **readonly**.

# 9. Perguntas em aberto
- Confirmar com backend se `OwnerSchema` sera expandido para `phone`, `bio` e metadados de verificacao; hoje o contrato oficial expoe apenas `name` e `email`.
- Definir se o avatar da aba `Dono` tera upload real nesta fase (nao existe endpoint de owner avatar no contrato atual).
- Confirmar regra final de UX para campos sem persistencia remota (`Telefone`/`Bio`): manter somente exibicao readonly ou habilitar edicao local temporaria.
