---
title: Geolocalizacao no passo de localizacao do onboarding
prd: documentation\features\profiling\onboarding\prd.md
status: concluido
last_updated_at: 2026-03-01
---

# 1. Objetivo
Implementar preenchimento assistido de `cidade` e `estado` no passo de localizacao do onboarding, com CTA `Usar minha localizacao atual`, usando `geolocator` para obter coordenadas do dispositivo e preenchendo o formulario sem quebrar o fluxo manual existente. Tecnicamente, a entrega adiciona abstracao de geolocalizacao na camada `core/drivers`, integra ao `OnboardingStepLocationPresenter` (MVP + `Riverpod` + `signals`) e mantem validacao/submit atual do onboarding.

# 2. Escopo

## 2.1 In-scope
- Adicionar CTA de geolocalizacao no componente `OnboardingStepLocation`.
- Solicitar permissao de localizacao em tempo de execucao (`whileInUse`) no primeiro uso.
- Tratar cenarios `service disabled`, `permission denied` e `denied forever` com mensagem orientativa e acao de abrir configuracoes.
- Obter coordenadas atuais via `geolocator` e resolver `cidade/estado` para preencher o `FormGroup`.
- Manter campos editaveis apos auto-preenchimento (usuario pode corrigir manualmente).
- Reaproveitar `LocationService.fetchCities(state)` para carregar lista de cidades apos definir UF detectada.

## 2.2 Out-of-scope
- Rastreamento em background, distancia em tempo real ou geofencing.
- Mudancas no fluxo de `feed`/filtros por distancia.
- Persistencia de latitude/longitude no backend do onboarding.
- Suporte dedicado para `web` e `desktop` nesta entrega (foco em `Android` e `iOS`).

# 3. Requisitos

## 3.1 Funcionais
- Exibir botao/CTA `Usar minha localizacao atual` no passo de localizacao do onboarding.
- Ao tocar no CTA, o app deve: verificar se servicos de localizacao estao ativos, solicitar permissao quando necessario, obter posicao atual (`latitude` e `longitude`), converter para `cidade` e `estado` e preencher o formulario.
- Quando a permissao estiver `denied forever`, exibir acao para abrir `App Settings`.
- Quando servico de localizacao estiver desligado, exibir acao para abrir `Location Settings`.
- Em falha de geolocalizacao, manter fluxo manual intacto (sem bloquear avancar, desde que usuario preencha campos).
- Campo `state` preenchido via geolocalizacao deve respeitar formato UF (`SP`, `RJ`, etc.), consistente com `LocationService`.

## 3.2 Nao funcionais
- Seguir padrao **MVP** na UI (`View` sem regra de negocio).
- Isolar plugin nativo (`geolocator`) na camada `drivers` via interface no `core`.
- Manter estado reativo com `signals` e injecao via `Riverpod`.
- Evitar duplicacao de logica de permissao dentro da `View`.
- Manter copy e visual alinhados ao layout atual da etapa de localizacao.

# 4. O que ja existe (inventario)

> Inclui apenas itens relevantes para esta implementacao.

## 4.1 UI (`lib/ui/`)
- **`OnboardingStepLocationPresenter`** (`lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/onboarding_step_location_presenter.dart`) - carrega estados/cidades via `LocationService` e ja centraliza estado do passo.
- **`OnboardingStepLocationView`** (`lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/onboarding_step_location_view.dart`) - formulario com `Autocomplete` para `Estado` e `Cidade`.
- **`OnboardingScreenPresenter`** (`lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_screen_presenter.dart`) - controla validacao do passo (`city` e `state`) e envio final do onboarding.

## 4.2 Core (`lib/core/`)
- **`LocationDto`** (`lib/core/profiling/dtos/structures/location_dto.dart`) - contrato de `cidade` e `estado` usado no onboarding.
- **`LocationService`** (`lib/core/shared/interfaces/location_service.dart`) - contrato de busca de estados e cidades.
- **`RestResponse`** (`lib/core/shared/responses/rest_response.dart`) - padrao de resposta usado na camada de service.

## 4.3 REST (`lib/rest/`)
- **`LocationService`** (`lib/rest/services/location_service.dart`) - implementacao REST que consome IBGE para `fetchStates` e `fetchCities`.
- **`LocationMapper`** (`lib/rest/mappers/location/location_mapper.dart`) - mapeia estados (`sigla`) e cidades (`nome`) da resposta IBGE.
- **`location_rest_client.restClientProvider`** (`lib/rest/location_rest_client.dart`) - cliente HTTP dedicado para API de localidades.

