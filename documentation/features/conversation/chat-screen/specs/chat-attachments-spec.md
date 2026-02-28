---
title: Chat — Envio e Visualizacao de Anexos
prd: documentation/features/conversation/chat-screen/prd.md
status: concluido
last_updated_at: 2026-02-28
---

# 1. Objetivo

Habilitar o envio de anexos (imagens e documentos) na tela de chat do `equiny_mobile`, substituindo o botao `+` placeholder por um fluxo completo: selecao de arquivo via bottom sheet, upload para o storage (Supabase via URL assinada), envio da mensagem com referencia ao anexo via WebSocket, e renderizacao do anexo recebido na lista de mensagens com tres estados visuais (`enviando`, `pronto`, `falhou`). A implementacao estende o fluxo existente de `ChatScreenPresenter` e `ChatInputBar`, respeita a arquitetura em camadas `MVP + Riverpod + Signals`, e adota `file_picker` para documentos (PDF/DOCX/TXT) e `image_picker` para imagens.

# 2. Escopo

## 2.1 In-scope

- Habilitar o botao `+` no `ChatInputBar` para abrir bottom sheet de selecao.
- Selecao de imagens (`jpg`/`jpeg`/`png`/`heic`) via `image_picker`.
- Selecao de documentos (`pdf`/`docx`/`txt`) via `file_picker`.
- Limite de **3 anexos** por mensagem.
- Validacao de tamanho por tipo (imagem 2 MB, PDF 3 MB, DOCX 2 MB, TXT 100 KB).
- Preview dos arquivos selecionados no `ChatInputBar` antes do envio.
- Fluxo de upload: `generateUploadUrlsForAttachments` -> `FileStorageDriver.uploadFiles`.
- Salvar mensagem via REST (`POST /conversation/chats/:chatId/messages`) para obter `messageId` antes do upload.
- Envio da mensagem com lista de anexos via WebSocket (`MessageSentEvent`).
- Renderizacao do anexo recebido (proprio ou do recipient) na `MessageBubble` com tres estados: `enviando`, `pronto`, `falhou`.
- Imagem no estado `pronto`: miniatura inline; ao tocar, abrir visualizacao em tela cheia.
- Documento no estado `pronto`: card com nome e icone; ao tocar, abrir com `url_launcher`.
- Botao "Tentar novamente" por anexo no estado `falhou`.
- Renomear `AttachmentDto` em `lib/core/conversation/dtos/structures/` para `MessageAttachmentDto` para eliminar conflito de nomes com `lib/core/storage/dtos/structures/attachment_dto.dart`.

## 2.2 Out-of-scope

- Video e audio.
- Reacao, edicao, delecao e encaminhamento de mensagens.
- Indicadores "digitando..." e confirmacao de leitura.
- Compressao/redimensionamento de imagens antes do upload.
- Paginacao de anexos (historico de arquivos).
- Apagar conversa (escopo separado previsto no PRD).
- Push notifications de novas mensagens com anexo.

# 3. Requisitos

## 3.1 Funcionais

