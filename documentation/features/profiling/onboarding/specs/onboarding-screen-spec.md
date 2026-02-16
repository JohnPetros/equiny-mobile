---
title: Onboarding obrigatorio do primeiro cavalo
status: em progresso
last_updated_at: 2026-02-16
---

# 1. Objetivo
Implementar o fluxo de onboarding obrigatorio do primeiro cavalo no app mobile em formato wizard de 7 etapas, conectando UI MVP (`View` + `Presenter`) com servicos REST de criacao de cavalo e galeria de imagens, garantindo validacao por etapa, bloqueio de acesso a experiencia principal ate conclusao, reinicio do fluxo ao reabrir o app e reaproveitamento dos contratos/abstracoes existentes nas camadas `core`, `rest`, `ui` e `drivers`.

# 2. Escopo

## 2.1 In-scope
- Wizard com 7 etapas: nome, nascimento (mes/ano), raca, sexo, altura, localizacao (cidade/estado), imagens.
- Validacao por etapa para avancar e navegacao de voltar para editar.
- Conclusao bloqueada ate existir `horse` valido + pelo menos 1 imagem.
- Integracao com APIs para `createHorse`, upload de imagens e vinculacao de galeria.
- Substituicao da rota placeholder `Routes.onboarding` pela tela real de onboarding.
- Persistencia local de flag de conclusao para gate de navegacao.

## 2.2 Out-of-scope
- SDK/infra de analytics (sem `AnalyticsDriver` nesta fase).
- Cadastro de multiplos cavalos durante onboarding.
- Upload de videos e documentos.
- Campos avancados de perfil do cavalo fora do PRD.

# 3. Requisitos

## 3.1 Funcionais
- O usuario recem-cadastrado deve entrar automaticamente no onboarding.
- O fluxo nao deve permitir `skip`.
- Cada etapa deve validar campos obrigatorios antes de avancar.
- Etapa 3 deve usar lista fixa de racas (sem busca no MVP).
- Etapa 7 deve permitir upload, retry e remocao de imagens.
- Conclusao deve criar cavalo, vincular galeria e redirecionar para `Routes.home`.
- Se o app fechar durante onboarding incompleto, o fluxo reabre na etapa 1.

## 3.2 Nao funcionais
- Manter padrao arquitetural MVP + `Riverpod` + `Signals`.
- Reaproveitar interfaces/DTOs existentes antes de criar novos.
- Isolar bibliotecas de dispositivo (image picker) por `driver`.
- Manter mensagens de erro claras por campo/etapa.

# 4. O que ja existe (inventario)

## 4.1 UI (`lib/ui/`)
- **`SignUpScreenPresenter`** (`lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart`) - redireciona para `Routes.onboarding` apos cadastro.
- **`SignUpScreenView`** (`lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_view.dart`) - referencia de estrutura MVP de tela.
- **`SignUpFormView`** (`lib/ui/auth/widgets/screens/sign_up_screen/sign_up_form/sign_up_form_view.dart`) - referencia de validacao com `reactive_forms`.

## 4.2 Core (`lib/core/`)
- **`HorseDto`** (`lib/core/profiling/dtos/entities/horse_dto.dart`) - DTO com campos necessarios do cavalo para onboarding.
- **`LocationDto`** (`lib/core/profiling/dtos/structures/location_dto.dart`) - cidade/estado para payload do cavalo.
- **`ImageDto`** (`lib/core/profiling/dtos/structures/image_dto.dart`) - metadados basicos de imagem.
- **`GalleryDto`** (`lib/core/profiling/dtos/structures/gallery_dto.dart`) - contrato de galeria existente para evolucao.
- **`ProfilingService`** (`lib/core/profiling/interfaces/profiling_service.dart`) - contrato para criar cavalo/galeria.
- **`FileStorageService`** (`lib/core/storage/interfaces/file_storage_service.dart`) - contrato de upload de imagem.
- **`Routes`** (`lib/core/shared/constants/routes.dart`) - rotas base do app.
- **`CacheKeys`** (`lib/core/shared/constants/cache_keys.dart`) - chaves de cache de sessao.
- **`RestResponse`** (`lib/core/shared/responses/rest_response.dart`) - wrapper padrao para resposta REST.

## 4.3 REST (`lib/rest/`)
- **`DioRestClient`** (`lib/rest/dio/dio_rest_client.dart`) - adapter HTTP concreto.
- **`restClientProvider`** (`lib/rest/rest_client.dart`) - composicao do `RestClient` com `EnvDriver`.
- **`AuthService`** (`lib/rest/auth/services/auth_service.dart`) - referencia de implementacao de service REST no projeto.
- **`authServiceProvider`** (`lib/rest/services.dart`) - ponto central de providers da camada REST.

