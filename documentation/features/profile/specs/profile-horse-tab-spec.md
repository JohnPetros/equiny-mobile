---
title: Tab de cavalo do perfil do usuario
status: em progresso
last_updated_at: 2026-02-16
---

# 1. Objetivo
Entregar a primeira iteracao da tela de perfil com foco na tab `Cavalo`, permitindo carregar dados atuais do cavalo, editar campos principais, gerenciar galeria de fotos (adicionar/remover/definir principal), controlar status `Ativo/Inativo` com validacao de elegibilidade para feed e salvar alteracoes com feedback de estado, mantendo arquitetura em camadas (`UI -> Core -> Rest -> Drivers`) e deixando a base de navegacao e composicao pronta para evoluir a tab `Dono` na proxima etapa sem retrabalho estrutural.

# 2. Escopo

## 2.1 In-scope
- Criar `ProfileScreen` com seletor de abas `Cavalo` e `Dono`, com foco funcional total na aba `Cavalo`.
- Carregar dados iniciais do cavalo e galeria ao abrir a tela via `ProfilingService`.
- Editar dados do cavalo com validacao de formulario, feedback inline e persistencia automatica por campo alterado.
- Gerenciar galeria com limite de 6 imagens, definicao de imagem principal e fluxo de retry de upload.
- Implementar toggle `Ativo/Inativo` com bloqueio de ativacao quando o cavalo estiver inelegivel para feed.
- Remover CTA de salvar e operar em modo autosave chamando service correspondente sempre que houver alteracao de `HorseDto`.

## 2.2 Out-of-scope
- Implementacao completa da aba `Dono` (campos, validacoes e persistencia).
- Suporte a multiplos cavalos com seletor na UI.
- Alteracoes de fluxo de `Discovery`, `Likes`, `Matches` ou `Chat`.
- Analytics/telemetria de eventos da tela.

# 3. Requisitos

## 3.1 Funcionais
- A tela deve exibir estrutura com abas `Cavalo` e `Dono` conforme referencia visual do Stitch.
- Ao abrir a tab `Cavalo`, o app deve hidratar formulario e galeria com dados vindos da API.
- Campos do cavalo devem permitir edicao de `nome`, `sexo`, `nascimento/idade`, `raca`, `altura`, `localizacao` e `descricao` (quando suportado pelo contrato atual).
- Ao alterar qualquer dado de `HorseDto`, o presenter deve acionar imediatamente `ProfilingService.updateHorse` (com `debounce` curto para evitar excesso de chamadas).
- A galeria deve suportar adicionar, remover e reordenar imagens para definir a principal, respeitando maximo de 6.
- O toggle `Ativo/Inativo` deve validar requisitos minimos antes de ativar e exibir pendencias quando bloqueado.
- Mudancas de galeria devem chamar `ProfilingService.updateHorseGallery` sem dependencia de botao de confirmacao.

## 3.2 Nao funcionais
- Seguir padrao MVP com `Presenter` + `View` e estado com `signals` + `reactive_forms`.
- Reaproveitar `MediaPickerDriver`, `FileStorageService`, `ProfilingService` e mappers existentes antes de criar duplicatas.
- Manter regras de camada: UI sem acesso direto a `RestClient` e sem logica de dominio na view.
- Garantir comportamento deterministico da imagem principal pela ordem da lista local (indice `0`).

# 4. O que ja existe (inventario)

## 4.1 UI (`lib/ui/`)
- **`OnboardingScreenPresenter`** (`lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_screen_presenter.dart`) - referencia de fluxo de upload com `MediaPickerDriver` + `FileStorageService` + `ProfilingService`.
- **`OnboardingStepImagesView`** (`lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_images/onboarding_step_images_view.dart`) - base reaproveitavel de UX de lista de imagens com erro e retry.
- **`AppThemeColors`, `AppSpacing`, `AppRadius`** (`lib/ui/shared/theme/app_theme.dart`) - tokens visuais e espacos usados no app.
- **`HomeScreenView`** (`lib/ui/home/widgets/screens/home_screen/home_screen_view.dart`) - tela placeholder que sera ponto inicial de acesso manual para `ProfileScreen` nesta etapa.

