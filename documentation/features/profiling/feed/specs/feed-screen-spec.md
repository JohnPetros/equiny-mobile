---
title: Feed screen de descoberta de cavalos
status: em progresso
last_updated_at: 2026-02-17
---

# 1. Objetivo
Entregar a primeira versao funcional da `FeedScreen` no `equiny_mobile`, substituindo o placeholder atual por uma experiencia real de descoberta de cavalos com consumo do endpoint `GET` de feed, suporte a filtros basicos, paginação por cursor, abertura de detalhe do cavalo e tratamento completo de estados de tela (`loading`, `erro`, `vazio`, `fim` e `bloqueio por perfil incompleto`), mantendo o fluxo arquitetural `View -> Presenter -> Provider -> Service -> RestClient -> API` e reuso maximo dos contratos existentes em `core`, `rest` e `drivers`.

# 2. Escopo

## 2.1 In-scope
- Substituir o placeholder de `lib/ui/feed/widgets/screens/feed_screen/feed_screen_view.dart` por tela de feed funcional.
- Implementar `Presenter` da feed para orquestrar carregamento inicial, filtros, paginação por cursor e controle do card atual.
- Implementar consumo do endpoint de feed no `ProfilingService` da camada `rest`, com mapeamento para DTO dedicado de item de feed.
- Implementar painel/modal de filtros com `idade`, `raca` (multi-select) e `localizacao`, incluindo `Aplicar` e `Limpar`.
- Persistir filtros da feed em sessao via `CacheDriver` (chave dedicada em `CacheKeys`).
- Implementar registro de decisao de swipe (`like`/`dislike`) via `POST /matching/swipes` usando os contratos novos da camada `core/matching`.
- Implementar tela de detalhe do cavalo aberta a partir do card, preservando continuidade do fluxo ao voltar para o feed.
- Tratar estados de bloqueio quando o usuario nao possui cavalo elegivel para consumir o feed.

## 2.2 Out-of-scope
- Exibicao de campos extras na tela de detalhe alem dos dados base do `HorseDto`.
- Telemetria/analytics de eventos da feed.
- Ranking avancado, recomendacao por afinidade, GPS/distancia e qualquer logica premium/boost.
- Ajustes estruturais na navegacao global alem do necessario para rota de detalhe da feed.

# 3. Requisitos

## 3.1 Funcionais
- A `FeedScreen` deve carregar cards de cavalos a partir do endpoint de feed e renderizar informacoes minimas: foto principal, nome, idade, sexo, localizacao, altura e raca.
- O carregamento inicial deve usar filtros base derivados do cavalo do usuario (sexo complementar, localizacao e faixa de idade padrao).
- A feed deve suportar paginacao por `cursor`, carregando proxima pagina conforme o usuario avancar nos cards.
- A acao de `like/dislike` deve chamar `POST /matching/swipes` com `from_horse_id` e `to_horse_id`, removendo o card atual da pilha apenas em sucesso.
- O painel de filtros deve permitir editar filtros, aplicar alteracoes com recarga da feed e limpar para o padrao.
- O app deve abrir a tela de detalhe do cavalo a partir do card atual e, ao voltar, manter continuidade da sessao de feed.
- A tela deve exibir estados dedicados para: carregamento inicial, erro de API com `retry`, zero resultados, fim do feed e bloqueio por perfil incompleto.
- Se o usuario nao tiver cavalo ativo com requisitos minimos (ex.: sem foto), a feed nao deve carregar cards e deve orientar navegacao para `ProfileScreen`.

## 3.2 Nao funcionais
- Seguir padrao `MVP` na UI com separacao entre `View` e `Presenter`.
- Usar `signals` para estado reativo local e `Riverpod` para injecao de dependencias.
- Manter `core` sem dependencias de framework e `rest` como unica camada de acesso HTTP.
- Reusar `RestResponse`, `PaginationResponse`, `DioRestClient`, `ProfilingService` e `CacheDriver` existentes antes de criar novos contratos.
- Evitar `N+1` de chamadas de galeria na listagem principal da feed; o payload da listagem deve conter dados suficientes para o card.

# 4. O que ja existe (inventario)

> Inclua apenas itens realmente relevantes para implementar a mudanca.