## 4.4 Drivers (`lib/drivers/`)
- **`GoRouterNavigationDriver`** (`lib/drivers/navigation-driver/go-router/go_router_navigation_driver.dart`) - adapter de navegacao usado por presenters.
- **`SharedPreferencesCacheDriver`** (`lib/drivers/cache-driver/shared-prefences/shared_preferences_cache_driver.dart`) - persistencia local de flags e sessao.
- **`DotEnvDriver`** (`lib/drivers/env-driver/dto-env/dot_env_driver.dart`) - leitura de configuracao ambiente.

# 5. O que deve ser criado

## 5.1 UI

### 5.1.1 Presenters/Stores
- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_screen_presenter.dart`
  - **Responsabilidade:** orquestrar etapas, validacao, upload, criacao de cavalo, vinculacao de galeria e navegacao final.
  - **Dependencias:** `ProfilingService`, `FileStorageService`, `MediaPickerDriver`, `NavigationDriver`, `CacheDriver`.
  - **Estado (`signals`/providers):** `form`, `currentStepIndex`, `isSubmitting`, `isUploadingImages`, `submitAttempted`, `generalError`, `uploadedImages`.
  - **Computeds:** `isFirstStep`, `isLastStep`, `currentStepLabel`, `canAdvance`, `canFinish`.
  - **Metodos:** `buildForm()`, `validateCurrentStep()`, `goNextStep()`, `goPreviousStep()`, `pickAndUploadImages()`, `removeImage()`, `retryImageUpload()`, `submitOnboarding()`.

- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_screen_presenter.dart` (provider)
  - **Responsabilidade:** expor `onboardingScreenPresenterProvider` via `Riverpod`.
  - **Dependencias:** providers de services/drivers usados no presenter.

### 5.1.2 Views
- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_screen_view.dart`
  - **Responsabilidade:** montar estrutura de tela, renderizar etapa atual e CTA de navegacao.
  - **Props:** sem props externas (resolve presenter via provider).
  - **Dependencias de UI:** `flutter/material.dart`, `flutter_riverpod`, `signals_flutter`, `reactive_forms`.

- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_progress_header/onboarding_progress_header_view.dart`
  - **Responsabilidade:** renderizar cabecalho com progresso (`Etapa X de 7`) e botao voltar.
  - **Props:** `stepLabel`, `title`, `subtitle`, `onBack`.
  - **Dependencias de UI:** componentes basicos de `Material` e tema compartilhado.

- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_name/onboarding_step_name_view.dart`
  - **Responsabilidade:** etapa 1 (nome do cavalo).
  - **Props:** `form`, `submitAttempted`.
  - **Dependencias de UI:** `reactive_forms`.

- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_birth/onboarding_step_birth_view.dart`
  - **Responsabilidade:** etapa 2 (mes/ano de nascimento).
  - **Props:** `form`, `submitAttempted`, `availableMonths`, `availableYears`.
  - **Dependencias de UI:** `reactive_forms`.

- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_breed/onboarding_step_breed_view.dart`
  - **Responsabilidade:** etapa 3 (raca em lista fixa).
  - **Props:** `form`, `submitAttempted`, `breedOptions`.
  - **Dependencias de UI:** `reactive_forms`.

- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_sex/onboarding_step_sex_view.dart`
  - **Responsabilidade:** etapa 4 (sexo).
  - **Props:** `form`, `submitAttempted`.
  - **Dependencias de UI:** `reactive_forms`.

- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_height/onboarding_step_height_view.dart`
  - **Responsabilidade:** etapa 5 (altura em metros).
  - **Props:** `form`, `submitAttempted`.
  - **Dependencias de UI:** `flutter/material.dart`, `reactive_forms`.

- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/onboarding_step_location_view.dart`
  - **Responsabilidade:** etapa 6 (cidade/estado).
  - **Props:** `form`, `submitAttempted`.
  - **Dependencias de UI:** `reactive_forms`.

- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_images/onboarding_step_images_view.dart`
  - **Responsabilidade:** etapa 7 (galeria, upload, retry e remocao).
  - **Props:** `images`, `isUploading`, `errorMessage`, `onAddImages`, `onRetry`, `onRemoveImage`.
  - **Dependencias de UI:** `flutter/material.dart`.

- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_actions/onboarding_actions_view.dart`
  - **Responsabilidade:** CTA inferior (`Voltar`, `Avancar`, `Concluir cadastro`) com estados de habilitacao/loading.
  - **Props:** `isFirstStep`, `isLastStep`, `canAdvance`, `canFinish`, `isLoading`, `onBack`, `onNext`, `onFinish`.
  - **Dependencias de UI:** `flutter/material.dart`.

