# Diretrizes da Camada Core

A camada **Core** (`lib/core/`) contém as regras de negócio, contratos e estruturas de dados agnósticos a frameworks.

---

## Princípios Arquiteturais

### Independência de Framework

A camada Core **NÃO deve depender** de Flutter, Riverpod, Dio ou qualquer biblioteca externa.

### Direção de Dependência

```
UI → REST → Core ← Drivers
         ↘  ↓  ↙
       TODAS dependem do Core
       Core NÃO depende de nenhuma
```

### Inversão de Dependência (DIP)

Core define interfaces, outras camadas implementam:

```dart
// Core define
abstract class CatalogService {
  Future<RestResponse<List<ProductDto>>> fetchProducts();
}

// REST implementa
class YampiCatalogService implements CatalogService { ... }
```

---

## Padrões de Design

### DTO Pattern

Objetos simples para transferência de dados:

```dart
class ProductDto {
  final String id;
  final String name;
  final List<SkuDto> skus;

  ProductDto({required this.id, required this.name, required this.skus});
}
```

### Interface Segregation

Interfaces pequenas e específicas por domínio:

```dart
abstract class CatalogService { ... }
abstract class MarketingService { ... }
abstract class CheckoutService { ... }
```

### Result Pattern (RestResponse)

Encapsula sucesso/erro:

```dart
class RestResponse<Body> {
  Body get body;
  bool get isSuccessful;
  bool get isFailure;
  String get errorMessage;
  RestResponse<NewBody> mapBody<NewBody>(NewBody? Function(Body) mapper);
}
```

---

## Estrutura de Diretórios

```
lib/core/
├── {dominio}/
│   ├── dtos/
│   │   └── {entidade}_dto.dart
│   └── interfaces/
│       └── {dominio}_service.dart
├── global/
│   ├── interfaces/
│   │   ├── rest_client.dart
│   │   ├── env_driver.dart
│   │   └── navigation_driver.dart
│   └── responses/
│       ├── rest_response.dart
│       └── pagination_response.dart
└── constants/
    └── http_status_code.dart
```

---

## Convenções de Nomenclatura

| Tipo | Padrão Arquivo | Padrão Classe |
|------|----------------|---------------|
| DTO | `{entidade}_dto.dart` | `{Entidade}Dto` |
| Service Interface | `{dominio}_service.dart` | `{Dominio}Service` |
| Driver Interface | `{nome}_driver.dart` | `{Nome}Driver` |
| Response | `{nome}_response.dart` | `{Nome}Response` |

---

## Componentes Globais

### Interfaces

| Interface | Função |
|-----------|--------|
| `RestClient` | Contrato HTTP (GET, POST, PUT, DELETE) |
| `EnvDriver` | Contrato para variáveis de ambiente |
| `NavigationDriver` | Contrato para navegação |

### Responses

| Response | Função |
|----------|--------|
| `RestResponse<T>` | Wrapper de resposta HTTP |
| `PaginationResponse<T>` | Wrapper para listas paginadas |

---

## Boas Práticas

### ✅ Fazer

- DTOs com campos `final` (imutabilidade)
- Interfaces pequenas por domínio
- Generics tipados (`RestResponse<ProductDto>`)
- Named parameters com `required`
- Composição de DTOs

### ❌ Evitar

- Dependência de frameworks
- Lógica de apresentação em DTOs
- Lógica de persistência no Core
- Imports circulares
- Campos nullable sem necessidade