- **RF-01:** ao tocar no `+` habilitado, exibir bottom sheet com opcoes "Imagem" e "Documento".
- **RF-02:** "Imagem" abre `image_picker` (galeria); "Documento" abre `file_picker` com filtros por extensao.
- **RF-03:** nao permitir selecionar mais de 3 arquivos por mensagem (considerando anexos ja no preview).
- **RF-04:** validar tamanho de cada arquivo antes de incluir no preview; exibir erro inline se exceder limite.
- **RF-05:** exibir preview dos arquivos selecionados no `ChatInputBar` antes do envio.
- **RF-06:** ao enviar, criar a mensagem via REST primeiro (`POST /conversation/chats/:chatId/messages`) para obter `messageId`; o campo `content` pode ser `null` quando a mensagem contem somente anexos.
- **RF-07:** usar `messageId` e `chatId` para chamar `generateUploadUrlsForAttachments` e obter URLs assinadas.
- **RF-08:** fazer upload de **todos** os arquivos via `FileStorageDriver.uploadFiles`; bloquear o envio ate que todos os uploads sejam concluidos com sucesso — se qualquer upload falhar, nenhum `MessageSentEvent` e emitido e o presenter marca os itens com falha para retry individual.
- **RF-09:** emitir `MessageSentEvent` via WebSocket com as `keys` dos arquivos ja persistidos no storage; o servidor usa as `keys` recebidas para montar as referencias dos anexos na mensagem.
- **RF-10:** renderizar anexos em `MessageBubble` com estado `enviando` (progress indicator), `pronto` (imagem inline ou card de documento) e `falhou` (aviso + botao retry).
- **RF-11:** ao tocar em imagem no estado `pronto`, abrir `ChatImageViewer` (tela cheia).
- **RF-12:** ao tocar em documento no estado `pronto`, chamar `url_launcher` com a URL publica do arquivo.
- **RF-13:** botao "Tentar novamente" reprocessa somente o anexo com falha (retry por item); apos todos os retries bem-sucedidos, emitir o `MessageSentEvent` pendente.
- **RF-14:** mensagem pode ter texto + anexos ou somente anexos (`content` enviado como `null` ao REST quando nao ha texto).

## 3.2 Nao funcionais

- **RNF-01:** respeitar arquitetura em camadas; UI nao chama `RestClient` nem `FileStorageDriver` diretamente.
- **RNF-02:** estado reativo no presenter com `signals`; DI com `Riverpod`.
- **RNF-03:** `MessageAttachmentDto` (core/conversation) e `StorageAttachmentDto` (core/storage) devem ter nomes distintos e responsabilidades claras.
- **RNF-04:** operacoes de upload paralelas (um `Future.wait` por mensagem).
- **RNF-05:** manter padrao visual do tema atual (`AppThemeColors`, `AppSpacing`, `AppRadius`, `AppFontSize`).
- **RNF-06:** `file_picker` deve ser isolado via `DocumentPickerDriver` (interface no core + implementacao em drivers).

# 4. O que ja existe (inventario)

> Inclui apenas componentes relevantes para implementar o fluxo de anexos.

## 4.1 UI (`lib/ui/`)

- **`ChatScreenView`** (`lib/ui/conversation/widgets/screens/chat_screen/chat_screen_view.dart`) — tela de chat ja implementada; sera estendida para passar novos callbacks de anexo ao `ChatInputBar`.
- **`ChatScreenPresenter`** (`lib/ui/conversation/widgets/screens/chat_screen/chat_screen_presenter.dart`) — presenter central; sera estendido com estado e logica de selecao/upload de anexos.
- **`ChatInputBarView`** (`lib/ui/conversation/widgets/screens/chat_screen/chat_input_bar/chat_input_bar_view.dart`) — barra inferior existente com `+` desabilitado; sera modificada para habilitar o botao e exibir preview.
- **`MessageBubbleView`** (`lib/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_bubble_view.dart`) — bolha de texto; sera estendida para renderizar lista de anexos.
- **`MessageBubblePresenter`** (`lib/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_bubble_presenter.dart`) — presenter da bolha; sera estendido com helpers de tipo e estado de anexo.
- **`AppThemeColors/AppSpacing/AppRadius/AppFontSize`** (`lib/ui/shared/theme/app_theme.dart`) — tokens visuais reutilizados.

## 4.2 Core (`lib/core/`)