## 4.1 UI (`lib/ui/`)
- **`FeedScreenView`** (`lib/ui/feed/widgets/screens/feed_screen/feed_screen_view.dart`) - tela placeholder atual que sera substituida pela composicao real da feed.
- **`ProfileHorseTabPresenter`** (`lib/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_tab_presenter.dart`) - referencia de padrao de estado com `signals`, carregamento inicial e sincronizacao via `ProfilingService`.
- **`ProfileHorseFeedReadinessSectionPresenter`** (`lib/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_feed_readiness_section/profile_horse_feed_readiness_section_presenter.dart`) - referencia para regra de prontidao do cavalo para entrar no feed.
- **`AppThemeColors`, `AppSpacing`, `AppRadius`** (`lib/ui/shared/theme/app_theme.dart`) - tokens visuais reutilizaveis na feed.

## 4.2 Core (`lib/core/`)
- **`MatchingService`** (`lib/core/matching/interfaces/matching_service.dart`) - contrato de dominio para registrar swipe na camada de matching.
- **`SwipeDto`** (`lib/core/matching/dtos/structures/swipe_dto.dart`) - DTO de request/response do endpoint de swipe (`from_horse_id`, `to_horse_id`, `decision`, `created_at`).
- **`ProfilingService`** (`lib/core/profiling/interfaces/profiling_service.dart`) - contrato com assinatura de `fetchHorseFeed` ja prevista, porem com tipagem de retorno incorreta para uso em feed.
- **`HorseDto`** (`lib/core/profiling/dtos/entities/horse_dto.dart`) - base de atributos do cavalo reutilizavel para composicao do item de feed.
- **`AgeRangeDto`** (`lib/core/profiling/dtos/structures/age_range_dto.dart`) - estrutura existente para filtro de faixa etaria.
- **`LocationDto`** (`lib/core/profiling/dtos/structures/location_dto.dart`) - estrutura existente para filtro/localizacao.
- **`PaginationResponse`** (`lib/core/shared/responses/pagination_response.dart`) - wrapper de paginação por `items`, `nextCursor` e `limit`.

## 4.3 REST (`lib/rest/`)
- **`ProfilingService`** (`lib/rest/services/profiling_service.dart`) - implementacao REST de perfil; ainda nao implementa `fetchHorseFeed`.
- **`services.dart`** (`lib/rest/services.dart`) - composicao atual de providers REST, onde o provider de `MatchingService` deve ser registrado.
- **`HorseMapper`** (`lib/rest/mappers/profiling/horse_mapper.dart`) - referencia de padrao de mapper para `snake_case`/`camelCase` tolerante.
- **`DioRestClient`** (`lib/rest/dio/dio_rest_client.dart`) - adapter HTTP padrao usado por services.

## 4.4 Drivers (`lib/drivers/`)
- **`SharedPreferencesCacheDriver`** (`lib/drivers/cache-driver/shared-prefences/shared_preferences_cache_driver.dart`) - persistencia local para salvar filtros ativos da feed durante a sessao.
- **`GoRouterNavigationDriver`** (`lib/drivers/navigation-driver/go-router/go_router_navigation_driver.dart`) - base de navegacao para transicao entre feed e detalhe.

# 5. O que deve ser criado

> Liste apenas arquivos novos. Para cada arquivo, detalhe assinatura, responsabilidade, dependencias e estado quando aplicavel.

## 5.1 UI

### 5.1.1 Presenters/Stores
- **Arquivo:** `lib/ui/feed/widgets/screens/feed_screen/feed_screen_presenter.dart` (**novo arquivo**)
  - **Responsabilidade:** orquestrar estado completo da feed (carga inicial, filtros, paginação, card ativo, bloqueios e navegacao para detalhe).
  - **Dependencias:** `ProfilingService`, `MatchingService`, `CacheDriver`, `NavigationDriver`.
  - **Estado (`signals`/providers):** `cards`, `filters`, `currentIndex`, `nextCursor`, `isLoadingInitial`, `isLoadingMore`, `isApplyingFilters`, `isBlocked`, `errorMessage`, `emptyStateReason`.
  - **Computeds:** `currentCard`, `hasCards`, `hasNextPage`, `activeFiltersCount`, `isEndOfFeed`.
  - **Metodos:** `init()`, `loadInitialFeed()`, `loadNextPage()`, `openFilters()`, `applyFilters()`, `clearFilters()`, `submitSwipe()`, `likeCurrentHorse()`, `dislikeCurrentHorse()`, `goToHorseDetails()`, `retry()`.

