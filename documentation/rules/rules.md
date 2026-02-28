# Guia de Documentação de Diretrizes do Projeto

Este arquivo é um índice para as diretrizes de documentação do projeto. Consulte o guia mais adequado ao tipo de mudança.

## UI (Interface de Usuário)
**Arquivo:** [`documentation/rules/ui-layer-rules.md`](./ui-layer-rules.md)

**Quando consultar:**
- Ao criar um documento relacionado a UI.
- Ao criar ou modificar Widgets Flutter (MVP Pattern).
- Para entender a estrutura View/Presenter.
- Para uso de gerenciamento de estado com `signals` e injeção com `riverpod`.
- Ao utilizar componentes do `shadcn_flutter`.

## Convenções de Código
**Arquivo:** [`documentation/rules/code-conventions-rules.md`](./code-conventions-rules.md)

**Quando consultar:**
- Ao criar um documento relacionado ao código.
- Para convenções gerais de nomenclatura (variáveis, funções, classes, arquivos).
- Para regras sobre Barrel files (index.dart).
- Para entender a estrutura de diretórios e organização geral.

## Drivers
**Arquivo:** [`documentation/rules/drivers-layer-rules.md`](./drivers-layer-rules.md)

**Quando consultar:**
- Ao criar um documento relacionado a drivers.
- Ao implementar adaptadores para bibliotecas externas (Env, Navegação, Armazenamento Local, etc.).
- Para entender como isolar infraestrutura da camada de domínio (Core).
- Ao configurar inicializações de ferramentas de terceiros.

## Core
**Arquivo:** [`documentation/rules/core-layer-rules.md`](./core-layer-rules.md)

**Quando consultar:**
- Ao criar um documento relacionado à camada core.
- Para entender a arquitetura de Domínio (Clean Architecture).
- Ao definir Entidades, Casos de Uso (Use Cases) e Interfaces.
- Para contratos de abstração que serão implementados por Drivers ou Repositórios.

## REST
**Arquivo:** [`documentation/rules/rest-layer-rules.md`](./rest-layer-rules.md)

**Quando consultar:**
- Ao criar um documento relacionado à camada REST.
- Ao realizar requisições HTTP para APIs externas.
- Para implementar clientes REST e tratamento de respostas/erros de API.

## WebSocket
**Arquivo:** [`documentation/rules/websocket-layer-rules.md`](./websocket-layer-rules.md)

**Quando consultar:**
- Ao criar ou modificar canais WebSocket (ex.: chat, presença e eventos realtime).
- Ao alterar o `WebSocketClient` e o ciclo de vida de conexão/sessão.
- Ao integrar atualizações em tempo real em presenters sem parse de JSON na UI.

## Testes Unitários
**Arquivo:** [`documentation/rules/unit-tests-rules.md`](./unit-tests-rules.md)

**Quando consultar:**
- Ao criar um documento relacionado a testes unitários.
- Ao escrever testes para Casos de Uso, Presenters e outras classes de lógica.
- Para entender padrões de Mocks e Fakers.
- Para boas práticas de estrutura e nomenclatura de testes.

## Desenvolvimento
**Arquivo:** [`documentation/rules/developement-rules.md`](./developement-rules.md)

**Quando consultar:**
- Ao criar um documento relacionado ao desenvolvimento.
- Para fluxo de trabalho Git (commits, PRs, branches).
- Para padrões de mensagens de commit e versionamento.