- **`MessageDto`** (`lib/core/conversation/dtos/entities/message_dto.dart`) — possui `List<AttachmentDto> attachments` (campo a ser atualizado para `List<MessageAttachmentDto>`).
- **`MessageAttachmentDto` (conversation)** (`lib/core/conversation/dtos/structures/attachment_dto.dart`) — DTO de anexo de mensagem com campos `kind`, `key`, `name`, `size`.
- **`FileStorageService`** (`lib/core/storage/interfaces/file_storage_service.dart`) — contrato ja possui `generateUploadUrlsForAttachments`.
- **`FileStorageDriver`** (`lib/core/storage/interfaces/file_storage_driver.dart`) — contrato com `uploadFiles`, `getFileUrl`.
- **`ConversationService`** (`lib/core/conversation/interfaces/conversation_service.dart`) — necessita de novo metodo `sendMessage`.
- **`MessageSentEvent`** (`lib/core/conversation/events/message_sent_event.dart`) — evento de envio via WebSocket; sera atualizado para incluir lista de `MessageAttachmentDto`.
- **`MediaPickerDriver`** (`lib/core/shared/interfaces/media_picker_driver.dart`) — contrato de selecao de imagens ja existente.

## 4.3 REST (`lib/rest/`)

- **`FileStorageService`** (`lib/rest/services/file_storage_service.dart`) — implementa `generateUploadUrlsForAttachments`; recebe `chatId`, `messageId` e `List<StorageAttachmentDto>`.
- **`ConversationService`** (`lib/rest/services/conversation_service.dart`) — implementa servico de conversa; necessita de `sendMessage`.
- **`MessageMapper`** (`lib/rest/mappers/conversation/message_mapper.dart`) — mapeia `MessageDto` e `MessageAttachmentDto`; `toDto` ja mapeia `attachments`.

## 4.4 Drivers (`lib/drivers/`)

- **`SupabaseFileStorageDriver`** (`lib/drivers/file-storage-driver/supabase/supabase_file_storage_provider.dart`) — implementa upload via URL assinada.
- **`ImagePickerMediaPickerDriver`** (`lib/drivers/media-picker-driver/image-picker/image_picker_media_picker_driver.dart`) — selecao de imagens via `image_picker`.
- **`fileStorageDriverProvider`** (`lib/drivers/file-storage-driver/index.dart`) — provider do driver de storage.
- **`mediaPickerDriverProvider`** (`lib/drivers/media-picker-driver/index.dart`) — provider do media picker.

# 5. O que deve ser criado

## 5.1 UI

### 5.1.1 Presenters/Stores

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_attachment_picker/chat_attachment_picker_presenter.dart` (**novo arquivo**)
  - **Responsabilidade:** orquestrar a selecao de arquivos via bottom sheet (imagem ou documento), validar tamanhos e alimentar a lista de `PendingAttachment` no presenter principal.
  - **Dependencias:** `MediaPickerDriver`, `DocumentPickerDriver`.
  - **Metodos:**
    - `pickImages()` — abre `image_picker`, valida tamanho, retorna `List<PendingAttachment>`.
    - `pickDocuments()` — abre `DocumentPickerDriver`, valida tamanho, retorna `List<PendingAttachment>`.
    - `validateFileSize(File file, String kind) -> String?` — retorna mensagem de erro ou `null`.

### 5.1.2 Views

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_attachment_picker/chat_attachment_picker_view.dart` (**novo arquivo**)
  - **Responsabilidade:** bottom sheet com duas opcoes ("Imagem" e "Documento"); fecha apos selecao ou cancelamento.
  - **Props:** `onPickImages`, `onPickDocuments`.
  - **Dependencias de UI:** `shadcn_flutter` (bottom sheet/modal), tema compartilhado.

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_image_viewer/chat_image_viewer_view.dart` (**novo arquivo**)
  - **Responsabilidade:** exibir imagem em tela cheia com suporte a zoom; botao de fechar.
  - **Props:** `String imageUrl`.
  - **Dependencias de UI:** `InteractiveViewer`, `AppThemeColors`.

### 5.1.3 Widgets

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/chat_screen/chat_attachment_picker/` (**nova pasta**)
  - **Responsabilidade:** bottom sheet de selecao de tipo de anexo.
  - **Props:** `onPickImages`, `onPickDocuments`.
  - **Estrutura de pastas (ASCII):**