## 4.4 Drivers (`lib/drivers/`)
- **`ImagePickerMediaPickerDriver`** (`lib/drivers/media-picker-driver/image-picker/image_picker_media_picker_driver.dart`) - referencia de isolamento de plugin nativo.
- **`OneSignalPushNotificationDriver`** (`lib/drivers/push-notification-driver/one-signal/one_signal_push_notification_driver.dart`) - referencia de fluxo de permissao em driver.
- **Nao existe driver de geolocalizacao hoje** (lacuna da feature).

# 5. O que deve ser criado

> Lista apenas de novos arquivos necessarios para viabilizar a feature.

## 5.1 UI

### 5.1.1 Presenters/Stores
- Nenhum **novo arquivo** previsto. A logica entra no presenter existente do passo de localizacao.

### 5.1.2 Views
- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/location_autofill_cta/location_autofill_cta_view.dart` (**novo arquivo**)
  - **Responsabilidade:** renderizar CTA de geolocalizacao, loading e estados de erro/acao secundaria (`Abrir configuracoes`).
  - **Props:** `isLoading`, `message`, `onTapDetect`, `onTapOpenSettings`.
  - **Dependencias de UI:** `flutter/material.dart`, tema (`AppThemeColors`, `AppSpacing`, `AppRadius`).

- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/location_autofill_cta/index.dart` (**novo arquivo**)
  - **Responsabilidade:** exportar `LocationAutofillCtaView` via `typedef`.

### 5.1.3 Widgets
- **Arquivo/Pasta:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/location_autofill_cta/` (**novo diretorio**)
  - **Responsabilidade:** encapsular bloco visual de geolocalizacao sem poluir `OnboardingStepLocationView`.
  - **Props:** conforme item 5.1.2.
  - **Widgets internos:** nenhum.
  - **Estrutura de pastas (ASCII):**
```text
onboarding_step_location/
  location_autofill_cta/
    index.dart
    location_autofill_cta_view.dart
```

## 5.2 Core
- **Arquivo:** `lib/core/shared/interfaces/geolocation_driver.dart` (**novo arquivo**)
  - **Tipo:** `interface`
  - **Contratos/assinaturas:** `Future<LocationDto> detectCurrentLocation();`, `Future<void> openAppSettings();`, `Future<void> openLocationSettings();`
  - **Responsabilidade:** abstrair obtencao de localizacao atual e acoes de settings sem acoplar UI ao plugin nativo.
  - **Observacao:** incluir tipo de falha (ex.: `enum` ou `exception`) no mesmo arquivo para permitir tratamento granular no presenter.

## 5.3 REST
- Nenhum **novo arquivo** previsto.

## 5.4 Drivers
- **Arquivo:** `lib/drivers/geolocation-driver/geolocator/geolocator_geolocation_driver.dart` (**novo arquivo**)
  - **Adapter/Driver:** implementacao concreta de `GeolocationDriver` usando `geolocator` (e reverse geocoding local no proprio driver).
  - **Responsabilidade:** executar fluxo de permissao + leitura de posicao + resolucao de `cidade` e `UF`.
  - **Dependencias:** `geolocator`, `geocoding`, `LocationDto`.
  - **Decisao aplicada na implementacao:** normalizacao de `estado` para UF (`SP`, `RJ`, etc.) no proprio driver antes de preencher o formulario.

- **Arquivo:** `lib/drivers/geolocation-driver/index.dart` (**novo arquivo**)
  - **Adapter/Driver:** provider Riverpod (`geolocationDriverProvider`).
  - **Responsabilidade:** expor dependencia para presenters da UI.
  - **Dependencias:** `flutter_riverpod`, `GeolocationDriver`, `GeolocatorGeolocationDriver`.

# 6. O que deve ser modificado

> Lista apenas de arquivos existentes impactados.

- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/onboarding_step_location_presenter.dart`
  - **Mudanca:** injetar `GeolocationDriver`, adicionar sinais (`isDetectingLocation`, `geolocationMessage`, `canOpenSettings`) e metodo `detectAndApplyCurrentLocation(FormGroup form)` com tratamento de falhas de permissao/servico.
  - **Justificativa:** centralizar regra de geolocalizacao no presenter, mantendo a view declarativa.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/onboarding_step_location_view.dart`
  - **Mudanca:** incluir bloco `LocationAutofillCta`, acionar metodo do presenter e sincronizar `TextEditingController` com valores detectados.
  - **Justificativa:** adicionar UX de preenchimento automatico sem quebrar o fluxo manual atual.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/index.dart`
  - **Mudanca:** manter export principal do passo e incluir export do novo widget interno quando necessario.
  - **Justificativa:** preservar padrao de Barrel file para composicao interna.
  - **Camada:** `ui`

