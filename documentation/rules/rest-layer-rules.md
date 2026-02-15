# Diretrizes da Camada REST

A camada **REST** (`lib/rest/`) implementa a comunicação HTTP com APIs externas.

---

## Padrões de Design

### Adapter Pattern

`DioRestClient` adapta a biblioteca Dio para a interface `RestClient` do Core:

```dart
class DioRestClient implements RestClient {
  late final Dio _dio;
  // implementação dos métodos HTTP
}
```

### Service Pattern

Services implementam interfaces do Core e encapsulam chamadas HTTP:

```dart
class YampiCatalogService extends YampiService implements CatalogService {
  @override
  Future<RestResponse<List<ProductDto>>> fetchProducts() async {
    final response = await restClient.get('/catalog/products');
    return response.mapBody((body) => YampiProductMapper.toDtoList(body));
  }
}
```

### Template Method (Classe Base)

`YampiService` configura automaticamente base URL e headers:

```dart
class YampiService {
  YampiService(this.restClient, this.envDriver) {
    restClient.setBaseUrl(envDriver.get(Env.yampiApiUrl));
    restClient.setHeader('User-Token', envDriver.get(Env.yampiUserToken));
  }
}
```

### Mapper Pattern

Mappers convertem JSON para DTOs:

```dart
class YampiProductMapper {
  static ProductDto toDto(Json json) { ... }
  static List<ProductDto> toDtoList(Json json) { ... }
  static PaginationResponse<ProductDto> toDtoPagination(Json json) { ... }
}
```

---

## Tecnologias

| Biblioteca | Função |
|------------|--------|
| **dio** | Cliente HTTP |
| **flutter_riverpod** | Injeção de dependências |
| **flutter_dotenv** | Variáveis de ambiente |

---

## Estrutura de Diretórios

```
lib/rest/
├── rest_client.dart         # Provider do RestClient
├── services.dart            # Providers de serviços
├── types/
│   ├── json.dart            # typedef Json = Map<String, dynamic>
│   └── query_params.dart
├── dio/
│   └── dio_rest_client.dart
└── {provider}/              # ex: yampi/
    ├── services/
    │   ├── {provider}_service.dart         # Classe base
    │   └── {provider}_{domain}_service.dart
    └── mappers/
        └── {provider}_{entity}_mapper.dart
```

---

## Convenções de Nomenclatura

| Tipo | Padrão Arquivo | Padrão Classe |
|------|----------------|---------------|
| Service Base | `{provider}_service.dart` | `{Provider}Service` |
| Service Impl | `{provider}_{domain}_service.dart` | `{Provider}{Domain}Service` |
| Mapper | `{provider}_{entity}_mapper.dart` | `{Provider}{Entity}Mapper` |

### Métodos de Mapper

| Método | Uso |
|--------|-----|
| `toDto(Json)` | Converte único objeto |
| `toDtoList(Json)` | Converte lista |
| `toDtoPagination(Json)` | Converte resposta paginada |

---

## Boas Práticas

### ✅ Fazer

- Usar interfaces da camada Core
- Mappers com métodos estáticos
- Tratar null safety nos Mappers
- Configuração via EnvDriver

### ❌ Evitar

- Expor Dio para outras camadas
- Lógica de negócio nos Mappers
- Hardcode de URLs ou tokens
