---
title: Opcao de camera para avatar do dono
prd: documentation\features\profiling\profile\prd.md
status: concluido
last_updated_at: 2026-03-09
---

# 1. Objetivo
Entregar a evolucao do upload de avatar da aba `Dono` na `ProfileScreen` para permitir **captura por camera** e **selecao pela galeria** no mesmo fluxo, preservando a arquitetura em camadas (`View -> Presenter -> Provider -> Service -> RestClient -> API`) e reaproveitando os contratos atuais de upload/sincronizacao do owner sem duplicar regras no frontend.

# 2. Escopo

## 2.1 In-scope
- Adicionar seletor de origem da imagem no avatar do owner com duas acoes: `Tirar foto` e `Escolher da galeria`.
- Implementar captura por camera no `MediaPickerDriver` e no driver concreto com `image_picker`.
- Reaproveitar o fluxo atual de upload (`generateUploadUrlForOwnerAvatar` + `uploadFile`) para ambos os caminhos (camera e galeria).
- Manter a acao de remover avatar e os estados de erro/carregamento ja existentes.
- Garantir compatibilidade com o autosave da aba `Dono`, sem corrida entre sync de formulario e upload de avatar.
- Ajustar configuracao iOS para permissao de camera no `Info.plist`.
- Consolidar cobertura automatizada para o fluxo de camera/source sheet e validar a feature com `dart format .`, `flutter analyze` e `flutter test`.

## 2.2 Out-of-scope
- Crop, edicao, filtros, compressao customizada ou rotacao de imagem.
- Captura de video.
- Mudancas em fluxo de avatar de outras telas (chat, onboarding, horse gallery).
- Alteracoes de endpoint backend ou de contrato REST de upload de avatar.
- Ajustes de layout estrutural da aba `Dono` fora do componente de avatar.

# 3. Requisitos

## 3.1 Funcionais
- Ao tocar no avatar (ou CTA de avatar), o usuario deve escolher entre `Tirar foto` e `Escolher da galeria`.
- Se escolher `Tirar foto`, o app deve abrir a camera, capturar 1 foto e seguir o mesmo fluxo de upload e persistencia do avatar.
- Se escolher `Escolher da galeria`, o comportamento atual deve ser preservado (selecionar imagem e subir).
- Em sucesso, o `avatar` do `OwnerDto` deve atualizar imediatamente na UI e sincronizar via `ProfilingService.updateOwner`.
- Em cancelamento do picker (camera/galeria), nenhuma alteracao deve ser persistida.
- Em falha de permissao, indisponibilidade da camera ou erro de upload/sync, a UI deve exibir erro amigavel e manter estado valido anterior.
- A acao `Remover foto` deve continuar funcional e independente da nova opcao de camera.

## 3.2 Nao funcionais
- Seguir **MVP** na camada UI com estado em `signals` e DI em `Riverpod`.
- Nao acessar plugin (`image_picker`) fora da camada `drivers`.
- Manter chamadas de upload concentradas em `FileStorageService` e `FileStorageDriver`.
- Preservar compatibilidade com chamadas atuais de `pickImages(maxImages: ...)` para nao gerar retrabalho em chat/onboarding/profile horse.
- Garantir configuracao iOS minima para camera (`NSCameraUsageDescription`) em conformidade com o `image_picker`.

# 4. O que ja existe (inventario)

> Inclua apenas itens realmente relevantes para implementar a mudanca.

## 4.1 UI (`lib/ui/`)
- **`ProfileOwnerTabPresenter`** (`lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_tab_presenter.dart`) - ja orquestra upload/remocao de avatar com galeria e sync via `ProfilingService`.
- **`ProfileOwnerAvatarFieldView`** (`lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_avatar_field/profile_owner_avatar_field_view.dart`) - componente visual do avatar e CTA atual de adicionar/trocar/remover.
- **`ProfileOwnerAvatarFieldPresenter`** (`lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_avatar_field/profile_owner_avatar_field_presenter.dart`) - resolve estado visual e labels do avatar.
- **`ProfileScreenView`** (`lib/ui/profiling/widgets/screens/profile_screen/profile_screen_view.dart`) - conecta callbacks do owner presenter para a aba `Dono`.
- **`ChatAttachmentPickerView`** (`lib/ui/conversation/widgets/screens/chat_screen/chat_attachment_picker/chat_attachment_picker_view.dart`) - referencia interna de padrao para `showModalBottomSheet` com acoes de escolha.

## 4.2 Core (`lib/core/`)
- **`MediaPickerDriver`** (`lib/core/shared/interfaces/media_picker_driver.dart`) - contrato atual para selecao de imagens pela galeria.
- **`FileStorageService`** (`lib/core/storage/interfaces/file_storage_service.dart`) - contrato para gerar signed upload URL de avatar.
- **`ProfilingService`** (`lib/core/profiling/interfaces/profiling_service.dart`) - contrato para persistir owner com avatar atualizado.
- **`OwnerDto`** (`lib/core/profiling/dtos/entities/owner_dto.dart`) - entidade que carrega o campo `avatar`.

