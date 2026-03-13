<h1 align="center">🐴 Equiny</h1>

Aplicativo mobile nativo desenvolvido em **Flutter** para conectar proprietarios de cavalos por meio de um fluxo de descoberta estilo swipe (like/dislike), com **match mutuo** e **chat em tempo real**.

## 🚀 Visao Geral

O Equiny foi criado para oferecer uma experiencia fluida de descoberta e conexao entre perfis de cavalos, incluindo:

- **Onboarding Guiado:** cadastro, autenticacao e criacao do perfil do dono e do cavalo.
- **Feed Inteligente:** descoberta de perfis com filtros e decisao rapida via like/dislike.
- **Matching Automatico:** conexao criada quando ha interesse mutuo entre perfis.
- **Conversas em Tempo Real:** chat entre perfis com match para alinhamento de detalhes.
- **Gestao de Perfil:** edicao de dados, fotos e controle de disponibilidade do cavalo.

## 🛠 Tech Stack

O projeto utiliza tecnologias modernas do ecossistema Flutter:

- **Linguagem:** [Dart](https://dart.dev)
- **Framework:** [Flutter](https://flutter.dev)
- **Gerenciamento de Estado & DI:** [Riverpod](https://riverpod.dev) + [Signals](https://pub.dev/packages/signals)
- **Interface (UI):** [Shadcn Flutter](https://pub.dev/packages/shadcn_flutter) + [Flutter Animate](https://pub.dev/packages/flutter_animate)
- **Navegacao:** [GoRouter](https://pub.dev/packages/go_router)
- **Cliente HTTP:** [Dio](https://pub.dev/packages/dio)
- **Realtime:** [web_socket_channel](https://pub.dev/packages/web_socket_channel)
- **Backend:** Integracao com **Equiny Server** (API RESTful)
- **Storage de midia:** [Supabase](https://supabase.com) via [supabase_flutter](https://pub.dev/packages/supabase_flutter)

## 🏗 Arquitetura

O projeto segue **Arquitetura em Camadas**, inspirada em Clean Architecture e MVP, priorizando desacoplamento, manutencao e testabilidade.

### Estrutura de Camadas

- **UI (`lib/ui`)**: Widgets, telas e presenters (MVP).
- **Core (`lib/core`)**: DTOs, contratos e tipos compartilhados de dominio.
- **Rest (`lib/rest`)**: Implementacoes HTTP e integracoes com API REST.
- **Drivers (`lib/drivers`)**: Adaptadores de infraestrutura (env, storage, integracoes externas).
- **WebSocket (`lib/websocket`)**: Comunicacao realtime para recursos de conversa e eventos.

Para mais detalhes tecnicos, consulte a [Documentacao de Arquitetura](documentation/architecture.md).

## 📂 Estrutura do Projeto

```bash
lib/
├── app.dart         # Bootstrap do app
├── core/            # Dominio, contratos e DTOs
├── drivers/         # Adaptadores de infraestrutura
├── rest/            # Comunicacao HTTP com API
├── shared/          # Componentes e utilitarios compartilhados
├── ui/              # Camada de apresentacao (Screens, Widgets, Presenters)
├── websocket/       # Camada de comunicacao realtime
├── router.dart      # Configuracao de navegacao (GoRouter)
└── main.dart        # Ponto de entrada
```

## ⚙️ Configuracao e Instalacao

### Pre-requisitos

- Flutter SDK **3.10.7** ou superior.

### Passo a passo

1. **Clone o repositorio:**
   ```bash
   git clone <url-do-repositorio>
   cd equiny_mobile
   ```

2. **Configure o ambiente:**
   Crie um arquivo `.env` na raiz do projeto com as chaves necessarias para API e servicos externos.

3. **Instale as dependencias:**
   ```bash
   flutter pub get
   ```

4. **Execute o app:**
   ```bash
   flutter run
   ```

## 📖 Documentacao

Documentacoes detalhadas estao no diretorio `documentation/`:

- [Visao Geral do Produto (PRD)](https://raw.githubusercontent.com/JohnPetros/equiny/refs/heads/main/documentation/overview.md)
- [Arquitetura e Decisoes Tecnicas](documentation/architecture.md)
- [Regras e Diretrizes do Projeto](documentation/rules/rules.md)

## 🧪 Testes

O projeto utiliza `flutter_test`, `mocktail` e `network_image_mock` para testes automatizados.

```bash
flutter test
```