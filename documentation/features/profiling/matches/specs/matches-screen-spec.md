---
title: Spec tecnica da tela de Matches (Conexoes)
prd: documentation\features\profiling\matches\prd.md
status: concluido
last_updated_at: 2026-02-18
---

# 1. Objetivo
Entregar a tela de `Matches` no app mobile com lista simples (sem paginacao), agrupamento visual em `Novos` e `Todos`, contador de novos no header, estados de carregamento/erro/vazio e `bottom dialog` de opcoes ao tocar em item, preservando o fluxo arquitetural `View -> Presenter -> Provider -> Service -> RestClient -> API` e reduzindo risco de regressao por reaproveitar padroes ja usados no `feed_screen`.

# 2. Escopo

## 2.1 In-scope
- Implementar `Presenter` da tela de matches com `signals`, `computed` e `Provider.autoDispose`.
- Consumir `ProfilingService.fetchHorseMatches` sem paginacao e com ordenacao local por `createdAt` desc.
- Renderizar **duas listas visuais** na mesma tela: lista horizontal `Novos` (isViewed=false) e lista vertical `Todos` (isViewed=true).
- Exibir badge `Novo` por item e contador `X novos` no header quando `newCount > 0`.
- Abrir `bottom dialog` de opcoes ao tocar em item de qualquer lista (`Novos` e `Todos`).
- Atualizar estado do item para visto ao acionar `Mandar mensagem` e navegar para `Routes.conversations`.
- Criar estados de tela: loading inicial, erro com retry, empty state com CTA para `Feed`.

## 2.2 Out-of-scope
- Implementacao completa da conversa individual (historico/envio em tempo real).
- Filtros avancados de matches, busca textual e ordenacoes adicionais.
- Acoes de bloqueio, denuncia, desfazer/arquivar match.
- Reescrita da navegacao principal (bottom tabs e rotas existentes).
- Tela dedicada de perfil publico do match (acao `Ver perfil` fica limitada ao fluxo definido no app nesta fase).

# 3. Requisitos

## 3.1 Funcionais
- Mostrar tela `Matches` com titulo e contador de novos apenas quando houver pelo menos 1 item novo.
- Exibir **duas listas**: `Novos` no topo (horizontal) e `Todos` abaixo (vertical).
- Ordenar cada secao por `createdAt` em ordem decrescente.
- Exibir na lista `Novos`: avatar circular + nome.
- Exibir na lista `Todos`: avatar circular, nome e `createdAt` em tempo relativo (ex: `2 dias atras`, `1 sem atras`).
- Quando `ownerAvatar` estiver vazio ou nulo, exibir avatar fallback (iniciais do nome ou icone padrao).
- Ao tocar no item de `Novos` ou `Todos`, abrir `bottom dialog` com titulo `Opcoes para {nome}` e acoes `Ver perfil`, `Mandar mensagem` e `Cancelar`.
- Ao escolher `Mandar mensagem`, remover status `Novo` (se aplicavel), atualizar contador e navegar para `Routes.conversations`.
- Ao escolher `Ver perfil`, executar o fluxo de perfil disponivel no app sem alterar contrato de conversa nesta entrega.
- Quando nao houver matches, exibir mensagem de vazio e CTA `Ir para o Feed`.

## 3.2 Nao funcionais
- Manter arquitetura em camadas e padrao MVP (sem chamada REST direta na View).
- Usar `signals` para estado local e `Riverpod` para DI.
- Garantir renderizacao estavel da lista completa retornada pela API.
- Evitar jank visual com placeholder de imagem e resolucao por `FileStorageDriver`.
- Garantir fallback de avatar para evitar quebra visual quando a imagem do owner nao existir.
- Respeitar convencoes de nome e organizacao de arquivos em `snake_case` + `index.dart`.

# 4. O que ja existe (inventario)

> Inclua apenas itens realmente relevantes para implementar a mudanca.