- **Arquivo:** `lib/ui/feed/widgets/screens/feed_screen/feed_filters_sheet/feed_filters_sheet_presenter.dart` (**novo arquivo**)
  - **Responsabilidade:** controlar estado temporario do modal de filtros e validar consistencia antes de aplicar.
  - **Dependencias:** `reactive_forms`.
  - **Estado (`signals`/providers):** `form`, `selectedBreeds`.
  - **Computeds:** `canApply`, `activeFiltersCount`.
  - **Metodos:** `buildForm()`, `toggleBreed()`, `toDto()`, `resetFromDto()`.

- **Arquivo:** `lib/ui/feed/widgets/screens/feed_horse_details_screen/feed_horse_details_screen_presenter.dart` (**novo arquivo**)
  - **Responsabilidade:** preparar estado da tela de detalhe a partir do item selecionado na feed.
  - **Dependencias:** `ProfilingService` (somente para enriquecimento opcional de galeria/descricao quando necessario).
  - **Estado (`signals`/providers):** `horse`, `isLoadingDetails`, `detailsError`.
  - **Computeds:** `horseAgeLabel`, `hasGallery`.
  - **Metodos:** `init()`, `loadDetails()`, `retryLoadDetails()`.

### 5.1.2 Views
- **Arquivo:** `lib/ui/feed/widgets/screens/feed_screen/feed_filters_sheet/feed_filters_sheet_view.dart` (**novo arquivo**)
  - **Responsabilidade:** renderizar painel de filtros conforme Stitch (`Faixa de idade`, `Localizacao`, `Raca`, `Aplicar`, `Limpar`).
  - **Props:** `initialFilters`, `onApply`, `onClear`, `onClose`.
  - **Dependencias de UI:** `flutter/material.dart`, `flutter_riverpod`, `signals_flutter`, `reactive_forms`, tema (`AppTheme`).

- **Arquivo:** `lib/ui/feed/widgets/screens/feed_horse_details_screen/feed_horse_details_screen_view.dart` (**novo arquivo**)
  - **Responsabilidade:** renderizar detalhes do cavalo selecionado no feed com galeria, atributos e descricao.
  - **Props:** `horseId` ou `HorseFeedItemDto` via `GoRouter.extra`.
  - **Dependencias de UI:** `flutter/material.dart`, `flutter_riverpod`, `signals_flutter`, tema (`AppTheme`).

### 5.1.3 Widgets
- **Arquivo/Pasta:** `lib/ui/feed/widgets/screens/feed_screen/feed_horse_card/` (**novo diretorio**)
  - **Responsabilidade:** renderizar card principal da feed com imagem, metadados e CTA de detalhe.
  - **Props:** `horse`, `onLike`, `onDislike`, `onDetails`, `onNextImage`, `onPreviousImage`.
  - **Widgets internos:** `feed_horse_card_gallery`.
  - **Estrutura de pastas (ASCII):**
```text
feed_horse_card/
  feed_horse_card_view.dart
  feed_horse_card_presenter.dart
  index.dart
  feed_horse_card_gallery/
    feed_horse_card_gallery_view.dart
    index.dart
```

- **Arquivo/Pasta:** `lib/ui/feed/widgets/screens/feed_screen/feed_screen_state/` (**novo diretorio**)
  - **Responsabilidade:** concentrar widgets de estado da feed (`loading`, `erro`, `vazio`, `fim`, `bloqueio`).
  - **Props:** variam por estado (`message`, `onRetry`, `onGoToProfile`, `onClearFilters`).
  - **Widgets internos:** um widget por estado.
  - **Estrutura de pastas (ASCII):**
```text
feed_screen_state/
  feed_screen_loading_state_view.dart
  feed_screen_error_state_view.dart
  feed_screen_empty_state_view.dart
  feed_screen_end_state_view.dart
  feed_screen_blocked_state_view.dart
  index.dart
```

- **Arquivo/Pasta:** `lib/ui/feed/widgets/screens/feed_horse_details_screen/` (**novo diretorio**)
  - **Responsabilidade:** encapsular tela de detalhe com presenter, view e export.
  - **Props:** resolve dados por `route` (`path` params e `extra`).
  - **Widgets internos:** secoes de atributos, descricao e galeria.
  - **Estrutura de pastas (ASCII):**
