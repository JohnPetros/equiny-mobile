# PRD Reference — Inbox

- Milestone GitHub (fonte de verdade): `https://github.com/JohnPetros/equiny/milestone/8`
- Ultima sincronizacao local: `2026-02-21`

## Status da implementacao mobile

- Inbox MVP implementada (lista, ordenacao por atividade, badge de nao lidas, estados loading/error/empty, navegacao para chat).
- Estado vazio refinado com layout final e CTA "Ir para Matches".
- Integracao REST criada para `GET /conversation/chats`, `GET /conversation/chats/{chatId}` e `POST /conversation/messages`.
- Rota `Routes.chat` adicionada para fluxo de abertura de thread.

## Observacoes

- Thread de chat permanece fora do escopo desta spec e foi mantida como placeholder tecnico.