## 4.1 UI (`lib/ui/`)
- **`MatchesScreenView`** (`lib/ui/matches/widgets/screens/matches_screen/matches_screen_view.dart`) - tela placeholder que sera substituida pelo fluxo MVP.
- **`FeedScreenPresenter`** (`lib/ui/feed/widgets/screens/feed_screen/feed_screen_presenter.dart`) - referencia de padrao para estado, `Provider.autoDispose` e tratamento de erro.
- **`FeedHorseCardView`** (`lib/ui/feed/widgets/screens/feed_screen/feed_horse_card/feed_horse_card_view.dart`) - referencia de composicao visual e uso de widgets internos.
- **`ConversationsScreenView`** (`lib/ui/conversations/widgets/screens/conversations_screen/conversations_screen_view.dart`) - destino de navegacao apos toque em match.

## 4.2 Core (`lib/core/`)
- **`HorseMatchDto`** (`lib/core/profiling/dtos/structures/horse_match_dto.dart`) - contrato base de dados de match que precisa evoluir para suportar campos da lista.
- **`ProfilingService`** (`lib/core/profiling/interfaces/profiling_service.dart`) - contrato que ja declara `fetchHorseMatches`, mas com assinatura insuficiente para listagem da tela.
- **`Routes`** (`lib/core/shared/constants/routes.dart`) - rota `Routes.matches` e `Routes.conversations` ja disponiveis.

## 4.3 REST (`lib/rest/`)
- **`ProfilingService`** (`lib/rest/services/profiling_service.dart`) - implementa chamadas de profiling e sera estendido com endpoint de matches.
- **`HorseFeedMapper`** (`lib/rest/mappers/profiling/horse_feed_mapper.dart`) - referencia de padrao para mapear payloads de profiling.
- **`services.dart`** (`lib/rest/services.dart`) - provider de injecao para `profilingServiceProvider` ja existente.

## 4.4 Drivers (`lib/drivers/`)
- **`GoRouterNavigationDriver`** (`lib/drivers/navigation-driver/go-router/go_router_navigation_driver.dart`) - permite `goTo(route, data: extra)` para abrir `Conversations` com contexto do match.
- **`fileStorageDriverProvider`** (`lib/drivers/file-storage-driver/index.dart`) - resolver URL da thumbnail com `FileStorageDriver.getFileUrl`.

# 5. O que deve ser criado

> Liste apenas arquivos novos. Para cada arquivo, detalhe assinatura, responsabilidade, dependencias e estado quando aplicavel.

## 5.1 UI

### 5.1.1 Presenters/Stores
- **Arquivo:** `lib/ui/matches/widgets/screens/matches_screen/matches_screen_presenter.dart`
  - **Responsabilidade:** orquestrar carregamento de matches, agrupamento `Novos/Todos`, abertura/fechamento do dialog de opcoes, transicao de item visto e navegacao para `Conversations`.
  - **Dependencias:** `ProfilingService`, `NavigationDriver`, `CacheDriver` (opcional para horse ativo), `DateTime` helpers.
  - **Estado (`signals`/providers):** `matches`, `isLoadingInitial`, `errorMessage`, `activeHorseId`, `selectedMatch`, `isOptionsDialogOpen`.
  - **Computeds:** `newMatches`, `seenMatches`, `newCount`, `isEmptyState`, `hasError`.
  - **Metodos:** `init()`, `retry()`, `openMatchOptions(HorseMatchDto match)`, `closeMatchOptions()`, `onTapViewProfile()`, `onTapSendMessage()`, `goToFeed()`.

### 5.1.2 Views
- **Arquivo:** `lib/ui/matches/widgets/screens/matches_screen/matches_screen_content_view.dart`
  - **Responsabilidade:** encapsular o conteudo principal da tela (header + secoes + estados) separado do scaffold raiz.
  - **Props:** `presenter`.
  - **Dependencias de UI:** `signals_flutter`, tema em `app_theme`, `matches_header`, `new_matches_list`, `matches_list`, `match_option_dialog` e `matches_screen_state`.

### 5.1.3 Widgets
- **Arquivo/Pasta:** `lib/ui/matches/widgets/screens/matches_screen/matches_header/`
  - **Responsabilidade:** titulo da tela + chip `X novos` condicional.
  - **Props:** `title`, `newCount`.
  - **Widgets internos:** nenhum.
  - **Estrutura de pastas (ASCII):**
```text
matches_screen/
  matches_header/
    index.dart
    matches_header_view.dart
```

