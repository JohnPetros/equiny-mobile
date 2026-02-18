# Prompt: Conclude Spec

**Objetivo:**
Finalizar e consolidar a implementação de uma Spec técnica, garantindo que o código esteja polido, documentado, validado e pronto para a criação de um Pull Request.

**Entrada:**
*   **Spec Técnica:** O documento que guiou a implementação (`documentation/features/.../specs/...`).
*   **Código Implementado:** As alterações realizadas nas camadas UI, Core, Rest e Drivers.

**Diretrizes de Execução:**

1.  **Validação de Qualidade Final:**
    *   **Análise Estática:** Execute `flutter analyze` em todo o projeto para garantir que não existam warnings ou erros remanescentes.
    *   **Testes Unitários:** Execute `flutter test` para validar que todos os testes (novos e existentes) estão passando.
    *   **Formatação:** Garanta que todos os arquivos seguem o padrão do Dart com `dart format .`.
    *   **Diretrizes de codificação:** Garanta que todos os arquivos seguem `documentation\guidelines\code-conventions-guidelines.md`

2.  **Verificação de Requisitos:**
    *   Compare o código final com cada seção da Spec (O que deve ser criado/modificado).
    *   Certifique-se de que todos os componentes descritos foram implementados conforme planejado.

3. **Atualização da Documentação e Visualização:**
    *   Refine o documento da Spec original para refletir decisões de design de última hora ou mudanças de caminho.
    *   Leia o PRD associado a spec e atualize-o para refletir as alterações implementadas, caso necessário. O PRD é um link para um arquivo md no Github, então use o GitHub CLI para ler/atualizar o milestone.
    *   Caso seja necessário, rules associadas caso algum novo padrão de projeto não mapeado foi utilizado na implementação.
    *   **Diagramas ASCII:** Avalie se as mudanças implementadas alteraram fluxos complexos ou a navegação.
        *   **Ação:** Gere ou atualize um diagrama ASCII (fluxo de dados ou sequência) para facilitar a visualização da implementação final.
        *   Utilize a notação `ASCII` dentro de blocos de código específicos.

4.  **Geração de Resumo Final:**
    *   Forneça um resumo técnico do que foi concluído para facilitar a criação do PR subsequente.

