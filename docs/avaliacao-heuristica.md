# Avaliação heurística — Cuca Ativa

## 1. Objetivo e método

Esta avaliação verifica a usabilidade do jogo **Cuca Ativa** com as **10 heurísticas de usabilidade de
Jakob Nielsen**, tendo em vista o público-alvo (pessoas idosas). Trata-se de uma **inspeção de
especialista**: o avaliador percorre as telas e os fluxos do jogo e confronta cada um com as
heurísticas, registrando pontos fortes e problemas.

- **Versão avaliada:** aplicativo Android gerado em 24/11/2026 (Godot 4.7.2).
- **Telas e fluxos inspecionados:** menu principal, tutorial (primeiro acesso), seleção de dificuldade,
  tabuleiro (níveis Fácil, Médio e Difícil), pausa, tela de Parabéns, histórico e configurações.
- **Fontes de evidência:** uso do jogo nas telas citadas e leitura do código-fonte para confirmar o
  comportamento (referências indicadas em cada problema).
- **Gravidade (escala de Nielsen):** 0 = não é problema · 1 = cosmético · 2 = problema pequeno ·
  3 = problema grande, prioridade alta · 4 = catastrófico, corrigir antes de usar.

### Limitações
- Houve **um único avaliador**. O método recomenda de 3 a 5 avaliadores para encontrar a maior parte
  dos problemas; os resultados devem ser lidos como um primeiro levantamento.
- A avaliação **não substitui o teste com usuários idosos reais**, que é o passo seguinte natural.
- O comportamento do botão "voltar" do Android e o efeito da vibração só podem ser confirmados no
  aparelho e estão marcados como *a verificar*.

## 2. Resumo dos resultados

| Gravidade | Quantidade | Problemas |
|---|---|---|
| 3 – Grande | 2 | P01, P02 |
| 2 – Pequeno | 5 | P03, P04, P05, P06, P07 |
| 1 – Cosmético | 4 | P08, P09, P10, P11 |
| **Total** | **11** | |

O jogo cumpre bem as heurísticas ligadas a **linguagem, feedback, consistência e prevenção de erros
durante a jogada**. Os problemas mais relevantes estão em **ritmo do jogo** (tempo que as cartas
erradas ficam à mostra) e em **perda de progresso sem aviso** (sair ou reiniciar a partida).

## 3. Avaliação por heurística

### H1 — Visibilidade do estado do sistema
**Pontos fortes:** a pontuação fica sempre visível; cada acerto gera som, voz, legenda, animação e
vibração; o contador de dicas mostra quantas restam; a carta virada fica claramente diferente da
carta fechada; a tela de Parabéns mostra pontos, tempo e colocação.

**Problemas**
- **P03 (gravidade 2) — Não há indicação de progresso.** Só aparece a pontuação; o jogador não vê
  quantos pares já encontrou nem quantos faltam. *Recomendação:* exibir "Pares: 3 de 8".
- **P04 (gravidade 2) — O botão Dica fica esmaecido sem explicação.** Ele só funciona com no mínimo
  15 pontos e gasta 15 pontos (`HINT_COST` em `game_manager.gd`), mas a tela não informa nada disso.
  *Recomendação:* mostrar o custo no botão ("Dica: 15 pontos") ou uma mensagem ao tocar quando desativado.

### H2 — Correspondência entre o sistema e o mundo real
**Pontos fortes:** o jogo usa **fotografias reais de animais**, o nome falado e o som característico,
o que reproduz o jogo da memória físico; a linguagem é simples, em português do Brasil, sem
jargão ("Jogar", "Dica", "Pausa", "Parabéns!"); o selo de ranking usa "1º LUGAR".

**Problemas**
- **P08 (gravidade 1) — Não se explica como se ganham pontos.** A palavra "Pontuação" aparece, mas
  não há regra visível (acerto soma, dica subtrai). *Recomendação:* uma frase no tutorial.

### H3 — Controle e liberdade do usuário
**Pontos fortes:** menu de pausa com Continuar, Reiniciar e Sair; botão **VOLTAR** em todas as telas
secundárias, sempre na mesma posição; salvamento automático e "Continuar partida"; é possível
fechar o app a qualquer momento sem perder a partida.

**Problemas**
- **P01 (gravidade 3) — Reiniciar e Sair não pedem confirmação.** Um toque descarta a partida em
  andamento (`_on_sair_pressed` e `_restart_game` em `board.gd`), sem aviso e sem como desfazer. Os
  dois botões ficam próximos no menu de pausa, e um toque acidental é provável em quem tem menos
  precisão no toque. *Recomendação:* diálogo "Tem certeza? Você perderá a partida" com os botões
  "Continuar jogando" e "Sim, sair".
- **P05 (gravidade 2) — As configurações não são guardadas.** Volume, tamanho da letra e vibração
  voltam ao padrão toda vez que o aplicativo é aberto. Uma pessoa que precisa de letra grande teria
  de ajustá-la a cada uso. *Recomendação:* salvar as preferências em `SaveManager`.
- **P11 (gravidade 1) — *A verificar:* o botão "voltar" do sistema Android.** Não foi tratado
  explicitamente no código; é preciso confirmar no aparelho se ele leva ao menu, abre a pausa ou
  fecha o aplicativo.

### H4 — Consistência e padrões
**Pontos fortes:** identidade visual única (cores, fontes arredondadas, botões grandes coloridos);
botões de mesma função com a mesma cor (vermelho para sair/voltar, verde para avançar); o verso
das cartas e as fotos são iguais no tutorial e no jogo; o mesmo selo e a mesma legenda amarela
aparecem de forma consistente; textos de interface todos em português.