- **Arquivo/Pasta:** `lib/ui/matches/widgets/screens/matches_screen/new_matches_list/`
  - **Responsabilidade:** lista horizontal de `Novos`.
  - **Props:** `items`, `onTapItem`.
  - **Widgets internos:** `new_matches_list_item` (com fallback de avatar).
  - **Estrutura de pastas (ASCII):**
```text
matches_screen/
  new_matches_list/
    index.dart
    new_matches_list_view.dart
    new_matches_list_item/
      index.dart
      new_matches_list_item_view.dart
```

- **Arquivo/Pasta:** `lib/ui/matches/widgets/screens/matches_screen/matches_list/`
  - **Responsabilidade:** lista vertical de `Todos`.
  - **Props:** `items`, `onTapItem`.
  - **Widgets internos:** `matches_list_item` (com fallback de avatar).
  - **Estrutura de pastas (ASCII):**
```text
matches_screen/
  matches_list/
    index.dart
    matches_list_view.dart
    matches_list_item/
      index.dart
      matches_list_item_presenter.dart
      matches_list_item_view.dart
```

- **Arquivo/Pasta:** `lib/ui/matches/widgets/screens/matches_screen/matches_screen_state/`
  - **Responsabilidade:** views de estado (`loading`, `error`, `empty`).
  - **Props:** callbacks `onRetry` e `onGoToFeed` quando aplicavel.
  - **Widgets internos:** nenhum.
  - **Estrutura de pastas (ASCII):**
```text
matches_screen/
  matches_screen_state/
    index.dart
    matches_screen_loading_state_view.dart
    matches_screen_error_state_view.dart
    matches_screen_empty_state_view.dart
```

## 5.2 Core
- Nenhum arquivo novo previsto em `core`.

## 5.3 REST
- **Arquivo:** `lib/rest/mappers/profiling/horse_match_mapper.dart`
  - **Service/Client:** mapper de payload de matches.
  - **Metodos:** `toDto(Json body)`, `toDtoList(Json body)`.
  - **Entrada/Saida:** `Json` API -> `HorseMatchDto`/`List<HorseMatchDto>`.

## 5.4 Drivers
- Nenhum arquivo novo previsto em `drivers`.

## 5.5 UI - Dialog de opcoes
- **Arquivo/Pasta:** `lib/ui/matches/widgets/screens/matches_screen/match_option_dialog/`
  - **Responsabilidade:** renderizar `bottom dialog` com acoes por match selecionado.
  - **Props:** `matchName`, `onViewProfile`, `onSendMessage`, `onCancel`.
  - **Widgets internos:** `match_option_item`.
  - **Estrutura de pastas (ASCII):**
```text
matches_screen/
  match_option_dialog/
    index.dart
    match_option_dialog_view.dart
    match_option_item/
      index.dart
      match_option_item_view.dart
```

# 6. O que deve ser modificado

> Liste apenas arquivos existentes. Mudancas em arquivo novo ficam na secao 5.

- **Arquivo:** `lib/core/profiling/dtos/structures/horse_match_dto.dart`
  - **Mudanca:** ampliar contrato para suportar campos de UI (`horseName`, `horseAvatarKey`, `city`, `state`, `horseBirthYear`, `matchHorseId`, `isViewed`, `createdAt`).
  - **Justificativa:** campos atuais (`owner*`) nao cobrem exibicao exigida pelo PRD da tela.
  - **Camada:** `core`

- **Arquivo:** `lib/core/profiling/interfaces/profiling_service.dart`
  - **Mudanca:** ajustar assinatura de `fetchHorseMatches` para listagem simples por cavalo ativo (`horseId`) e incluir `markHorseMatchAsViewed`.
  - **Justificativa:** assinatura atual com `fromHorseId/toHorseId` nao atende fluxo de lista + persistencia de `Novo`.
  - **Camada:** `core`

- **Arquivo:** `lib/rest/services/profiling_service.dart`
  - **Mudanca:** implementar `fetchHorseMatches` e `markHorseMatchAsViewed`, com `setAuthHeader`, tratamento de falha via `RestResponse` e uso do `HorseMatchMapper`.
  - **Justificativa:** provider de profiling ainda nao integra endpoints de matches.
  - **Camada:** `rest`