### 5.1.3 Widgets
- **Arquivo/Pasta (nova):** `lib/ui/profiling/widgets/screens/onboarding_screen/`
  - **Responsabilidade:** conter tela principal e subwidgets por etapa seguindo MVP.
  - **Props:** sem props externas no widget pai.
- **Widgets internos:** header de progresso, steps 1-7 e barra de acoes.
  - **Estrutura de pastas (ASCII):**
```text
lib/ui/profiling/widgets/screens/onboarding_screen/
  index.dart
  onboarding_screen_view.dart
  onboarding_screen_presenter.dart
  onboarding_progress_header/
    index.dart
    onboarding_progress_header_view.dart
  onboarding_step_name/
    index.dart
    onboarding_step_name_view.dart
  onboarding_step_birth/
    index.dart
    onboarding_step_birth_view.dart
  onboarding_step_breed/
    index.dart
    onboarding_step_breed_view.dart
  onboarding_step_sex/
    index.dart
    onboarding_step_sex_view.dart
  onboarding_step_height/
    index.dart
    onboarding_step_height_view.dart
  onboarding_step_location/
    index.dart
    onboarding_step_location_view.dart
  onboarding_step_images/
    index.dart
    onboarding_step_images_view.dart
  onboarding_actions/
    index.dart
    onboarding_actions_view.dart
```

## 5.2 Core
- **Arquivo:** `lib/core/shared/interfaces/media_picker_driver.dart`
  - **Tipo:** `interface`
  - **Contratos/assinaturas:** `Future<List<File>> pickImages({required int maxImages})`
  - **Responsabilidade:** abstrair selecao de imagens para manter UI independente de SDK.

## 5.3 REST
- **Arquivo:** `lib/rest/profiling/services/profiling_service.dart`
  - **Service/Client:** implementacao de `ProfilingService` usando `RestClient`.
  - **Metodos:** `createHorse(...)`, `createHorseGallery(...)`.
  - **Entrada/Saida:** `HorseDto`/`GalleryDto` <-> `RestResponse<HorseDto|GalleryDto>`.

- **Arquivo:** `lib/rest/storage/services/file_storage_service.dart`
  - **Service/Client:** implementacao de `FileStorageService` com upload multipart.
  - **Metodos:** `uploadImageFiles({required List<File> files})`.
  - **Entrada/Saida:** `List<File>` <-> `RestResponse<List<ImageDto>>`.

- **Arquivo:** `lib/rest/profiling/mappers/horse_mapper.dart`
  - **Service/Client:** mapper de payload/response de cavalo.
  - **Metodos:** `toPayload(HorseDto)`, `toDto(Json)`.
  - **Entrada/Saida:** `HorseDto` <-> `Json`.

- **Arquivo:** `lib/rest/profiling/mappers/gallery_mapper.dart`
  - **Service/Client:** mapper de payload/response de galeria.
  - **Metodos:** `toPayload(GalleryDto)`, `toDto(Json)`.
  - **Entrada/Saida:** `GalleryDto` <-> `Json`.

- **Arquivo:** `lib/rest/storage/mappers/image_mapper.dart`
  - **Service/Client:** mapper de resposta de upload.
  - **Metodos:** `toDtoList(Json)`.
  - **Entrada/Saida:** `Json` -> `List<ImageDto>`.

## 5.4 Drivers
- **Arquivo:** `lib/drivers/media-picker-driver/image-picker/image_picker_media_picker_driver.dart`
  - **Adapter/Driver:** implementacao concreta de `MediaPickerDriver` com `image_picker`.
  - **Responsabilidade:** abrir galeria/camera e retornar lista de `File`.
  - **Dependencias:** `image_picker`, `dart:io`.

- **Arquivo:** `lib/drivers/media-picker-driver/index.dart`
  - **Adapter/Driver:** provider Riverpod para `MediaPickerDriver`.
  - **Responsabilidade:** composicao central da dependencia para presenter.
  - **Dependencias:** `flutter_riverpod`, `MediaPickerDriver`, implementacao concreta.

# 6. O que deve ser modificado

- **Arquivo:** `lib/router.dart`
  - **Mudanca:** trocar placeholder da rota `Routes.onboarding` pela `OnboardingScreenView` e adicionar guard de redirecionamento por `accessToken` + `onboardingCompleted`.
  - **Justificativa:** garantir obrigatoriedade do onboarding antes da experiencia principal.
  - **Impacto:** `ui`

- **Arquivo:** `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart`
  - **Mudanca:** apos cadastro, persistir `onboardingCompleted=false` antes de navegar para `Routes.onboarding`.
  - **Justificativa:** habilitar controle de fluxo entre cadastro e onboarding.
  - **Impacto:** `ui`

