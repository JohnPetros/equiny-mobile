## 🎯 Objetivo
Este PR implementa a nova experiência completa da tela de perfil, entregando as abas de Cavalo e Dono com carregamento, edição e sincronização de dados com backend, substituindo placeholders e consolidando o fluxo de perfil no app.

## #️⃣ Issues relacionadas
- resolve JohnPetros/equiny#7

## 📋 Changelog
- Adiciona a estrutura da `ProfileScreen` com seletor de abas e navegação integrada.
- Implementa a aba **Cavalo** com formulário, galeria, checklist de prontidão e seção de status ativo.
- Implementa a aba **Dono** com formulário dedicado, seção de verificação e substituição do placeholder anterior.
- Expande contratos de domínio e interface (`HorseDto`, `OwnerDto`, `ProfilingService`) para suportar os novos fluxos de sincronização.
- Atualiza camada REST com mapeadores e serviços para leitura/atualização de owner, horse e galeria.
- Introduz contrato de storage (`FileStorageDriver`) e provider Supabase para upload de arquivos.
- Atualiza rotas e pontos de entrada para incluir a nova tela no fluxo principal.
- Cria/atualiza cobertura de testes de presenters e views de autenticação e perfil.
- Atualiza documentação de regras e specs das abas de perfil.

## 🧪 Como testar
1. Inicie o app e navegue até a tela de perfil.
2. Valide o carregamento inicial da aba **Cavalo** com dados e estado de sincronização.
3. Edite campos do cavalo, altere status ativo e confirme persistência/autosave.
4. Adicione/edite itens de galeria e valide sincronização e feedback visual.
5. Troque para a aba **Dono**, valide carregamento de dados e seção de perfil verificado.
6. Edite os campos permitidos do dono e confirme sincronização automática e tratamento de erro.
7. Execute a suíte de testes relacionada ao perfil e autenticação para confirmar regressão.

## 👀 Observações
- A implementação prioriza separação por responsabilidade no padrão MVP para facilitar manutenção.
- O fluxo foi dividido entre camadas de domínio, interface, REST e UI para manter baixo acoplamento.
- Existem commits separados por responsabilidade para facilitar revisão incremental.