- **Arquivo:** `lib/rest/mappers/profiling/horse_match_mapper.dart`
  - **Mudanca:** normalizar `ownerAvatar` para string vazia quando ausente e manter parse resiliente.
  - **Justificativa:** simplificar regra de fallback de avatar na UI.
  - **Camada:** `rest`

- **Arquivo:** `lib/ui/matches/widgets/screens/matches_screen/matches_screen_view.dart`
  - **Mudanca:** substituir placeholder por tela completa baseada em presenter, listas e abertura do `bottom dialog` de opcoes.
  - **Justificativa:** entregar requisitos funcionais da milestone de matches.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/matches/widgets/screens/matches_screen/index.dart`
  - **Mudanca:** manter typedef e exportar presenter/estados via imports do modulo (se necessario).
  - **Justificativa:** garantir ponto unico de entrada do widget conforme padrao.
  - **Camada:** `ui`

- **Arquivo:** `lib/router.dart`
  - **Mudanca:** manter rota `Routes.conversations` sem alteracao de payload nesta entrega.
  - **Justificativa:** contrato de payload para abertura dirigida da conversa esta fora de escopo.
  - **Camada:** `ui`

# 7. O que deve ser removido

> Remocoes precisam ser seguras (sem quebrar fluxo, import ou contrato publico). Se houver substituicao, aponte o novo caminho.

- Nenhuma remocao prevista nesta entrega.

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)
```text
MatchesScreenView
  -> MatchesScreenPresenter
    -> profilingServiceProvider (Riverpod)
      -> ProfilingService.fetchHorseMatches
        -> RestClient.get('/profiling/horses/{horseId}/matches')
          -> API

Tap match
  -> MatchesScreenPresenter.openMatchOptions
    -> BottomDialog (Ver perfil | Mandar mensagem | Cancelar)
      -> onTapSendMessage
        -> ProfilingService.markHorseMatchAsViewed
        -> NavigationDriver.goTo(Routes.conversations)
```

## 8.2 Layout/hierarquia visual (ASCII)
```text
MatchesScreen
  |- Header
  |   |- Title: Matches
  |   `- Badge: X novos (condicional)
  |- Content
  |   |- Section: Novos (condicional)
  |   |   `- HorizontalAvatarList[] (com fallback de avatar)
  |   `- Section: Todos
  |       `- VerticalRowList[] (avatar + nome + tempo relativo, com fallback)
  `- BottomDialog (ao tocar em item)
      |- Titulo: Opcoes para {nome}
      |- Acao: Ver perfil
      |- Acao: Mandar mensagem
      `- Acao: Cancelar
  `- Empty/Error/Loading state (conforme estado)
```

## 8.3 Referencias internas
- `lib/ui/feed/widgets/screens/feed_screen/feed_screen_presenter.dart` (orquestracao + signals)
- `lib/ui/feed/widgets/screens/feed_screen/feed_horse_card/feed_horse_card_view.dart` (composicao visual por widgets internos)
- `lib/rest/mappers/profiling/horse_feed_mapper.dart` (padrao de mapper para profiling)

## 8.4 Referencias de tela (quando houver)
- **Google Stitch screen id:** `b5dc0026cd214a6695af3c7f93f756cb` (projeto `15865350654253776765`)
- **Decisoes de UI extraidas:**
  - Header simples com titulo `Matches` e contador `3 novos` apenas quando houver itens novos.
  - Secao `Novos` em formato de lista horizontal com avatar e nome (fallback quando sem imagem).
  - Secao `Todos` em formato de lista vertical com avatar, nome e tempo relativo de `createdAt` (fallback quando sem imagem).
  - Bottom navigation persistente no contexto da tela.

# 9. Perguntas em aberto
- Qual o contrato final dos endpoints backend para matches: `GET` sem paginacao e `PATCH/POST` para marcar como visto (path e payload exatos)? **R: GET /profiling/horses/{horseId}/matches e PATCH /profiling/horses/{fromHorseId}/matches/{toHorseId}**
- O payload para abrir `Conversations` deve usar `matchHorseId`, `ownerId` ou um `conversationId` quando ja existir conversa? **R: fora do escopo**
- Em caso de falha ao marcar item como visto, a navegacao para `Conversations` deve continuar (otimista) ou bloquear com erro? **R: fora do escopo**