- **Arquivo:** `pubspec.yaml`
  - **Mudanca:** adicionar dependencias `geolocator` e `geocoding`.
  - **Justificativa:** `geolocator` cobre permissao/posicao; `geocoding` resolve `cidade` e `estado` a partir das coordenadas.
  - **Camada:** `drivers`

- **Arquivo:** `android/app/src/main/AndroidManifest.xml`
  - **Mudanca:** adicionar permissoes `ACCESS_FINE_LOCATION` e `ACCESS_COARSE_LOCATION`.
  - **Justificativa:** permitir leitura de localizacao no Android.
  - **Camada:** `drivers`

- **Arquivo:** `ios/Runner/Info.plist`
  - **Mudanca:** adicionar `NSLocationWhenInUseUsageDescription`.
  - **Justificativa:** requisito de permissao de localizacao no iOS.
  - **Camada:** `drivers`

# 7. O que deve ser removido

> Remocoes seguras, sem quebra de contrato.

- Nenhuma remocao prevista nesta entrega.

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)
```text
OnboardingStepLocationView
  -> OnboardingStepLocationPresenter
    -> geolocationDriverProvider
      -> GeolocatorGeolocationDriver
        -> Geolocator (permission + current position)
        -> Geocoding (reverse geocode city/state)
    -> locationServiceProvider
      -> LocationService
        -> RestClient
          -> IBGE API (/localidades/estados, /municipios)
  -> FormGroup (city/state atualizado)

OnboardingScreenView
  -> OnboardingScreenPresenter
    -> ProfilingService
      -> RestClient
        -> Equiny API
```

## 8.2 Layout/hierarquia visual (ASCII)
```text
OnboardingStepLocation
  |- Title + Subtitle
  |- LocationAutofillCta
  |   |- Button "Usar minha localizacao atual"
  |   |- Loading indicator
  |   `- Message + action (abrir configuracoes)
  |- Estado (Autocomplete)
  |- Cidade (Autocomplete)
  `- Info text
```

## 8.3 Referencias internas
- `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/onboarding_step_location_presenter.dart`
- `lib/ui/profiling/widgets/screens/onboarding_screen/onboarding_step_location/onboarding_step_location_view.dart`
- `lib/core/profiling/dtos/structures/location_dto.dart`
- `lib/core/shared/interfaces/location_service.dart`
- `lib/rest/services/location_service.dart`
- `lib/rest/mappers/location/location_mapper.dart`
- `lib/drivers/media-picker-driver/image-picker/image_picker_media_picker_driver.dart`

## 8.4 Referencias de tela (quando houver)
- **Google Stitch screen id:** `projects/15865350654253776765/screens/ee253a51bcb44dda8873671bba25c0ae`
- **Decisoes de UI extraidas:**
  - Manter estrutura da etapa com titulo curto e texto de apoio.
  - Campos `Cidade` e `Estado` continuam visiveis e editaveis no corpo principal.
  - Rodape do onboarding (`Voltar` e `Avancar`) permanece inalterado.
  - CTA de geolocalizacao entra como reforco acima dos campos, sem alterar hierarquia macro.

# 9. Perguntas em aberto
- Nenhuma. Decisoes alinhadas:
  - Escopo de plataforma: `Android` e `iOS` (com permissoes nativas configuradas).
  - Cidade detectada fora da lista IBGE: **aceitar valor detectado**.
  - Copy de mensagens de permissao (`denied` e `denied forever`): **ja definida**.

# 10. Validacao final
- `dart format .` executado para garantir padrao Dart em todo o projeto.
- `flutter analyze` executado com resultado final **sem issues**.
- `flutter test` executado: suite global ainda possui falhas pre-existentes fora do escopo da geolocalizacao (ex.: testes de `onboarding_step_breed`, `onboarding_step_sex` e `onboarding_screen_view`).
- Conformidade com diretrizes de codigo validada contra `documentation/guidelines/code-conventions-guidelines.md` e `documentation/rules/code-conventions-rules.md` para os arquivos impactados pela feature.