- **Arquivo:** `lib/core/shared/constants/cache_keys.dart`
  - **Mudanca:** adicionar chave `onboardingCompleted`.
  - **Justificativa:** gate de navegacao e conclusao do fluxo.
  - **Impacto:** `core`

- **Arquivo:** `lib/core/storage/interfaces/file_storage_service.dart`
  - **Mudanca:** ajustar retorno para `Future<RestResponse<List<ImageDto>>>`.
  - **Justificativa:** contrato atual retorna `String` e nao cobre upload multiplo com metadados.
  - **Impacto:** `core`

- **Arquivo:** `lib/core/profiling/dtos/structures/gallery_dto.dart`
  - **Mudanca:** evoluir para DTO concreto com `horseId` e `images`.
  - **Justificativa:** permitir vinculacao explicita da galeria ao cavalo criado.
  - **Impacto:** `core`

- **Arquivo:** `lib/core/shared/constants/routes.dart`
  - **Mudanca:** adicionar `home` para destino apos conclusao do onboarding.
  - **Justificativa:** evitar string hardcoded e padronizar navegacao final.
  - **Impacto:** `core`

- **Arquivo:** `lib/rest/services.dart`
  - **Mudanca:** registrar `profilingServiceProvider` e `fileStorageServiceProvider`.
  - **Justificativa:** disponibilizar dependencias para o presenter via `Riverpod`.
  - **Impacto:** `rest`

- **Arquivo:** `pubspec.yaml`
- **Mudanca:** adicionar dependencia `image_picker`.
  - **Justificativa:** requisito de selecao de imagens na etapa 7.
  - **Impacto:** `drivers`

# 7. O que deve ser removido

- **Arquivo:** `lib/router.dart`
  - **Remocao:** `Scaffold` temporario da rota `Routes.onboarding` com `Text('Criar cavalo')`.
  - **Motivo:** substituir fluxo falso pela tela real de onboarding obrigatorio.
  - **Substituir por (se aplicavel):** `OnboardingScreen`

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)
```text
OnboardingScreenView
  -> OnboardingScreenPresenter
    -> validateCurrentStep()
    -> MediaPickerDriver.pickImages()
    -> FileStorageService.uploadImageFiles(files)
      -> RestClient (multipart)
      -> API /storage/images/upload
    -> ProfilingService.createHorse(horse)
      -> RestClient
      -> API /profiling/horses
    -> ProfilingService.createHorseGallery(gallery)
      -> RestClient
      -> API /profiling/horses/{horseId}/gallery
    -> CacheDriver.set(onboardingCompleted, true)
    -> NavigationDriver.goTo(Routes.home)
```

## 8.2 Layout/hierarquia visual (ASCII)
```text
OnboardingScreen
  |- ProgressHeader (Etapa X de 7 + back)
  |- StepContent (IndexedStack)
  |   |- Step1 Nome
  |   |- Step2 Nascimento
  |   |- Step3 Raca
  |   |- Step4 Sexo
  |   |- Step5 Altura
  |   |- Step6 Localizacao
  |   `- Step7 Imagens
  `- Footer CTA
      |- Voltar
      `- Avancar/Concluir
```

## 8.3 Referencias internas
- `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_presenter.dart`
- `lib/ui/auth/widgets/screens/sign_up_screen/sign_up_screen_view.dart`
- `lib/rest/auth/services/auth_service.dart`
- `lib/rest/auth/mappers/jwt_mapper.dart`
- `documentation/architecture.md`
- `documentation/rules/rules.md`

## 8.4 Referencias de tela (quando houver)
- **Google Stitch screen id:** `projects/15865350654253776765/screens/115ad2c35a484a26881579a4c6f1cb49` (etapa 1)
- **Google Stitch screen id:** `projects/15865350654253776765/screens/49e5776b2e8c4efbbd233f436942fed9` (etapa 2)
- **Google Stitch screen id:** `projects/15865350654253776765/screens/26ea9f7b2c1446a2af737896ae21a0fe` (etapa 3)
- **Google Stitch screen id:** `projects/15865350654253776765/screens/e392c9a16f6f4ba69c9f791ed67d4ad4` (etapa 4)
- **Google Stitch screen id:** pendente (etapa 5 - altura)
- **Google Stitch screen id:** `projects/15865350654253776765/screens/ee253a51bcb44dda8873671bba25c0ae` (etapa 6)
- **Google Stitch screen id:** `projects/15865350654253776765/screens/05a195498f2542acb3ae9d294b6305d4` (etapa 7)
- **Decisoes de UI extraidas:**
- Header com progresso explicito por etapa (`Etapa X de 7`).
  - CTA de navegacao fixa no rodape (`Voltar` + `Avancar/Concluir`).
  - Feedback de erro por etapa/campo e feedback visual de upload na etapa de imagens.
