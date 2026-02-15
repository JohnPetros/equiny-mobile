# Drivers Layer Guidelines

## Visão Geral

A camada de **Drivers** (`lib/drivers/`) é responsável por fornecer as implementações concretas de infraestrutura e mecanismos externos definidos pelas interfaces da camada **Core** (`lib/core/`).

Esta camada isola o código dependente de bibliotecas externas e frameworks (como Router, DotEnv, LocalStorage, Firebase, etc.) do restante da aplicação, seguindo o padrão de **Inversão de Dependência**.

## Responsabilidades

*   Implementar interfaces de infraestrutura definidas no `Core`.
*   Encapsular chamadas a bibliotecas externas.
*   Adaptar APIs de terceiros para os contratos do domínio.
*   Configurar inicializações de ferramentas externas (quando necessário e não feito no `main`).
*   **NÃO** deve conter regras de negócio.
*   **NÃO** deve depender da camada UI ou Rest diretamente (exceto para tipos necessários, mas idealmente apenas Core).

## Estrutura de Diretórios

A organização deve ser feita por funcionalidade/driver, contendo a implementação e um arquivo de exportação.

```
lib/drivers/
├── env-driver/
│   ├── index.dart            # Exporta os drivers
│   └── dot_env_driver.dart   # Implementação concreta usando flutter_dotenv
├── navigation-driver/
│   ├── index.dart
│   └── go_router_navigation_driver.dart
└── [outros-drivers]/
```

## Convenções de Nomenclatura

*   **Pastas**: kebab-case (ex: `env-driver`, `local-storage-driver`).
*   **Arquivos**: snake_case (ex: `dot_env_driver.dart`).
*   **Classes**: PascalCase, geralmente terminando com o nome do driver ou implementação (ex: `DotEnvDriver`, `GoRouterNavigationDriver`) e implementando a interface do Core.

## Regras e Diretrizes

### 1. Dependência da Camada Core
Os drivers devem sempre implementar uma interface definida na camada **Core**. Isso garante que a aplicação não conheça a implementação concreta, mas sim o contrato.

**Certo (Core):**
```dart
// lib/core/global/interfaces/env_driver.dart
abstract class EnvDriver {
  String get(String key);
}
```

**Certo (Drivers):**
```dart
// lib/drivers/env-driver/dot_env_driver.dart
import 'package:sertton/core/global/interfaces/env_driver.dart';

class DotEnvDriver implements EnvDriver { ... }
```

### 2. Isolamento de Bibliotecas Externas
Evite vazar tipos de bibliotecas externas para fora desta camada. Se uma biblioteca retorna um objeto complexo, mapeie-o para um DTO ou tipo primitivo definido no Core.

### 3. Simplicidade
Mantenha as implementações o mais simples possível. O objetivo é apenas conectar a interface do Core à funcionalidade da biblioteca externa. Lógica complexa de decisão deve estar no Core (UseCases/Services) ou na UI (Presenters).

### 4. Tratamento de Erros
Capture erros específicos da biblioteca externa e, se necessário, lance exceções de domínio ou retorne valores padrão seguros, conforme definido no contrato da interface.

## Exemplos

### EnvDriver (Variáveis de Ambiente)

Implementação que utiliza o pacote `flutter_dotenv` para ler variáveis de ambiente.

```dart
// lib/drivers/env-driver/dot_env_driver.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sertton/core/global/interfaces/env_driver.dart';

class DotEnvDriver implements EnvDriver {
  @override
  String get(String key) {
    return dotenv.env[key] ?? '';
  }
}
```

### NavigationDriver (Navegação)

Implementação que utiliza o `go_router` para gerenciar a navegação. Observe como a dependência do `GoRouter` é injetada ou gerenciada internamente, adaptando para a interface `NavigationDriver`.

```dart
// lib/drivers/navigation-driver/go_router_navigation_driver.dart
import 'package:go_router/go_router.dart';
import 'package:sertton/core/global/interfaces/navigation_driver.dart';

class GoRouterNavigationDriver implements NavigationDriver {
  final GoRouter _router;

  GoRouterNavigationDriver(this._router);

  @override
  void go(String route, {Object? data}) {
    _router.go(route, extra: data);
  }

  @override
  void back() {
    if (_router.canPop()) {
      _router.pop();
    }
  }
}
```