```text
chat_attachment_picker/
  chat_attachment_picker_view.dart
  chat_attachment_picker_presenter.dart
  index.dart
```

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/chat_screen/chat_image_viewer/` (**nova pasta**)
  - **Responsabilidade:** visualizacao de imagem em tela cheia com zoom.
  - **Props:** `String imageUrl`.
  - **Estrutura de pastas (ASCII):**
```text
chat_image_viewer/
  chat_image_viewer_view.dart
  index.dart
```

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/chat_screen/chat_input_bar/pending_attachments_preview/` (**nova pasta interna**)
  - **Responsabilidade:** faixa horizontal de thumbnails/cards de arquivos pendentes acima do campo de texto; cada item tem botao `x` para remover e indicador de erro de validacao.
  - **Props:** `List<PendingAttachment> attachments`, `onRemove(int index)`.
  - **Widgets internos:** `PendingAttachmentItem` (thumbnail para imagem, card com icone para documento).
  - **Estrutura de pastas (ASCII):**
```text
chat_input_bar/
  chat_input_bar_view.dart
  index.dart
  pending_attachments_preview/
    pending_attachments_preview_view.dart
    index.dart
    pending_attachment_item/
      pending_attachment_item_view.dart
      index.dart
```

- **Arquivo/Pasta:** `lib/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_attachment_list/` (**nova pasta interna**)
  - **Responsabilidade:** renderizar lista de anexos dentro da `MessageBubble`; cada item usa `MessageAttachmentItem` com estado visual.
  - **Props:** `List<MessageAttachmentDto> attachments`, `Map<String, AttachmentUploadStatus> uploadStatusMap`, `onRetry(String key)`, `onOpenDocument(String url)`, `onOpenImage(String url)`.
  - **Widgets internos:** `MessageAttachmentItem` (imagem miniatura ou card de documento com estado).
  - **Estrutura de pastas (ASCII):**
```text
message_bubble/
  message_bubble_view.dart
  message_bubble_presenter.dart
  index.dart
  message_attachment_list/
    message_attachment_list_view.dart
    index.dart
    message_attachment_item/
      message_attachment_item_view.dart
      message_attachment_item_presenter.dart
      index.dart
```

## 5.2 Core

- **Arquivo:** `lib/core/conversation/dtos/structures/attachment_dto.dart` (**arquivo mantido com classe renomeada**)
  - **Tipo:** `dto`
  - **Contratos/assinaturas:**
    ```dart
    class MessageAttachmentDto {
      final String kind;   // 'image' | 'pdf' | 'docx' | 'txt'
      final String key;    // path no storage (usado para resolver URL publica)
      final String name;   // nome original do arquivo
      final double size;   // tamanho em bytes
    }
    ```
  - **Responsabilidade:** representar anexo ja persistido e associado a uma `MessageDto` (recebido via REST ou WebSocket).

- **Arquivo:** `lib/core/conversation/dtos/structures/pending_attachment.dart` (**novo arquivo**)
  - **Tipo:** `dto`
  - **Contratos/assinaturas:**
    ```dart
    class PendingAttachment {
      final String localId;      // UUID gerado localmente
      final File file;
      final String kind;         // 'image' | 'pdf' | 'docx' | 'txt'
      final String name;
      final double size;
      final AttachmentUploadStatus status;  // enum
      final String? errorMessage;
    }
    ```
  - **Responsabilidade:** representar um anexo selecionado localmente antes/durante o upload.

- **Arquivo:** `lib/core/conversation/enums/attachment_upload_status.dart` (**novo arquivo**)
  - **Tipo:** `enum`
  - **Contratos/assinaturas:** `enum AttachmentUploadStatus { sending, ready, failed }`
  - **Responsabilidade:** estados visuais do anexo na bolha de mensagem.

