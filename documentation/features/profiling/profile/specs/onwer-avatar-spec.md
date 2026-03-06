---
title: Upload de avatar do dono na aba de perfil
prd: ../prd.md
status: concluido
last_updated_at: 2026-02-21
---

# 1. Objetivo
Entregar o fluxo completo de **upload, troca e remocao** do `avatar` do owner na aba `Dono` da `ProfileScreen`, conectando UI e infraestrutura existente (`MediaPickerDriver`, `FileStorageService`, `FileStorageDriver` e `ProfilingService`) para persistir a imagem no storage e refletir o estado no `OwnerDto`, mantendo o padrao em camadas `View -> Presenter -> Provider -> Service -> RestClient -> API` sem logica de rede na `View`.

# 2. Escopo

## 2.1 In-scope
- Tornar o bloco de avatar da aba `Dono` interativo (selecionar imagem da galeria, trocar e remover).
- Implementar no `ProfileOwnerTabPresenter` o fluxo de upload: selecionar arquivo, solicitar signed upload URL, enviar arquivo para storage e sincronizar owner.
- Implementar `generateUploadUrlForOwnerAvatar` no `FileStorageService` REST com `POST /storage/upload/owners/{owner_id}/avatar`.
- Exibir estados de carregamento e erro do avatar sem bloquear edicao dos demais campos do formulario.
- Recarregar/hidratar estado local do owner apos sucesso para manter UI consistente com backend.

## 2.2 Out-of-scope
- Edicao de foto via camera, crop, rotacao ou compressao customizada.
- Alteracoes de contrato backend fora das rotas ja previstas para upload e update de owner.
- Reestruturacao da aba `Dono` fora do trecho de avatar.
- Mudancas no fluxo da aba `Cavalo`, Feed, Matches, Chat ou Auth.

# 3. Requisitos

## 3.1 Funcionais
- Ao tocar no avatar sem imagem, deve abrir selecao de imagem da galeria.
- Ao tocar no avatar com imagem, deve permitir **trocar** ou **remover**.
- Em upload bem-sucedido, o owner deve ter `avatar` atualizado e a UI deve exibir a nova imagem imediatamente.
- Em remocao, o owner deve persistir `avatar` vazio/nulo e a UI deve voltar para placeholder.
- Sempre que o `avatar` mudar (upload, troca ou remocao), o presenter deve persistir o owner via `ProfilingService.updateOwner`.
- Em falha (geracao de URL, upload ou sync), a UI deve exibir mensagem de erro e manter estado anterior valido.
- O upload deve usar apenas o contrato `generateUploadUrlForOwnerAvatar` + `uploadFile` (sem chamada direta ao SDK de storage fora do driver).

## 3.2 Nao funcionais
- Seguir `MVP` com estado no `Presenter` usando `signals` e DI por `Riverpod`.
- Reutilizar `FileStorageService`, `FileStorageDriver`, `MediaPickerDriver`, `OwnerDto` e `ProfilingService` existentes.
- Manter responsabilidade por camada (`core` sem framework, `rest` sem regra de negocio, `drivers` isolando bibliotecas externas).
- Garantir consistencia de estado para evitar race condition entre `autosave` de formulario e upload de avatar.

# 4. O que ja existe (inventario)

> Inclua apenas itens realmente relevantes para implementar a mudanca.

## 4.1 UI (`lib/ui/`)
- **`ProfileOwnerTabPresenter`** (`lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_tab_presenter.dart`) - carrega/sincroniza owner e ja possui estado reativo da aba `Dono`.
- **`ProfileOwnerFormSectionView`** (`lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_form_section_view.dart`) - contem avatar em modo **readonly** (`_AvatarReadOnlyField`) e formulario de dados pessoais.
- **`ProfileScreenView`** (`lib/ui/profiling/widgets/screens/profile_screen/profile_screen_view.dart`) - integra os presenters das abas e injeta props da aba `Dono`.
- **`ProfileHorseTabPresenter`** (`lib/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_tab_presenter.dart`) - referencia de fluxo de upload com `MediaPickerDriver` + `FileStorageService` + `FileStorageDriver`.

## 4.2 Core (`lib/core/`)
- **`OwnerDto`** (`lib/core/profiling/dtos/entities/owner_dto.dart`) - ja contem campo `avatar` e sera reutilizado na sincronizacao.
- **`ProfilingService`** (`lib/core/profiling/interfaces/profiling_service.dart`) - contrato possui `fetchOwner` e `updateOwner`.
- **`FileStorageService`** (`lib/core/storage/interfaces/file_storage_service.dart`) - contrato ja possui `generateUploadUrlForOwnerAvatar`.
- **`FileStorageDriver`** (`lib/core/storage/interfaces/file_storage_driver.dart`) - contrato de upload de arquivo assinado.
- **`MediaPickerDriver`** (`lib/core/shared/interfaces/media_picker_driver.dart`) - contrato para selecao de imagens.