```text
feed_horse_details_screen/
  feed_horse_details_screen_view.dart
  feed_horse_details_screen_presenter.dart
  index.dart
```

## 5.2 Core
- **Arquivo:** `lib/core/profiling/dtos/structures/horse_feed_filters_dto.dart` (**novo arquivo**)
  - **Tipo:** `dto`
  - **Contratos/assinaturas:** `HorseFeedFiltersDto({required String sex, required List<String> breeds, required AgeRangeDto ageRange, required LocationDto location, required int limit, String? cursor})`.
  - **Responsabilidade:** consolidar filtros do feed em um contrato unico reutilizavel entre UI e REST.

- **Arquivo:** `lib/core/profiling/dtos/structures/horse_feed_item_dto.dart` (**novo arquivo**)
  - **Tipo:** `dto`
  - **Contratos/assinaturas:** campos minimos para card/detalhe (`id`, `name`, `sex`, `birthMonth`, `birthYear`, `breed`, `height`, `location`, `description`, `imageUrls`).
  - **Responsabilidade:** representar item retornado pelo endpoint de feed sem acoplar `HorseDto` de edicao do perfil.

- **Arquivo:** `lib/core/profiling/dtos/structures/horse_feed_result_dto.dart` (**novo arquivo**)
  - **Tipo:** `dto`
  - **Contratos/assinaturas:** `HorseFeedResultDto({required List<HorseDto> items, required String nextCursor, required int limit})`.
  - **Responsabilidade:** representar payload de resposta de `POST /profiling/horses/feed` conforme contrato informado.

## 5.3 REST
- **Arquivo:** `lib/rest/mappers/profiling/horse_feed_mapper.dart` (**novo arquivo**)
  - **Service/Client:** mapper dedicado da feed.
  - **Metodos:** `toFeedRequestJson(HorseFeedFiltersDto)`, `toFeedResultDto(Json)`.
  - **Entrada/Saida:** `HorseFeedFiltersDto -> Json` e `Json -> HorseFeedResultDto`.

- **Arquivo:** `lib/rest/mappers/matching/swipe_mapper.dart` (**novo arquivo**)
  - **Service/Client:** mapper dedicado para contrato de swipe.
  - **Metodos:** `toJson(SwipeDto)`, `toDto(Json)`.
  - **Entrada/Saida:** `SwipeDto <-> Json`.

- **Arquivo:** `lib/rest/services/matching_service.dart` (**novo arquivo**)
  - **Service/Client:** implementacao REST de `MatchingService`.
  - **Metodos:** `createSwipe({required SwipeDto swipe})`.
  - **Entrada/Saida:** `SwipeDto -> RestResponse<SwipeDto>` via `POST /matching/swipes`.

## 5.4 Drivers
- **Nenhum arquivo novo previsto.**

# 6. O que deve ser modificado

> Liste apenas arquivos existentes. Mudancas em arquivo novo ficam na secao 5.

- **Arquivo:** `lib/ui/feed/widgets/screens/feed_screen/feed_screen_view.dart`
  - **Mudanca:** substituir UI placeholder por composicao completa da feed conectada ao `feedScreenPresenterProvider`.
  - **Justificativa:** transformar rota `/feed` em tela funcional de descoberta.
  - **Impacto:** `ui`

- **Arquivo:** `lib/core/profiling/interfaces/profiling_service.dart`
  - **Mudanca:** ajustar assinatura de `fetchHorseFeed` para retorno tipado de paginação (`RestResponse<PaginationResponse<HorseFeedItemDto>>`) e parametro de filtros DTO.
  - **Justificativa:** contrato atual retorna `OwnerDto`, o que nao representa o dominio da feed.
  - **Impacto:** `core`

- **Arquivo:** `lib/rest/services/profiling_service.dart`
  - **Mudanca:** implementar metodo `fetchHorseFeed(...)` com chamada `POST /profiling/horses/feed` e uso do `HorseFeedMapper`.
  - **Justificativa:** habilitar carregamento real de cards no app.
  - **Impacto:** `rest`

- **Arquivo:** `lib/rest/services.dart`
  - **Mudanca:** registrar provider de `MatchingService` para injecao na `FeedScreen`.
  - **Justificativa:** disponibilizar dependencia de swipe no fluxo `View -> Presenter -> Provider -> Service`.
  - **Impacto:** `rest`