- **Arquivo:** `lib/core/shared/interfaces/document_picker_driver.dart` (**novo arquivo**)
  - **Tipo:** `interface`
  - **Contratos/assinaturas:**
    ```dart
    abstract class DocumentPickerDriver {
      Future<List<File>> pickDocuments({required List<String> allowedExtensions});
    }
    ```
  - **Responsabilidade:** contrato de selecao de documentos; implementado por `FilePickerDocumentPickerDriver`.

- **Mudanca em contrato existente:** `lib/core/conversation/interfaces/conversation_service.dart`
  - Adicionar metodo `sendMessage`:
    ```dart
    Future<RestResponse<MessageDto>> sendMessage({
      required String chatId,
      required String content,
      required List<MessageAttachmentDto> attachments,
    });
    ```

- **Mudanca em contrato existente:** `lib/core/storage/interfaces/file_storage_service.dart`
  - Atualizar assinatura de `generateUploadUrlsForAttachments` para receber `chatId`, `messageId` e `List<StorageAttachmentDto>`.

## 5.3 REST

- **Arquivo:** `lib/rest/mappers/conversation/message_attachment_mapper.dart` (**novo arquivo**)
  - **Service/Client:** mapper para `MessageAttachmentDto`.
  - **Metodos:**
    - `static MessageAttachmentDto toDto(Json json)` — converte JSON recebido da API/WebSocket.
    - `static Json toJson(MessageAttachmentDto dto)` — serializa para envio via WebSocket.
  - **Entrada/Saida:** `Json` <-> `MessageAttachmentDto`.

## 5.4 Drivers

- **Arquivo:** `lib/drivers/document-picker-driver/file-picker/file_picker_document_picker_driver.dart` (**novo arquivo**)
  - **Adapter/Driver:** implementacao de `DocumentPickerDriver` usando o package `file_picker`.
  - **Responsabilidade:** abrir o gerenciador de arquivos nativo com filtros de extensao (`pdf`, `docx`, `txt`); retornar `List<File>`.
  - **Dependencias:** `file_picker`.

- **Arquivo:** `lib/drivers/document-picker-driver/index.dart` (**novo arquivo**)
  - **Adapter/Driver:** provider `documentPickerDriverProvider` (`Provider<DocumentPickerDriver>`).
  - **Responsabilidade:** disponibilizar driver de documento para DI no presenter.

# 6. O que deve ser modificado

> Lista somente arquivos existentes.

- **Arquivo:** `lib/core/conversation/dtos/structures/attachment_dto.dart`
  - **Mudanca:** renomear classe `AttachmentDto` -> `MessageAttachmentDto`; manter campos `kind`, `key`, `name`, `size`.
  - **Justificativa:** eliminar conflito de nomes com `lib/core/storage/dtos/structures/attachment_dto.dart`.
  - **Camada:** `core`

- **Arquivo:** `lib/core/conversation/dtos/entities/message_dto.dart`
  - **Mudanca:** atualizar import e tipo de `List<AttachmentDto>` para `List<MessageAttachmentDto>`.
  - **Justificativa:** alinhar com renomeacao do DTO de anexo de mensagem.
  - **Camada:** `core`

- **Arquivo:** `lib/core/conversation/events/message_sent_event.dart`
  - **Mudanca:** adicionar campo `List<MessageAttachmentDto> attachments` no `_Payload` e na classe publica.
  - **Justificativa:** permitir envio de referencias de anexos via WebSocket junto com o conteudo textual.
  - **Camada:** `core`

- **Arquivo:** `lib/rest/mappers/conversation/message_mapper.dart`
  - **Mudanca:** atualizar import de `AttachmentDto` -> `MessageAttachmentDto`; delegar mapeamento de attachment a `MessageAttachmentMapper`.
  - **Justificativa:** consolidar logica de mapeamento de anexo no novo mapper dedicado.
  - **Camada:** `rest`

