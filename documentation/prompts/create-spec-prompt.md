---
description: Criar spec tecnica detalhada para implementacao no equiny_mobile
---

# Prompt: Criar Spec

**Objetivo:** detalhar a implementacao tecnica de uma `feature`, `fix` ou `refactor` no `equiny_mobile`, atuando como Tech Lead Senior. A `spec` deve ser a ponte entre contexto de produto, layout e implementacao, com nivel de detalhe suficiente para execucao sem ambiguidades.

**Contexto do projeto (leitura minima obrigatoria):**

- Produto (alto nivel): PRD em `documentation/overview.md` (fonte externa)
- Arquitetura: `documentation/architecture.md`
- Regras por camada: `documentation/rules/rules.md` (e os docs acionados por ele)

## Entrada

- Enunciado da mudanca (1-3 paragrafos) e motivacao.
- Links para PRD/issue/discussao (se existirem).
- Acesso a codebase atual para validar caminhos e exemplos similares.
- Id da tela no Google Stitch (quando houver impacto visual).

## Diretrizes de execucao

1. **Pesquisa e contextualizacao (sem expor `chain-of-thought`):**
   - Identifique **objetivo**, **escopo**, **risco** e **camadas impactadas**.
   - Mapeie o fluxo principal antes de escrever: `View -> Presenter/Store -> Provider -> Service -> RestClient -> API`.
   - Reuse/extenda componentes existentes; evite duplicidade de `Presenter`, `Store`, `Widget`, `DTO`, `Service` e `Driver`.
   - Consulte regras especificas conforme escopo:
     - Mudanca em UI/MVP/widgets -> `documentation/guidelines/ui-layer-rules.md`
     - Mudanca em contratos/entidades -> `documentation/guidelines/core-layer-rules.md`
     - Mudanca em integracao HTTP -> `documentation/guidelines/rest-layer-rules.md`
     - Mudanca em infraestrutura/adapters -> `documentation/guidelines/drivers-layer-rules.md`
     - Convencoes gerais -> `documentation/guidelines/code-conventions-guidelines.md`

2. **Ferramentas auxiliares:**
   - Use Serena para localizar arquivos e referencias na codebase.
   - Use Context7 apenas quando precisar de documentacao/exemplos de biblioteca especifica.
   - Use Google Stitch para validar layout e hierarquia visual quando houver `screen_id`.
   - Use a tool `question` para me fazer perguntas caso precise de mais informacoes para continuar.

3. **Qualidade e densidade:**
   - Seja direto; prefira listas e blocos curtos.
   - Use **negrito** para decisoes e `code` para termos tecnicos (ex: `Riverpod`, `Signals`, `GoRouter`, `Dio`, `shadcn_flutter`).
   - Escreva em PT-BR; mantenha termos de programacao em Ingles e em `code`.

## Estrutura do documento (modelo obrigatorio)

Use frontmatter e a hierarquia de cabecalhos sem pular niveis.

```md
---
title: <Titulo claro>
status: <em progresso|concluido>
last_updated_at: <AAAA-MM-DD>
---

# 1. Objetivo
<1 paragrafo: o que sera entregue funcionalmente e tecnicamente.>

# 2. Escopo

## 2.1 In-scope
- ...

## 2.2 Out-of-scope
- ...

# 3. Requisitos

## 3.1 Funcionais
- ...

## 3.2 Nao funcionais
- ...

# 4. O que ja existe (inventario)

> Inclua apenas itens realmente relevantes para implementar a mudanca.

## 4.1 UI (`lib/ui/`)
- **`NomeDaClasseOuWidget`** (`lib/ui/...`) - <como sera reutilizado>

## 4.2 Core (`lib/core/`)
- **`NomeDaClasse`** (`lib/core/...`) - ...

## 4.3 REST (`lib/rest/`)
- **`NomeDaClasse`** (`lib/rest/...`) - ...

## 4.4 Drivers (`lib/drivers/`)
- **`NomeDaClasse`** (`lib/drivers/...`) - ...

# 5. O que deve ser criado

> Liste apenas arquivos novos. Para cada arquivo, detalhe assinatura, responsabilidade, dependencias e estado quando aplicavel.

## 5.1 UI

### 5.1.1 Presenters/Stores
- **Arquivo:** `lib/ui/.../..._presenter.dart` ou `..._store.dart`
  - **Responsabilidade:** ...
  - **Dependencias:** ...
  - **Estado (`signals`/providers):** ...
  - **Computeds:** ...
  - **Metodos:** ...

### 5.1.2 Views
- **Arquivo:** `lib/ui/.../..._view.dart`
  - **Responsabilidade:** ...
  - **Props:** ...
  - **Dependencias de UI:** `shadcn_flutter`, tema, etc.

### 5.1.3 Widgets
- **Arquivo/Pasta:** `lib/ui/.../widgets/...`
  - **Responsabilidade:** ...
  - **Props:** ...
  - **Widgets internos:** ...
  - **Estrutura de pastas (ASCII):**
```text
widgets/
  <widget_pai>/
    <widget_pai>.dart
    widgets/
      <widget_filho>.dart
```

## 5.2 Core
- **Arquivo:** `lib/core/...`
  - **Tipo:** `dto` | `interface` | `entity` | `value_object`
  - **Contratos/assinaturas:** ...
  - **Responsabilidade:** ...

## 5.3 REST
- **Arquivo:** `lib/rest/...`
  - **Service/Client:** ...
  - **Metodos:** ...
  - **Entrada/Saida:** ...

## 5.4 Drivers
- **Arquivo:** `lib/drivers/...`
  - **Adapter/Driver:** ...
  - **Responsabilidade:** ...
  - **Dependencias:** ...

# 6. O que deve ser modificado

> Liste apenas arquivos existentes. Mudancas em arquivo novo ficam na secao 5.

- **Arquivo:** `lib/...`
  - **Mudanca:** ...
  - **Justificativa:** ...
  - **Impacto:** `ui` | `core` | `rest` | `drivers`

# 7. O que deve ser removido

> Remocoes precisam ser seguras (sem quebrar fluxo, import ou contrato publico). Se houver substituicao, aponte o novo caminho.

- **Arquivo:** `lib/...`
  - **Remocao:** ...
  - **Motivo:** ...
  - **Substituir por (se aplicavel):** `lib/...`

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)
```text
View -> Presenter/Store -> Provider -> Service -> RestClient -> API
```

## 8.2 Layout/hierarquia visual (ASCII)
```text
Screen
  |- Header
  |- Content
  |   |- Section A
  |   `- Section B
  `- Footer CTA
```

## 8.3 Referencias internas
- `lib/...` (arquivo similar usado como base)

## 8.4 Referencias de tela (quando houver)
- **Google Stitch screen id:** `<id>`
- **Decisoes de UI extraidas:** <bullet points curtos>
```

**Regras**

- Nao inclua testes automatizados na `spec`.
- Todos os caminhos citados devem existir no projeto (ou estar explicitamente marcados como **novo arquivo**).
- Se uma decisao tecnica depender de informacao ausente, registre em `Perguntas em aberto` no fim do documento.