## 4.3 REST (`lib/rest/`)
- **`FileStorageService`** (`lib/rest/services/file_storage_service.dart`) - implementa `generateUploadUrlForOwnerAvatar` em `/storage/upload/owners/{owner_id}/avatar`.
- **`ProfilingService`** (`lib/rest/services/profiling_service.dart`) - persiste owner via `PUT /profiling/owners/me`.
- **`OwnerMapper`** (`lib/rest/mappers/profiling/owner_mapper.dart`) - serializa/desserializa `avatar` no payload de owner.

## 4.4 Drivers (`lib/drivers/`)
- **`ImagePickerMediaPickerDriver`** (`lib/drivers/media-picker-driver/image-picker/image_picker_media_picker_driver.dart`) - implementa selecao por galeria usando `image_picker`.
- **`SupabaseFileStorageDriver`** (`lib/drivers/file-storage-driver/supabase/supabase_file_storage_provider.dart`) - executa upload de arquivo para signed URL.

# 5. O que deve ser criado

> Liste apenas arquivos novos. Para cada arquivo, detalhe assinatura, responsabilidade, dependencias e estado quando aplicavel.

## 5.1 UI

### 5.1.1 Presenters/Stores
- **Arquivo (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_avatar_field/profile_owner_avatar_source_sheet/profile_owner_avatar_source_sheet_presenter.dart`
  - **Responsabilidade:** definir opcoes de origem de avatar (`camera` e `gallery`), opcao destrutiva de remocao e labels de exibicao para o bottom sheet.
  - **Dependencias:** somente tipos Dart puros.
  - **Estado (`signals`/providers):** nao se aplica.
  - **Computeds:** nao se aplica.
  - **Metodos:** `buildOptions({required bool showGalleryOption, required bool showRemoveOption})`, `resolveTitle()`.

### 5.1.2 Views
- **Arquivo (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_avatar_field/profile_owner_avatar_source_sheet/profile_owner_avatar_source_sheet_view.dart`
  - **Responsabilidade:** exibir `showModalBottomSheet` com opcoes `Tirar foto`, `Escolher da galeria` e, quando houver avatar atual, `Remover foto`, retornando a acao selecionada para a view do avatar.
  - **Props:** `onPickFromCamera`, `onPickFromGallery`, `showRemoveOption`, `onRemovePhoto`.
  - **Dependencias de UI:** `flutter/material.dart`, `AppTheme`.

### 5.1.3 Widgets
- **Arquivo/Pasta (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_avatar_field/profile_owner_avatar_source_sheet/`
  - **Responsabilidade:** encapsular a UX de selecao de origem da foto sem poluir `ProfileOwnerAvatarFieldView`.
  - **Props:** callbacks de acao (`camera` e `gallery`).
  - **Widgets internos:** nenhum.
  - **Estrutura de pastas (ASCII):**
```text
profile_owner_avatar_source_sheet/
  index.dart
  profile_owner_avatar_source_sheet_presenter.dart
  profile_owner_avatar_source_sheet_view.dart
```

## 5.2 Core
- **Nenhum arquivo novo.**

## 5.3 REST
- **Nenhum arquivo novo.**

## 5.4 Drivers
- **Nenhum arquivo novo.**

# 6. O que deve ser modificado

> Liste apenas arquivos existentes. Mudancas em arquivo novo ficam na secao 5.

- **Arquivo:** `lib/core/shared/interfaces/media_picker_driver.dart`
  - **Mudanca:** evoluir contrato para suportar captura por camera, mantendo `pickImages(maxImages: ...)` compativel com os call sites existentes.
  - **Justificativa:** a camada `ui` precisa solicitar camera sem depender de `image_picker` diretamente.
  - **Camada:** `core`

- **Arquivo:** `lib/drivers/media-picker-driver/image-picker/image_picker_media_picker_driver.dart`
  - **Mudanca:** implementar captura por camera com `ImageSource.camera`, incluindo tratamento de cancelamento e plataforma nao suportada alinhado ao comportamento atual.
  - **Justificativa:** concretizar o novo contrato do `MediaPickerDriver` na camada de infraestrutura.
  - **Camada:** `drivers`

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_tab_presenter.dart`
  - **Mudanca:** adicionar fluxo dedicado para `camera` (ex.: `captureAndUploadAvatar`) e refatorar o metodo privado de upload para receber origem (`camera`/`gallery`) sem duplicar codigo de sync.
  - **Justificativa:** manter a regra de negocio de avatar centralizada no presenter da aba `Dono`.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_tab_view.dart`
  - **Mudanca:** receber e propagar callback de captura por camera para a secao de formulario.
  - **Justificativa:** manter composicao da aba desacoplada da logica de upload.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_form_section_view.dart`
  - **Mudanca:** receber e repassar callbacks de `camera` e `gallery` para o componente de avatar.
  - **Justificativa:** manter o form section apenas como ponto de composicao.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_avatar_field/profile_owner_avatar_field_view.dart`
  - **Mudanca:** trocar acao direta de upload por abertura de source sheet e acionar callbacks distintos (`camera`, `gallery` ou `remover`).
  - **Justificativa:** atender requisito de UX com duas opcoes de origem sem acoplamento de plugin na UI.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_avatar_field/profile_owner_avatar_field_presenter.dart`
  - **Mudanca:** ajustar labels/estado da CTA para refletir fluxo com seletor de origem (sem perder estados `Enviando foto...`, `Adicionar foto`, `Trocar foto`).
  - **Justificativa:** manter regra de texto da UI centralizada no presenter local.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_screen_view.dart`
  - **Mudanca:** passar novo callback de camera do `ProfileOwnerTabPresenter` para `ProfileOwnerTab`.
  - **Justificativa:** conectar feature no container sem alterar contrato de outras abas.
  - **Camada:** `ui`

- **Arquivo:** `ios/Runner/Info.plist`
  - **Mudanca:** adicionar `NSCameraUsageDescription` com copy adequada ao contexto de avatar do perfil.
  - **Justificativa:** requisito de plataforma do `image_picker` para captura por camera no iOS.
  - **Camada:** `drivers`

# 7. O que deve ser removido

> Remocoes precisam ser seguras (sem quebrar fluxo, import ou contrato publico). Se houver substituicao, aponte o novo caminho.

- **Nenhuma remocao prevista nesta iteracao.**

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)
```text
ProfileOwnerAvatarFieldView
  -> ProfileOwnerAvatarSourceSheetView (camera | gallery | remove)
    -> ProfileOwnerTabPresenter
      -> MediaPickerDriver (camera/gallery)
      -> FileStorageService.generateUploadUrlForOwnerAvatar(...)
      -> FileStorageDriver.uploadFile(...)
      -> ProfilingService.updateOwner(...)
      -> RestClient (Dio)
      -> API
```

## 8.2 Layout/hierarquia visual (ASCII)
```text
ProfileOwnerTab
  |- Dados Pessoais
  |   |- Avatar Field
  |   |   |- Circular avatar
  |   |   |- Camera badge
  |   |   `- CTA (Adicionar/Trocar)
  |   `- Avatar Source Sheet (on tap)
  |       |- Tirar foto
   |       |- Escolher da galeria
   |       `- Remover foto (quando houver avatar)
  `- Demais campos (nome, email, telefone, bio)
```

## 8.3 Sequencia final de captura por camera (ASCII)
```ASCII
Usuario
  -> Avatar Field tap
  -> Source Sheet escolhe "Tirar foto"
  -> ProfileOwnerTabPresenter.captureAndUploadAvatar()
  -> MediaPickerDriver.pickImageFromCamera()
  -> FileStorageService.generateUploadUrlForOwnerAvatar()
  -> FileStorageDriver.uploadFile()
  -> ProfilingService.updateOwner()
  -> UI atualiza avatarUrl / estados de sync
```

## 8.4 Referencias internas
- `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_tab_presenter.dart` (fluxo atual de upload/sync do avatar)
- `lib/ui/conversation/widgets/screens/chat_screen/chat_attachment_picker/chat_attachment_picker_view.dart` (padrao de bottom sheet com acoes)
- `lib/drivers/media-picker-driver/image-picker/image_picker_media_picker_driver.dart` (integracao atual com `image_picker`)
- `lib/rest/services/file_storage_service.dart` (geracao de signed URL de avatar)

## 8.5 Referencias de tela (quando houver)
- **Google Stitch screen id:** `projects/15865350654253776765/screens/f4cfe7687bd448bca78b5ce672360e86`
- **Decisoes de UI extraidas:**
  - Avatar permanece como elemento de destaque no topo da secao `Dados Pessoais`.
  - Badge de camera no avatar deve ser preservada como affordance principal de troca de foto.
  - Nova escolha de origem entra como interacao complementar (bottom sheet), sem alterar hierarquia da tela base.
  - A acao de remover foto foi consolidada dentro do source sheet e mantida como CTA dedicado abaixo do avatar para reduzir friccao em cenarios recorrentes.

# 9. Validacao final
- `dart format .` executado com sucesso para garantir padrao Dart nos arquivos da feature e testes relacionados.
- `flutter analyze` executado sem warnings ou erros remanescentes.
- `flutter test` executado com sucesso, incluindo cobertura adicional para camera/source sheet.
- Cobertura automatizada consolidada em `test/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_tab_presenter_test.dart` e `test/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_avatar_field/profile_owner_avatar_source_sheet/profile_owner_avatar_source_sheet_view_test.dart`.

# 10. Decisoes registradas
- `Remover foto` permanece disponivel tanto no CTA dedicado quanto dentro do source sheet para manter descoberta e rapidez de uso.
- `NSCameraUsageDescription` final definido como copy objetiva focada em avatar de perfil.