## 4.2 Core (`lib/core/`)
- **`HorseDto`** (`lib/core/profiling/dtos/entities/horse_dto.dart`) - DTO base do cavalo, hoje usado no onboarding e create/update.
- **`OwnerDto`** (`lib/core/profiling/dtos/entities/owner_dto.dart`) - contrato de owner para fluxo futuro da aba `Dono`.
- **`GalleryDto`** (`lib/core/profiling/dtos/structures/gallery_dto.dart`) - contrato de galeria usado no create/update.
- **`ImageDto`** (`lib/core/profiling/dtos/structures/image_dto.dart`) - unidade de imagem persistida.
- **`ProfilingService`** (`lib/core/profiling/interfaces/profiling_service.dart`) - interface com metodos de perfil (parte ainda sem implementacao concreta completa no REST).

## 4.3 REST (`lib/rest/`)
- **`ProfilingService`** (`lib/rest/profiling/services/profiling_service.dart`) - implementa `fetchOwner`, `createHorse` e `createHorseGallery`; precisa ser extendido para leitura/edicao de cavalo e galeria.
- **`HorseMapper`** (`lib/rest/profiling/mappers/horse_mapper.dart`) - serializacao e desserializacao de cavalo.
- **`GalleryMapper`** (`lib/rest/profiling/mappers/gallery_mapper.dart`) - serializacao e desserializacao de galeria.
- **`FileStorageService`** (`lib/rest/storage/services/file_storage_service.dart`) - upload multipart de imagens ja pronto para reutilizacao.

## 4.4 Drivers (`lib/drivers/`)
- **`ImagePickerMediaPickerDriver`** (`lib/drivers/media-picker-driver/image-picker/image_picker_media_picker_driver.dart`) - driver concreto para selecionar imagens do dispositivo.
- **`GoRouterNavigationDriver`** (`lib/drivers/navigation-driver/go-router/go_router_navigation_driver.dart`) - adaptador de navegacao usado pelos presenters.
- **`SharedPreferencesCacheDriver`** (`lib/drivers/cache-driver/shared-prefences/shared_preferences_cache_driver.dart`) - persistencia local simples para flags/chaves de sessao.

# 5. O que deve ser criado

## 5.1 UI

