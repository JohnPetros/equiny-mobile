# Guia de Documentação de Diretrizes do Projeto

Este arquivo serve como índice para as diretrizes de documentação do projeto. Consulte os arquivos específicos abaixo com base na tarefa em questão.

## Diretrizes de Interface de Usuário (ui)
**Arquivo:** `/documentation/rules/ui-layer-rules.md`
**Quando consultar:**
- Ao criar um documento relacionado a UI.
- Ao criar ou modificar Widgets Flutter (MVP Pattern).
- Para entender a estrutura View/Presenter.
- Para uso de gerenciamento de estado com `signals` e injeção com `riverpod`.
- Ao utilizar componentes do `shadcn_flutter`.

## Convenções de Código
**Arquivo:** `/documentation/rules/code-conventions-rules.md`
**Quando consultar:**
- Ao criar um documento relacionado ao código.
- Para convenções gerais de nomenclatura (variáveis, funções, classes, arquivos).
- Para regras sobre Barrel files (index.dart).
- Para entender a estrutura de diretórios e organização geral.

## Diretrizes da Camada de Drivers
**Arquivo:** `/documentation/rules/drivers-layer-rules.md`
**Quando consultar:**
- Ao criar um documento relacionado a drivers.
- Ao implementar adaptadores para bibliotecas externas (Env, Navegação, Armazenamento Loal, etc.).
- Para entender como isolar infraestrutura da camada de domínio (Core).
- Ao configurar inicializações de ferramentas de terceiros.

## Diretrizes do Pacote Core (core)
**Arquivo:** `/documentation/rules/core-layer-rules.md`
**Quando consultar:**
- Ao criar um documento relacionado à camada core.
- Para entender a arquitetura de Domínio (Clean Architecture).
- Ao definir Entidades, Casos de Uso (Use Cases) e Interfaces.
- Para contratos de abstração que serão implementados por Drivers ou Repositórios.

## Diretrizes da Camada REST
**Arquivo:** `/documentation/rules/rest-layer-rules.md`
**Quando consultar:**
- Ao criar um documento relacionado à camada rest.
- Ao realizar requisições HTTP para APIs externas.
- Para implementar clientes REST e tratamento de respostas/erros de API.

## Diretrizes de Testes Unitários
**Arquivo:** `/documentation/rules/unit-tests-rules.md`
**Quando consultar:**
- Ao criar um documento relacionado a testes unitários.
- Ao escrever testes para Casos de Uso, Presenters e outras classes de lógica.
- Para entender padrões de Mocks e Fakers.
- Para boas práticas de estrutura e nomenclatura de testes.

## Diretrizes de Desenvolvimento
**Arquivo:** `/documentation/rules/developement-rules.md`
**Quando consultar:**
- Ao criar um documento relacionado ao desenvolvimento.
- Para fluxo de trabalho Git (Commits, PRs, Branches).
- Para padrões de mensagens de commit e versionamento.