- **Arquivo:** `lib/rest/services/file_storage_service.dart`
  - **Mudanca:** ajustar `generateUploadUrlsForAttachments` para enviar `attachments` no body, serializando `StorageAttachmentDto` com `kind` e `name`.
  - **Justificativa:** alinhar o payload de upload ao contrato tipado do `FileStorageService` e manter metadados completos por anexo.
  - **Camada:** `rest`

- **Arquivo:** `lib/rest/services/conversation_service.dart`
  - **Mudanca:** implementar `sendMessage` com `POST /conversation/chats/:chatId/messages`; corpo inclui `content` e lista de `attachments` (serializada via `MessageAttachmentMapper.toJson`).
  - **Justificativa:** obter `messageId` do servidor antes de gerar URLs de upload (fluxo acordado).
  - **Camada:** `rest`

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_input_bar/chat_input_bar_view.dart`
  - **Mudanca:** habilitar botao `+`; receber novo callback `onAttachmentTap`; renderizar `PendingAttachmentsPreview` quando houver arquivos pendentes acima do campo de texto.
  - **Justificativa:** habilitar fluxo de selecao e preview de anexos na barra inferior.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_bubble_view.dart`
  - **Mudanca:** adicionar renderizacao de `MessageAttachmentList` abaixo do texto (se `attachments` nao vazio); passar `uploadStatusMap` e callbacks de retry/abertura.
  - **Justificativa:** exibir anexos dentro da bolha de mensagem.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_bubble_presenter.dart`
  - **Mudanca:** adicionar helpers `isImage(String kind)`, `isDocument(String kind)`, `attachmentIconData(String kind)`.
  - **Justificativa:** centralizar logica de apresentacao de tipo de anexo no presenter.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_screen_presenter.dart`
  - **Mudanca:** adicionar:
    - `Signal<List<PendingAttachment>> pendingAttachments`
    - Metodo `addPendingAttachments(List<PendingAttachment>)`
    - Metodo `removePendingAttachment(String localId)`
    - Metodo `retryAttachmentUpload(String localId)`
    - Logica de upload no fluxo `sendMessage`: criar mensagem via REST -> gerar URLs -> upload -> emitir WebSocket.
    - Injecao de `FileStorageService` e `DocumentPickerDriver`.
  - **Justificativa:** centralizar estado e orquestracao do ciclo de vida de anexos pendentes.
  - **Camada:** `ui`

- **Arquivo:** `lib/ui/conversation/widgets/screens/chat_screen/chat_screen_view.dart`
  - **Mudanca:** passar `onAttachmentTap` para `ChatInputBar` (abre `ChatAttachmentPicker`); passar callbacks de `openImage` e `openDocument` para `ChatMessagesList`.
  - **Justificativa:** conectar novos widgets de anexo ao fluxo existente da tela.
  - **Camada:** `ui`

- **Arquivo:** `lib/rest/services.dart`
  - **Mudanca:** sem alteracao de providers existentes; somente garantir que `fileStorageServiceProvider` continua disponivel para DI do presenter.
  - **Justificativa:** `ChatScreenPresenter` precisara de `fileStorageServiceProvider`.
  - **Camada:** `rest`

# 7. O que deve ser removido

- **Arquivo:** `lib/core/conversation/dtos/structures/attachment_dto.dart`
  - **Remocao:** classe `AttachmentDto` (campos `kind`, `key`, `name`, `size`).
  - **Motivo:** substituida por `MessageAttachmentDto` no arquivo `message_attachment_dto.dart`.
  - **Substituir por (se aplicavel):** `lib/core/conversation/dtos/structures/message_attachment_dto.dart`

> **Nota:** o DTO de upload da camada storage e necessario no fluxo atual; o servico recebe `chatId`, `messageId` e `List<StorageAttachmentDto>`.

# 8. Diagramas e referencias

## 8.1 Fluxo de dados (ASCII)