## 4.3 REST (`lib/rest/`)
- **`FileStorageService`** (`lib/rest/services/file_storage_service.dart`) - implementa uploads de anexos, galeria de cavalo e avatar de owner via signed URL.
- **`ProfilingService`** (`lib/rest/services/profiling_service.dart`) - persiste owner via `PUT /profiling/owners`.
- **`OwnerMapper`** (`lib/rest/mappers/auth/owner_mapper.dart`) - serializa/desserializa campo `avatar` no payload de owner.

## 4.4 Drivers (`lib/drivers/`)
- **`SupabaseFileStorageDriver`** (`lib/drivers/file-storage-driver/supabase/supabase_file_storage_provider.dart`) - executa upload em signed URL via `uploadFile`.
- **`ImagePickerMediaPickerDriver`** (`lib/drivers/media-picker-driver/image-picker/image_picker_media_picker_driver.dart`) - seleciona imagem da galeria com `pickImages(maxImages: 1)`.

# 5. O que deve ser criado

> Liste apenas arquivos novos. Para cada arquivo, detalhe assinatura, responsabilidade, dependencias e estado quando aplicavel.

## 5.1 UI

### 5.1.1 Presenters/Stores
- **Arquivo (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_avatar_field/profile_owner_avatar_field_presenter.dart`
  - **Responsabilidade:** encapsular regras de apresentacao do avatar (placeholder, label de acao, estado visual de erro/upload) sem chamada de servico.
  - **Dependencias:** apenas tipos Dart/Flutter basicos.
  - **Estado (`signals`/providers):** nao se aplica (stateless presenter utilitario).
  - **Computeds:** nao se aplica.
  - **Metodos:** `resolveAvatarUrl(...)`, `isAvatarAvailable(...)`, `resolveActionLabel(...)`.

### 5.1.2 Views
- **Arquivo (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_avatar_field/profile_owner_avatar_field_view.dart`
  - **Responsabilidade:** renderizar avatar clicavel, indicador de upload e CTA de acao (`Adicionar foto`, `Trocar foto`, `Remover foto`).
  - **Props:** `avatarUrl`, `isUploading`, `errorMessage`, `onPickAvatar`, `onReplaceAvatar`, `onRemoveAvatar`.
  - **Dependencias de UI:** `flutter/material.dart`, `AppTheme`.

### 5.1.3 Widgets
- **Arquivo/Pasta (novo):** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_avatar_field/`
  - **Responsabilidade:** concentrar o widget interno do avatar, mantendo `ProfileOwnerFormSectionView` focada na composicao da secao.
  - **Props:** herdadas da aba `Dono` via `ProfileOwnerFormSectionView`.
  - **Widgets internos:** nenhum.
  - **Estrutura de pastas (ASCII):**
```text
profile_owner_avatar_field/
  index.dart
  profile_owner_avatar_field_presenter.dart
  profile_owner_avatar_field_view.dart
```

## 5.2 Core
- **Nenhum arquivo novo.**

## 5.3 REST
- **Nenhum arquivo novo.**

## 5.4 Drivers
- **Nenhum arquivo novo.**

# 6. O que deve ser modificado

> Liste apenas arquivos existentes. Mudancas em arquivo novo ficam na secao 5.

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_tab_presenter.dart`
  - **Mudanca:** injetar `FileStorageService`, `FileStorageDriver` e `MediaPickerDriver`; adicionar sinais de avatar (`ownerAvatarUrl`, `isUploadingAvatar`, `avatarError`); implementar metodos `pickAndUploadAvatar()`, `replaceAvatar()`, `removeAvatar()`, `syncOwnerAvatar(...)` e hidratar avatar no `loadOwner()`, garantindo chamada de `ProfilingService.updateOwner` a cada mudanca efetiva de avatar.
  - **Justificativa:** concentrar toda orquestracao do fluxo de avatar no presenter da aba `Dono`, preservando padrao `MVP`.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_tab_view.dart`
  - **Mudanca:** receber props de estado/acoes do avatar e encaminhar para `ProfileOwnerFormSection`.
  - **Justificativa:** manter composicao da aba sem acoplamento a regras de upload.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_form_section_view.dart`
  - **Mudanca:** substituir `_AvatarReadOnlyField` pelo novo widget `ProfileOwnerAvatarField`; remover implementacao privada de avatar readonly.
  - **Justificativa:** separar componente complexo em pasta propria, alinhado as regras da camada UI.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/index.dart`
  - **Mudanca:** atualizar export/typedef para nova assinatura da `View` com props de avatar.
  - **Justificativa:** manter API publica do componente consistente com o novo fluxo.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_screen_view.dart`
  - **Mudanca:** passar callbacks e estados de avatar do `ownerTabPresenter` para `ProfileOwnerTab`.
  - **Justificativa:** conectar a feature no container da tela sem quebrar o comportamento atual das abas.
  - **Camada:** `ui`

- **Arquivo:** `lib/rest/services/file_storage_service.dart`
  - **Mudanca:** implementar `generateUploadUrlForOwnerAvatar({required String ownerId, required String fileName})`, com validacao de entrada, `setAuthHeader()`, `POST /storage/upload/owners/$ownerId/avatar` e mapeamento via `UploadUrlMapper.toDto`.
  - **Justificativa:** fechar implementacao da interface `FileStorageService` no fluxo de avatar de owner.
  - **Camada:** `rest`

# 7. O que deve ser removido

> Remocoes precisam ser seguras (sem quebrar fluxo, import ou contrato publico). Se houver substituicao, aponte o novo caminho.

- **Arquivo:** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_form_section_view.dart`
  - **Remocao:** classe interna `_AvatarReadOnlyField` e trecho de UI readonly correspondente.
  - **Motivo:** substituicao por componente dedicado com interacao real.
  - **Substituir por (se aplicavel):** `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_form_section/profile_owner_avatar_field/profile_owner_avatar_field_view.dart`

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)
```text
ProfileOwnerAvatarFieldView (tap)
  -> ProfileOwnerTabPresenter.pickAndUploadAvatar()
    -> MediaPickerDriver.pickImages(maxImages: 1)
    -> FileStorageService.generateUploadUrlForOwnerAvatar(ownerId, fileName)
    -> FileStorageDriver.uploadFile(file, uploadUrl)
    -> ProfilingService.updateOwner(owner.avatar = uploadUrl.filePath)
    -> ProfileOwnerTabPresenter.ownerAvatarUrl atualizado
```

## 8.2 Layout/hierarquia visual (ASCII)
```text
ProfileOwnerTab
  |- Dados Pessoais
  |   |- Avatar Field
  |   |   |- Circular image/placeholder
  |   |   |- Upload progress (quando aplicavel)
  |   |   `- Actions: Adicionar | Trocar | Remover
  |   |- Nome Completo
  |   |- Email (readonly)
  |   |- Telefone
  |   `- Bio
  `- Perfil Verificado (readonly)
```

## 8.3 Referencias internas
- `lib/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_tab_presenter.dart` (fluxo de upload ja consolidado)
- `lib/ui/profiling/widgets/screens/profile_screen/profile_owner_tab/profile_owner_tab_presenter.dart` (orquestracao atual da aba Dono)
- `lib/rest/services/file_storage_service.dart` (padrao de validacao e chamada REST)
- `lib/drivers/file-storage-driver/supabase/supabase_file_storage_provider.dart` (upload em signed URL)

## 8.4 Referencias de tela (quando houver)
- **Google Stitch screen id:** `projects/15865350654253776765/screens/f4cfe7687bd448bca78b5ce672360e86`
- **Decisoes de UI extraidas:**
  - Avatar central com destaque visual e badge de camera.
  - Avatar localizado no topo da secao `Dados Pessoais`.
  - Manter linguagem visual atual da aba (campos em bloco/pill e hierarquia tipografica existente).

# 9. Perguntas em aberto
- Nenhuma no momento.

# 10. Decisoes confirmadas
- A remocao de avatar deve ser persistida pelo contrato `ProfilingService.updateOwner` (sem rota dedicada).
- `generateUploadUrlForOwnerAvatar` retorna sempre somente 1 `UploadUrlDto`.

# 11. Consolidacao final da implementacao

## 11.1 Status de atendimento da spec
- [x] Avatar da aba `Dono` tornou-se interativo para upload, troca e remocao.
- [x] Mudanca de avatar sempre persiste owner via `ProfilingService.updateOwner`.
- [x] `FileStorageService` REST implementado para signed URL de avatar de owner.
- [x] Upload realizado exclusivamente via `FileStorageDriver.uploadFile`.
- [x] Estados de erro/carregamento de avatar conectados na UI da aba `Dono`.

## 11.2 Fluxo final (ASCII)
```ASCII
ProfileOwnerAvatarFieldView (tap)
  -> ProfileOwnerTabPresenter.pickAndUploadAvatar()/replaceAvatar()
    -> MediaPickerDriver.pickImages(maxImages: 1)
    -> FileStorageService.generateUploadUrlForOwnerAvatar(ownerId, fileName)
    -> FileStorageDriver.uploadFile(file, uploadUrl)
    -> ProfilingService.updateOwner(owner com avatar atualizado)

ProfileOwnerAvatarFieldView (remover)
  -> ProfileOwnerTabPresenter.removeAvatar()
    -> ProfilingService.updateOwner(owner com avatar nulo)
```
