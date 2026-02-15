# Diretrizes da Camada UI

A camada **UI** (`lib/ui/`) é responsável pela apresentação visual e interação com o usuário.

---

## Padrões de Design

### MVP (Model-View-Presenter)

| Componente | Responsabilidade | Sufixo |
|------------|------------------|--------|
| **View** | Renderização visual, recebe eventos do usuário | `*_view.dart` |
| **Presenter** | Lógica de estado, orquestração, chamadas a services | `*_presenter.dart` |

```dart
// Presenter
class ProductsListPresenter {
  final CatalogService _catalogService;
  late final products = futureSignal(() => _catalogService.fetchProducts());

  ProductsListPresenter(this._catalogService);
}

// View
class ProductListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(presenterProvider);
    // renderiza usando presenter.products
  }
}
```

### Barrel Pattern (Index Files)

Cada componente expõe um `index.dart` com `typedef` público:

```dart
// index.dart
import 'catalog_screen_view.dart';
typedef CatalogScreen = CatalogScreenView;
```

### Widgets internos

- Se sentir necessário criar um widget interno, crie uma pasta para ele dentro da pasta do widget maior. Não crie um pasta `widgets` ou `components` dentro do widget pai.
- Widgets internos também devem seguir o padrão MVP (Model-View-Presenter).

### Signals (Estado Reativo)

| Tipo | Uso |
|------|-----|
| `signal<T>` | Estado síncrono simples |
| `futureSignal<T>` | Estado assíncrono (Future) |
| `computed<T>` | Estado derivado |

---

## Tecnologias

| Biblioteca | Função |
|------------|--------|
| **flutter_riverpod** | Injeção de dependências e providers |
| **signals** | Gestão de estado reativo granular |
| **shadcn_flutter** | UI Kit com componentes modernos |
| **go_router** | Navegação declarativa |

---

## Estrutura de Diretórios

```
lib/ui/
└── {modulo}/
    └── widgets/
        ├── screens/
        │   └── {tela}/
        │       ├── {tela}_screen_view.dart
        │       ├── {tela}_screen_presenter.dart (opcional)
        │       ├── index.dart
        │       └── {componente}/
        │           ├── {componente}_view.dart
        │           ├── {componente}_presenter.dart
        │           └── index.dart
        └── components/  (widgets reutilizáveis)
```

---

## Convenções de Nomenclatura

| Tipo | Padrão Arquivo | Padrão Classe |
|------|----------------|---------------|
| View | `{nome}_view.dart` | `{Nome}View` |
| Screen | `{tela}_screen_view.dart` | `{Tela}ScreenView` |
| Presenter | `{nome}_presenter.dart` | `{Nome}Presenter` |
| Export | `index.dart` | `typedef {Nome} = {Nome}View` |

---

## Tipos de Widgets

| Tipo | Base Class | Uso |
|------|------------|-----|
| **Screen** | `ConsumerWidget` ou `StatelessWidget` | Tela completa (rota) |
| **Layout** | `StatelessWidget` | Shell de navegação |
| **Component** | `ConsumerWidget` | Widget reutilizável com estado |

---

## Boas Práticas

### ✅ Fazer

- Todo e qualquer widget deve ser o padrão MVP (Model-View-Presenter)
- Caso o widget tenha apenas a parte visual, ele deve conter apenas a View e index.dart
- Separar View de Presenter
- Usar Signals para estado local
- Usar ConsumerWidget para acessar providers
- Criar arquivos index.dart para exportação
- Componentizar widgets complexos
- Ao criar um widget interno de um widget maior, crie uma pasta para ele dentro da pasta do widget maior.

### ❌ Evitar

- Lógica de negócio na View
- Chamadas diretas a Services (usar Presenters)
- Widgets monolíticos
- Import direto de `*_view.dart` (usar `index.dart`)