### 5.1.1 Presenters/Stores
- **Arquivo (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_screen_presenter.dart`
  - **Responsabilidade:** orquestrar hidratacao, estado da aba ativa, validacao do formulario do cavalo, gerenciamento da galeria, regra de elegibilidade de ativacao e persistencia de alteracoes.
  - **Dependencias:** `ProfilingService`, `FileStorageService`, `MediaPickerDriver`, `NavigationDriver`.
  - **Estado (`signals`/providers):** `activeTab`, `horseForm`, `horseImages`, `isLoadingInitialData`, `isSyncingHorse`, `isSyncingGallery`, `isUploadingImages`, `isHorseActive`, `generalError`, `fieldErrorsByKey`, `lastSyncAt`.
  - **Computeds:** `isHorseTab`, `canActivateHorse`, `feedReadinessChecklist`, `remainingImagesCount`.
  - **Metodos:** `loadHorseProfile()`, `switchTab()`, `startHorseAutosaveListener()`, `syncHorsePatch()`, `pickAndUploadImages()`, `retryImageUpload()`, `removeImage()`, `setPrimaryImage()`, `syncGallery()`, `toggleHorseActive()`, `discardLocalErrors()`.

### 5.1.2 Views
- **Arquivo (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_screen_view.dart`
  - **Responsabilidade:** montar layout da tela de perfil e delegar a renderizacao das secoes para widgets internos da aba `Cavalo`.
  - **Props:** sem props externas (resolve presenter via provider).
  - **Dependencias de UI:** `flutter/material.dart`, `flutter_riverpod`, `signals_flutter`, `reactive_forms`, tema atual (`AppTheme`).

### 5.1.3 Widgets
- **Arquivo/Pasta (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_tab_selector/`
  - **Responsabilidade:** controle visual de abas `Cavalo` e `Dono` com callback de troca.
  - **Props:** `activeTab`, `onTabChanged`.

- **Arquivo/Pasta (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/`
  - **Responsabilidade:** container principal da tab `Cavalo` com composicao de galeria, formulario, bloco de prontidao e toggle de status.
  - **Props:** `form`, `images`, `isHorseActive`, `isLoading`, `isUploading`, `errors`, callbacks de acoes.

- **Arquivo/Pasta (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_horse_gallery/`
  - **Responsabilidade:** widget interno exclusivo da galeria do cavalo para upload, exibicao, remocao, definicao de principal e retry de erro de sincronizacao.
  - **Props:** `images`, `isUploading`, `isSyncing`, `maxImages`, `errorMessage`, `onAddImages`, `onSetPrimary`, `onRemoveImage`, `onRetrySync`.

- **Arquivo/Pasta (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab_placeholder/`
  - **Responsabilidade:** placeholder nao interativo da tab `Dono` para manter estrutura de navegacao pronta.
  - **Props:** `onGoBack` (opcional) e texto de estado.

- **Arquivo/Pasta (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_save_actions/`
  - **Responsabilidade:** **removido desta iteracao** por troca para autosave orientado a alteracao de campo.
  - **Props:** nao se aplica.

- **Estrutura de pastas (ASCII):**
```text
lib/ui/profiling/widgets/screens/profile_screen/
  index.dart
  profile_screen_view.dart
  profile_screen_presenter.dart
  profile_tab_selector/
    index.dart
    profile_tab_selector_view.dart
  profile_horse_tab/
    index.dart
    profile_horse_tab_view.dart
  profile_horse_gallery/
    index.dart
    profile_horse_gallery_view.dart
  profile_owner_tab_placeholder/
    index.dart
    profile_owner_tab_placeholder_view.dart
```

## 5.2 Core
- **Nenhum arquivo novo.**

## 5.3 REST
- **Nenhum arquivo novo.**

## 5.4 Drivers
- **Nenhum arquivo novo.**

# 6. O que deve ser modificado

- **Arquivo:** `lib/core/shared/constants/routes.dart`
  - **Mudanca:** adicionar rota `Routes.profile`.
  - **Justificativa:** expor entrada canonica para a nova tela de perfil.
  - **Impacto:** `core`

- **Arquivo:** `lib/router.dart`
  - **Mudanca:** registrar rota `Routes.profile` com `ProfileScreen` e ajustar redirecionamento pos-login/onboarding para permitir navegacao ao perfil.
  - **Justificativa:** integrar nova tela no fluxo de navegacao.
  - **Impacto:** `ui`

- **Arquivo:** `lib/ui/home/widgets/screens/home_screen/home_screen_view.dart`
  - **Mudanca:** substituir placeholder por CTA simples de acesso a `Routes.profile` (ate existir shell completo de home tabs).
  - **Justificativa:** garantir caminho de acesso funcional para validar a feature.
  - **Impacto:** `ui`

- **Arquivo:** `lib/core/profiling/interfaces/profiling_service.dart`
  - **Mudanca:** corrigir assinatura de `updateHorseGallery` para `RestResponse<GalleryDto>` e incluir contrato explicito de leitura de galeria por `horseId` (se mantida necessidade de endpoint dedicado).
  - **Justificativa:** alinhar contrato do Core aos endpoints de Profile para leitura/edicao da tab de cavalo.
  - **Impacto:** `core`

- **Arquivo:** `lib/core/profiling/dtos/entities/horse_dto.dart`
  - **Mudanca:** incluir campos opcionais necessarios para a tela (`description`, `isActive`) sem quebrar onboarding atual.
  - **Justificativa:** permitir editar e persistir estado do cavalo ativo/inativo e descricao no mesmo DTO.
  - **Impacto:** `core`

- **Arquivo:** `lib/rest/profiling/services/profiling_service.dart`
  - **Mudanca:** implementar metodos pendentes de leitura/edicao (`fetchOwnerHorses`, `updateHorse`, `updateHorseGallery` e leitura de galeria por `horseId`, se aplicavel) com foco em chamadas frequentes de autosave.
  - **Justificativa:** a tab de cavalo passa a persistir por alteracao de campo, sem acao manual de salvar.
  - **Impacto:** `rest`

- **Arquivo:** `lib/rest/profiling/mappers/horse_mapper.dart`
  - **Mudanca:** suportar campos novos (`description`, `is_active`) e leitura tolerante de contratos snake_case/camelCase.
  - **Justificativa:** evitar quebra por variacao de payload entre endpoints.
  - **Impacto:** `rest`

- **Arquivo:** `lib/rest/profiling/mappers/gallery_mapper.dart`
  - **Mudanca:** padronizar serializacao para update completo da galeria mantendo ordem como fonte da imagem principal.
  - **Justificativa:** regra de negocio define principal e ordenacao pela lista enviada.
  - **Impacto:** `rest`

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_screen_view.dart`
  - **Mudanca:** remover botao/CTA de salvar e exibir estado passivo de sincronizacao (ex.: "Sincronizando..."/"Sincronizado").
  - **Justificativa:** alinhar UX ao modelo de autosave por campo alterado.
  - **Impacto:** `ui`

# 7. O que deve ser removido

- **Arquivo:** `lib/ui/home/widgets/screens/home_screen/home_screen_view.dart`
  - **Remocao:** `Scaffold` temporario com texto fixo `Home`.
  - **Motivo:** substituir placeholder por acesso real ao fluxo de perfil durante esta entrega.
  - **Substituir por (se aplicavel):** `ProfileScreen` (via `Routes.profile`).

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_save_actions/profile_save_actions_view.dart` (**novo arquivo nao deve mais ser criado**)
  - **Remocao:** bloco de acoes de salvamento manual.
  - **Motivo:** a tela adota autosave por alteracao de `HorseDto`.
  - **Substituir por (se aplicavel):** indicador passivo de sincronizacao em `profile_screen_view.dart`.

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)
```text
ProfileScreenView
  -> ProfileScreenPresenter
    -> profilingServiceProvider
      -> ProfilingService (REST)
        -> RestClient (Dio)
          -> GET /profiling/owners/me/horses
          -> GET /profiling/horses/{horseId}/gallery
          -> PUT /profiling/horses/{horseId}
          -> PUT /profiling/horses/{horseId}/gallery
    -> fileStorageServiceProvider
      -> FileStorageService (REST)
        -> RestClient (Dio)
          -> POST /storage/images/upload
```

## 8.2 Layout/hierarquia visual (ASCII)
```text
ProfileScreen
  |- TopBar (back, title, estado de sincronizacao)
  |- ProfileTabSelector (Cavalo | Dono)
  |- HorseTabContent
  |   |- ProfileHorseGallery (widget interno dedicado)
  |   |- HorseFormSection
  |   |   |- Nome
  |   |   |- Sexo
  |   |   |- Nascimento/Idade
  |   |   |- Raca
  |   |   |- Altura
  |   |   |- Localizacao (cidade/estado)
  |   |   `- Descricao
  |   |- FeedReadinessSection (checklist de pendencias)
  |   `- ActiveToggleSection (Ativo/Inativo)
  `- Inline sync feedback
```

## 8.3 Referencias internas
- `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_screen_presenter.dart`
- `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_images/onboarding_step_images_view.dart`
- `lib/rest/profiling/services/profiling_service.dart`
- `lib/rest/profiling/mappers/horse_mapper.dart`
- `lib/rest/profiling/mappers/gallery_mapper.dart`
- `lib/core/profiling/interfaces/profiling_service.dart`

## 8.4 Referencias de tela (quando houver)
- **Google Stitch screen id:** `projects/15865350654253776765/screens/d6aa76824041495e9a184e05062908ca`
- **Decisoes de UI extraidas:**
  - Tab switch no topo com destaque visual de aba ativa (`Cavalo` ativo nesta entrega).
  - Bloco de galeria no topo com slots de imagem e acao clara de adicionar.
  - Secao `Pronto para o Feed` com checklist de criterios e feedback de pendencias.
  - Toggle destacado para `Ativar Cavalo` com texto de ajuda contextual.

# 9. Observações
- Endpoint de listagem confirmado: `GET /profiling/owners/me/horses`.
- Contrato de galeria confirmado: imagem principal definida pela ordem da lista (indice `0`), sem campo explicito `is_primary`/`position` no payload mobile.
- Campo temporal confirmado: manter contrato de `HorseDto` (sem campo `idade` direto fora do DTO).
- Decisao de navegacao para esta etapa: manter exposicao da `Profile` via fluxo existente sem introduzir shell global novo; a evolucao para tabs globais fica para etapa dedicada de navegacao.