**Problemas**
- **P07 (gravidade 2) — "Sair" não encerra a partida de verdade.** Ao tocar em Sair na pausa, o jogo
  volta ao menu, mas a partida continua marcada como em andamento (`is_running`). Se o aplicativo for
  minimizado em seguida, ela é salva e passa a aparecer como "Continuar partida", mesmo tendo sido
  abandonada de propósito. O comportamento surpreende e contradiz o texto do botão.
  *Recomendação:* ao sair, encerrar a partida ou perguntar se deseja guardá-la.

### H5 — Prevenção de erros
**Pontos fortes:** enquanto duas cartas estão sendo comparadas, novos toques são ignorados; cartas
já encontradas ficam travadas; tocar duas vezes na mesma carta não conta como jogada; áreas de toque
grandes (cartas de cerca de 74 dp ou mais; botões acima de 48 dp); **errar o par não gera nenhuma
penalidade** (RNF04).

**Problemas**
- **P01** (ver H3): ações destrutivas sem confirmação.

### H6 — Reconhecimento em vez de memorização
**Pontos fortes:** todos os botões de ícone têm rótulo de texto (Histórico, Configurações, Voltar);
a opção escolhida em cada configuração aparece marcada com um sinal de visto; o histórico informa
nível, pontos, tempo e lugar de cada partida; as telas têm uma ação principal cada.

**Problemas**
- **P09 (gravidade 1) — O botão "Continuar partida" não mostra o que será retomado** (nível e
  quantos pares já foram feitos). *Recomendação:* acrescentar "Fácil – 3 de 8 pares".

### H7 — Flexibilidade e eficiência de uso
**Pontos fortes:** três níveis de dificuldade; três tamanhos de letra; três opções de volume;
vibração com interruptor próprio; dica opcional; "Continuar partida" evita recomeçar.

**Problemas**
- **P02 (gravidade 3) — O ritmo do jogo não se adapta ao jogador.** Quando o par está errado, as
  duas cartas voltam a ficar viradas depois de apenas **0,6 segundo** (`MISMATCH_REVEAL_SECONDS` em
  `board.gd`). Para pessoas idosas, esse tempo é curto para olhar e memorizar as duas figuras, o que
  é a essência do jogo, e pode gerar frustração. *Recomendação:* aumentar para cerca de 1,5 s e/ou
  oferecer na tela de Configurações a opção "Velocidade do jogo".

### H8 — Estética e design minimalista
**Pontos fortes:** telas limpas, com poucos elementos e muito espaço; hierarquia clara entre título,
conteúdo e ações; cores com bom contraste; texto grande; fotos em primeiro plano e sem poluição.

**Problemas**
- **P10 (gravidade 1) — Na tela de Parabéns o selo do ranking cobre parte da ilustração da arara.**
  Fica legível, mas a composição é pesada. *Recomendação:* deslocar a ilustração ou reduzir o selo.

### H9 — Ajudar o usuário a reconhecer, diagnosticar e corrigir erros
**Pontos fortes:** o jogo praticamente não gera situações de erro do tipo "mensagem de falha"; errar um
par apenas vira as cartas de volta, sem tom de reprovação (balanço suave, sem vermelho e sem
alarme); o jogador pode usar a Dica para se recuperar; a partida interrompida pode ser retomada.

**Problemas**
- A recuperação de um erro **grave** (sair da partida sem querer) não é possível: ver P01 e P07.

### H10 — Ajuda e documentação
**Pontos fortes:** tutorial **interativo** (2 × 2 cartas) no primeiro acesso, com a mesma aparência
do jogo; legendas que descrevem o som para quem ouve mal.

**Problemas**
- **P06 (gravidade 2) — O tutorial aparece uma única vez e não pode ser revisto.** O único acesso é
  automático no primeiro uso (`main_menu.gd`). Quem esquecer as regras não tem onde consultar.
  *Recomendação:* botão "Como jogar" no menu principal ou nas Configurações.
- Ver também P04 (função do botão Dica) e P08 (pontuação) como lacunas de ajuda.

## 4. Pontos fortes gerais
- **Acessibilidade como princípio de projeto:** letra de no mínimo 18 sp com duas opções maiores,
  alvos de toque amplos, contraste alto e ambiente sem pressão (RNF01 a RNF04).
- **Retorno multissensorial** a cada jogada: som, voz, legenda, animação e vibração.
- **Linguagem e conteúdo familiares:** animais reais, nomes falados, sem jargão.
- **Funcionamento offline**, sem coleta de dados.

## 5. Prioridades de correção

| Prioridade | Problema | Esforço estimado |
|---|---|---|
| 1 | P02 — Aumentar o tempo de exibição das cartas erradas | Pequeno (alterar uma constante) |
| 2 | P01 — Confirmação ao Reiniciar e Sair | Médio |
| 3 | P07 — Encerrar a partida ao sair | Pequeno |
| 4 | P05 — Guardar as configurações | Médio |
| 5 | P06 — Botão "Como jogar" | Pequeno |
| 6 | P03 — Mostrar "pares encontrados" | Pequeno |
| 7 | P04 — Explicar o custo da Dica | Pequeno |

## 6. Próximos passos
1. Corrigir os problemas de maior gravidade (P01 e P02).
2. Repetir a inspeção com **mais avaliadores** (3 a 5), idealmente com formação em IHC.
3. Realizar **teste de usabilidade com pessoas idosas**, observando o tempo de reação ao par errado,
   o uso do botão Dica e a compreensão do menu de pausa.
4. Verificar no aparelho os itens marcados como *a verificar* (botão "voltar" do Android, força da
   vibração).
