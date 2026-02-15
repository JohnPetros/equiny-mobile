# Prompt: Criar Documento de Spec

## Objetivo
Detalhar a implementacao técnica de uma feature, fix ou refatoracao atuando como Tech Lead Senior.
O documento deve ser a ponte entre o PRD (Product Requirements Document) e o codigo, com nivel de detalhe suficiente para implementacao direta, sem ambiguidades.

## Entradas
- Esboco da spec ou solicitacao de mudanca.
- PRD associado (nivel superior).
- Acesso a codebase atual.
- Id da tela no Google Stitch

## Diretrizes de Execucao

### 1) Pesquisa e contextualizacao
- **Entender o PRD**: Acesse o link do PRD associado (nivel superior) e entenda o objetivo da tarefa usando Github ClI.
- **Mapear fluxo:** entender origem e destino dos dados (`UI -> Store -> Service -> API`) antes de escrever.
- **Verificar existencia:** identificar recursos existentes (widgets, DTOs, services) que devem ser reutilizados ou estendidos; evitar duplicidade.
- **Consultar rules:** revisar padroes das camadas (`core`, `rest`, `ui`, `drivers`) e da stack (Riverpod, Signals) conforme escopo.
- **Consultar Stitch:** revisar a tela no Google Stitch usando o MCP do Google Stitch.
- **Identificar referencias:** localizar exemplos similares na codebase para reaproveitamento inteligente.
- **Questionar:** Caso necessario, me faça perguntas para entender melhor o contexto da tarefa ou decidir questões técnicas usando sua tool `question`.


### 2) Estruturacao da spec
Gerar um arquivo Markdown seguindo exatamente a estrutura abaixo.

## Modelo Obrigatorio

### 1. Cabecalho (Frontmatter)
```yaml
title: [Titulo da Spec]
status: [concluido|concluida|em progresso]
lastUpdatedAt: [AAAA-MM-DD]
```

### 2. Objetivo (Obrigatorio)
Resumo em um paragrafo do que sera entregue, funcional e tecnicamente.

### 3. O que ja existe? (Obrigatorio)
Para cada camada impactada, listar recursos existentes da codebase.

Formato:
- **`NomeDaClasse`** (`caminho/relativo/do/arquivo.dart`) - *Breve descricao do uso (ex.: metodo a chamar, store a consumir).*

### 4. O que deve ser criado? (Quando aplicavel)
Descrever novos componentes por camada. Para cada arquivo novo, detalhar:

#### UI (Presenters, Stores)
- **Localizacao:** `caminho/do/arquivo.dart`
- **Dependencias:** o que deve ser injetado.
- **Signals/Estado:** variaveis reativas (ex.: `isLoading`, `items`).
- **Computeds:** variaveis derivadas (ex.: `isEmpty`, `totalPrice`).
- **Metodos:** assinatura e responsabilidade.

#### UI (Views)
- **Localizacao:** `caminho/do/arquivo.dart`
- **Bibliotecas de UI:** o que deve ser usado/injetado.
- **Props:** parametros recebidos no construtor.

#### UI (Widgets)
- **Localizacao:** `caminho/da/pasta`
- **Props:** parametros recebidos no construtor.
- **Widgets internos:** listar seguindo a mesma estrutura.
- **Estrutura de pastas:** representar em ASCII quando houver widgets internos.

> Todo widget deve seguir MVP: View e, quando houver estado/providers, Presenter.
> Se o widget tiver widgets internos, aplicar o mesmo padrao (Widgets, Views e Presenters).

#### REST (Services)
- **Localizacao:** `caminho/do/arquivo.dart`
- **Dependencias:** o que deve ser injetado.
- **Metodos:** assinatura e responsabilidade.

#### Drivers
- **Localizacao:** `caminho/do/arquivo.dart`
- **Dependencias:** o que deve ser injetado.
- **Metodos:** assinatura e responsabilidade.

> Nem todas as camadas sao obrigatorias. Escolha somente as necessarias para a tarefa.

### 5. O que deve ser modificado? (Quando aplicavel)
Para alteracoes em codigo existente:

#### [Nome da Camada]
- **Arquivo:** `caminho/do/arquivo.dart`
- **Mudanca:** descrever alteracao especifica (ex.: adicionar prop `onTap`, injetar novo service).

### 6. O que deve ser removido? (Quando aplicavel)

#### [Nome da Camada]
- **Arquivo:** `caminho/do/arquivo.dart`
- **Motivo:** explicar remocao e impacto.

### 7. Usar como referencia (Opcional)
- Links/caminhos para arquivos similares na codebase.

### 8. Diagramas e referencias
- **Fluxo de dados:** diagrama ASCII/texto com interacao entre camadas.
- **Layout:** ASCII da hierarquia visual para telas/widgets complexos.
- **Referencias:** caminhos de arquivos similares usados como base.

## Checklist de Validacao
- Estrutura obrigatoria seguida integralmente.
- Caminhos de arquivos conferidos na codebase.
- Sem duplicacao de componentes ja existentes.
- Decisoes alinhadas com guidelines da camada.