- **Arquivo:** `lib/core/shared/constants/cache_keys.dart`
  - **Mudanca:** adicionar chave de cache para filtros da feed (ex.: `feedFilters`).
  - **Justificativa:** persistir filtros ativos durante sessao e melhorar continuidade de UX.
  - **Impacto:** `core`

- **Arquivo:** `lib/core/shared/constants/routes.dart`
  - **Mudanca:** adicionar rota de detalhe da feed (ex.: `feedHorseDetails`).
  - **Justificativa:** formalizar navegacao para tela de detalhe sem hardcode de strings.
  - **Impacto:** `core`

- **Arquivo:** `lib/router.dart`
  - **Mudanca:** registrar rota de detalhe do cavalo e manter feed dentro da `ShellRoute` existente.
  - **Justificativa:** integrar navegacao entre card e detalhe com retorno seguro para a feed.
  - **Impacto:** `ui`

# 7. O que deve ser removido

> Remocoes precisam ser seguras (sem quebrar fluxo, import ou contrato publico). Se houver substituicao, aponte o novo caminho.

- **Arquivo:** `lib/ui/feed/widgets/screens/feed_screen/feed_screen_view.dart`
  - **Remocao:** bloco placeholder atual (`Text('Placeholder: Feed')`) e estrutura temporaria associada.
  - **Motivo:** substituir implementacao mock por tela funcional de feed.
  - **Substituir por (se aplicavel):** `lib/ui/feed/widgets/screens/feed_screen/feed_screen_view.dart` (nova composicao com presenter + widgets de estado/card).

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)
```text
FeedScreenView
  -> FeedScreenPresenter
    -> profilingServiceProvider
      -> ProfilingService (REST)
        -> RestClient (Dio)
          -> POST /profiling/horses/feed
    -> matchingServiceProvider
      -> MatchingService (REST)
        -> RestClient (Dio)
          -> POST /matching/swipes
    -> cacheDriverProvider
      -> SharedPreferencesCacheDriver
```

## 8.2 Layout/hierarquia visual (ASCII)
```text
FeedScreen
  |- Header (DESCOBERTA + botao Filtros + badge)
  |- CardStack
  |   `- FeedHorseCard
  |       |- Gallery (prev/next)
  |       |- Identity (nome, idade, sexo, localizacao)
  |       |- Stats (idade, localizacao, altura, raca)
  |       `- CTA Detalhes
  |- ActionBar (dislike, detalhes, like)
  `- BottomTabNavigation

FeedFiltersSheet
  |- Faixa de idade
  |- Localizacao
  |- Raca (multi-select)
  `- Footer (Limpar, Aplicar)
```

## 8.3 Referencias internas
- `lib/ui/feed/widgets/screens/feed_screen/feed_screen_view.dart`
- `lib/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_tab_presenter.dart`
- `lib/ui/profiling/widgets/screens/profile_screen/profile_horse_tab/profile_horse_feed_readiness_section/profile_horse_feed_readiness_section_presenter.dart`
- `lib/core/profiling/interfaces/profiling_service.dart`
- `lib/core/matching/interfaces/matching_service.dart`
- `lib/core/matching/dtos/structures/swipe_dto.dart`
- `lib/rest/services/profiling_service.dart`
- `lib/rest/mappers/profiling/horse_mapper.dart`

## 8.4 Referencias de tela (quando houver)
- **Google Stitch screen id:** `66e7849a50fc44ba9e89ee0d9887d054`
- **Google Stitch screen id:** `913fe10960dd47f9a5a5b6f34dd3c2c4`
- **Google Stitch screen id:** `18fad547867249479104b14daa5d3470`
- **Decisoes de UI extraidas:**
  - Header da feed com titulo `DESCOBERTA` e entrada de `Filtros` com contador de ativos.
  - Card central com imagem grande, navegacao entre fotos e CTA explicito de `DETALHES`.
  - Barra de acao inferior com tres acoes visuais (`dislike`, `detalhes`, `like`).
  - Modal de filtros com controle de faixa de idade, localizacao e racas selecionadas.

# 9. Perguntas em aberto
- Confirmar conjunto canonico de valores para `decision` em `SwipeDto` (`like/dislike` ou outro enum oficial).
- Confirmar granularidade oficial do filtro de localizacao na API (`estado` apenas ou `cidade + estado`).

