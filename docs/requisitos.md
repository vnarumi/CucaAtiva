# Requisitos — Cuca Ativa

Transcrito de `Documento de Pré-Requisitos - Jogo da Memória Cuca Ativa[Projetos I].pdf`.
Esta é a fonte de verdade em versionamento — os subagentes devem consultar este arquivo,
não o PDF (que vive fora do repositório).

## 1. Contexto

Jogo de memória (cartas em pares embaralhados) para estímulo cognitivo de pessoas idosas.
Standalone, Android prioritário, ferramentas/bibliotecas livres e gratuitas. Três níveis de
dificuldade progressivos.

Público-alvo: declínio cognitivo leve, limitações visuais, dificuldades auditivas,
dificuldades motoras (tremores leves), baixo letramento digital.

## 2. Requisitos Funcionais (RF)

| ID | Nome | Descrição | Prioridade |
|---|---|---|---|
| RF01 | Seleção de Dificuldade | Fácil (16 cartas/8 pares), Médio (30 cartas/15 pares), Difícil (40 cartas/20 pares), escolhidos antes da partida | ESSENCIAL |
| RF02 | Mecânica do Jogo | Virar até duas cartas simultaneamente para tentar par | ESSENCIAL |
| RF03 | Feedback de Acerto/Erro | Sons distintos + animações visuais claras ao acertar/errar | ESSENCIAL |
| RF04 | Registro de Progresso | Salvar localmente pontuação e tempo de cada partida | IMPORTANTE |
| RF05 | Tutorial Interativo | Telas explicativas simples e guiadas no primeiro acesso | IMPORTANTE |
| RF06 | Controle de Partida (Pausa) | Botão de pausa: reiniciar, continuar, ou voltar ao menu | ESSENCIAL |
| RF07 | Histórico de Desempenho | Tela com pontuações anteriores e melhores tempos | DESEJÁVEL |
| RF08 | Salvamento Automático | Auto-save do estado da partida ao fechar inesperadamente/receber chamada | IMPORTANTE |
| RF13 | Sistema de Dicas | Botão "Dica" (uso limitado) que revela par ou vislumbre do tabuleiro | DESEJÁVEL |

## 3. Requisitos Não-Funcionais (RNF)

| ID | Nome | Descrição | Prioridade |
|---|---|---|---|
| RNF01 | Contraste | Taxa mínima 4.5:1 (WCAG) entre texto/elementos e fundo | ESSENCIAL |
| RNF02 | Tipografia | Textos principais ≥18sp, fontes sem serifa (Arial/Roboto/Open Sans) | ESSENCIAL |
| RNF03 | Área de Toque | Botões/cartas/áreas clicáveis ≥48x48dp | ESSENCIAL |
| RNF04 | Ambiente Amigável | Sem cronômetros regressivos, alarmes estressantes ou elementos punitivos | IMPORTANTE |
| RNF05 | Tempo de Resposta | Latência de virada de carta / transição de tela ≤200ms | IMPORTANTE |
| RNF06 | Responsividade | Adaptação dinâmica a diferentes tamanhos/proporções de tela | ESSENCIAL |
| RNF07 | Offline | 100% funcional sem internet para execução básica | ESSENCIAL |
| RNF08 | Estabilidade | Falhas críticas <1% das sessões iniciadas | IMPORTANTE |
| RNF09 | Privacidade (LGPD) | Sem coleta/armazenamento/transmissão de dados pessoais sem consentimento | ESSENCIAL |
| RNF10 | Compatibilidade | Exclusivo Android, desde Android 8.0 Oreo (API 26) | ESSENCIAL |

## 4. Regras de Negócio (RN)

| ID | Nome | Descrição |
|---|---|---|
| RN01 | Lógica de Pontuação | +10 por par correto, -2 por tentativa incorreta, piso em 0 |
| RN02 | Condição de Vitória | Partida finalizada quando todos os pares do nível forem encontrados |
| RN03 | Bônus de Combo | Acertos consecutivos sem erro: bônus +5 cumulativo por acerto (1º=10, 2º=15, 3º=20...). Reseta ao errar |
| RN04 | Sistema de Dicas | Dica custa 15 pontos, exige pontuação ≥15, máximo 3 dicas por partida |
| RN05 | Persistência do Histórico | Só grava histórico (RF07) em vitória; partidas abandonadas/reiniciadas/pausadas não geram registro |
| RN06 | Reinicialização de Partida | Reiniciar via pausa (RF06) zera progresso/cronômetro/pontuação e reembaralha o mesmo nível |