```text
-- Selecao de arquivo --
ChatInputBar(+) -> ChatAttachmentPickerView (bottom sheet)
  -> [Imagem] MediaPickerDriver.pickImages
  -> [Documento] DocumentPickerDriver.pickDocuments
  -> ChatAttachmentPickerPresenter.validateFileSize
  -> ChatScreenPresenter.addPendingAttachments
  -> PendingAttachmentsPreview (preview na barra)

-- Envio com anexos --
ChatInputBar.onSend
  -> ChatScreenPresenter.sendMessage
    1. ConversationService.sendMessage (POST REST) -> MessageDto (com id)
    2. FileStorageService.generateUploadUrlsForAttachments (chatId, messageId, StorageAttachmentDto)
    3. FileStorageDriver.uploadFiles (upload paralelo)
    4. [cada PendingAttachment] status = ready / failed
    5. ConversationChannel.emitMessageSentEvent (MessageSentEvent + attachments)
    -> websocket server

-- Recebimento --
ConversationChannel.listen
  -> presenter._onMessageReceived(MessageDto com attachments)
  -> messages signal atualizado
  -> MessageBubble renderiza MessageAttachmentList

-- Abertura de anexo --
MessageAttachmentItem.onTap
  -> [imagem] push ChatImageViewer (url_launcher ou Navigator.push)
  -> [documento] url_launcher.launchUrl(url)

-- Retry de falha --
MessageAttachmentItem(retry)
  -> ChatScreenPresenter.retryAttachmentUpload(localId)
    -> repete passos 2-5 para o anexo especifico
```

## 8.2 Layout/hierarquia visual (ASCII)

```text
ChatScreen
  |- ChatHeader
  |- Body
  |   `- ChatMessagesList
  |       `- MessageBubble
  |           |- TextContent (opcional, pode ser vazio)
  |           `- MessageAttachmentList
  |               `- MessageAttachmentItem
  |                   |- [enviando] CircularProgressIndicator + nome
  |                   |- [pronto/imagem] Image.network miniatura (toque -> ChatImageViewer)
  |                   |- [pronto/doc] Card: icone + nome (toque -> url_launcher)
  |                   `- [falhou] icone erro + "Tentar novamente"
  `- ChatInputBar (fixed)
      |- PendingAttachmentsPreview (faixa horizontal, condicional)
      |   `- PendingAttachmentItem (thumbnail/card + botao x)
      |- Row
      |   |- IconButton "+" (habilitado)
      |   |- TextField
      |   `- IconButton "Enviar"
      `- ChatAttachmentPickerView (bottom sheet, modal)
          |- ListTile "Imagem"
          `- ListTile "Documento"
```

## 8.3 Referencias internas

- `lib/ui/conversation/widgets/screens/chat_screen/chat_screen_presenter.dart` — presenter base a ser estendido.
- `lib/ui/conversation/widgets/screens/chat_screen/chat_input_bar/chat_input_bar_view.dart` — barra inferior com `+` a ser habilitado.
- `lib/rest/services/file_storage_service.dart` — implementacao de `generateUploadUrlsForAttachments`.
- `lib/drivers/file-storage-driver/supabase/supabase_file_storage_provider.dart` — upload via URL assinada.
- `lib/drivers/media-picker-driver/image-picker/image_picker_media_picker_driver.dart` — referencia de padrao de driver de picker.
- `lib/core/storage/interfaces/file_storage_service.dart` — contrato de servico de storage.

# 9. Decisoes finais

- O endpoint de criacao da mensagem foi confirmado como `POST /conversation/chats/:chatId/messages`.
- `content` pode ser `null` quando a mensagem contem somente anexos.
- O `MessageSentEvent` envia a lista de anexos com `keys` ja persistidas no storage.
- `file_picker` foi adicionado ao `pubspec.yaml` como dependencia direta.
- Em caso de falha de upload, o evento WebSocket e bloqueado ate os retries dos anexos com erro.

# 10. Validacao final

- `dart format .` executado com sucesso.
- `flutter analyze` executado sem warnings/erros.
- `flutter test` executado com todos os testes passando.
