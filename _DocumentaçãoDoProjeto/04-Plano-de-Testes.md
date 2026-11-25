# Plano de Testes — Cuca Ativa

## 1. Objetivo
Verificar que o jogo cumpre os requisitos (RF, RNF e RN de `docs/requisitos.md`) e que as regras de
negócio se mantêm corretas a cada alteração do código.

## 2. Estratégia

| Nível | O que cobre | Como | Responsável |
|---|---|---|---|
| **Automatizado (unidade)** | Regras do jogo, tabuleiro, pontuação, ranking, salvamento, configurações, escolha das imagens, áudio básico | 9 suítes em `tests/`, 72 casos, com a base `McpTestSuite` do plugin godot-ai | Desenvolvedora |
| **Manual (funcional)** | Fluxos completos das telas, pausa, reinício, vitória, salvamento e retomada | Roteiro de casos (seção 5) executado no editor e no celular | Desenvolvedora |
| **Inspeção de usabilidade** | Problemas de usabilidade para pessoas idosas | Avaliação heurística de Nielsen (10 heurísticas, gravidade 0 a 4) — ver `docs/avaliacao-heuristica.md` | Desenvolvedora |
| **Acessibilidade** | Contraste, tipografia, área de toque, feedback não punitivo | Cálculo de contraste (WCAG) e conferência de tamanhos no tema e nas cenas | Desenvolvedora |

## 3. Ambiente
- **Automatizados:** Godot 4.7.2, executados pelo editor com o plugin godot-ai (`test_run`).
- **Manuais:** editor do Godot (computador) e APK instalado em celular Android 8.0 ou superior.
- **Ferramenta de execução:** não há framework externo de testes; usa-se a base `McpTestSuite` já
  incluída em `addons/godot_ai/testing/`. Cada arquivo `test_*.gd` precisa da anotação `@tool`.

## 4. Testes automatizados — suítes e escopo

| Suíte | Casos | Escopo | Requisitos |
|---|---|---|---|
| `test_score_rules` | 6 | Pontos do 1º acerto, escalada do combo, penalidade de erro, piso em 0, acúmulo normal, condição de vitória | RN01, RN02, RN03 |
| `test_board_generator` | 5 | Pares por nível, nº de cartas, cada id aparece 2×, nível inválido, tabuleiro embaralhado | RF01 |
| `test_game_manager` | 18 | Início/reinício, jogada inválida, acerto, erro, combo, vitória, cronômetro, restauração de estado salvo, dicas (custo, limite de 3, mínimo de pontos, ignora cartas já resolvidas) | RF02, RF08, RF13, RN01–RN04, RN06 |
| `test_save_manager` | 9 | Arquivo ausente, gravar/recarregar histórico, não perder entradas, partida em andamento, limpar, retomar sem save, tutorial visto | RF04, RF05, RF07, RF08, RN05 |
| `test_game_ranking` | 7 | Primeira partida, mais pontos à frente, empate decidido pelo tempo, outros níveis não contam, partidas idênticas, textos do selo, tom positivo | — |
| `test_card_icons` | 10 | Animais suficientes por nível, sem repetição, fotos existentes e carregáveis, pasta do nível correta, legenda com nome e som, sorteio com a quantidade pedida, distinto e variado | RF01, RF02 |
| `test_settings_manager` | 7 | Escala padrão, sinal ao mudar, aplicação ao tema, volta ao normal, textos de cena escalam, títulos não escalam, limite de 125% em textos limitados | RNF02 |
| `test_audio_manager` | 4 | Tons de acerto e erro gerados, volume padrão, limites do volume | RF03 |
| `test_time_format` | 6 | 0 s, só segundos, minutos e segundos, arredondamento, negativo vira 0, minutos grandes | RF07 |
| **Total** | **72** | | |

### Critérios
- **Aprovação:** todos os 72 casos passam.
- **Falha:** qualquer caso falhando bloqueia a entrega da alteração até ser corrigido.
- Os testes de salvamento usam um **arquivo temporário**, para nunca alterar o save real do jogador.

## 5. Testes manuais — roteiro de casos

| ID | Caso | Passos | Resultado esperado | Requisito |
|---|---|---|---|---|
| M01 | Tutorial no primeiro acesso | Abrir o app recém-instalado | Mostra o tutorial antes do menu; "Entendi!" leva ao menu; não volta a aparecer | RF05 |
| M02 | Escolher nível | Jogar → cada um dos 3 níveis | 16, 30 e 40 cartas; todas visíveis sem rolagem | RF01, RNF06 |
| M03 | Acerto | Virar duas cartas iguais | Tom, vibração, dança com partículas, nome falado, som e legenda; pontos sobem | RF03, RN01, RN03 |
| M04 | Erro | Virar duas cartas diferentes | Balanço suave, sem vermelho; cartas voltam após 1,5 s; −2 pontos (mínimo 0) | RF03, RNF04, RN01 |
| M05 | Dica | Tocar na estrela com ≥ 15 pontos | Moldura amarela pulsante em um par; −15 pontos; contador diminui; some após 3 usos | RF13, RN04 |
| M06 | Dica indisponível | Tocar com menos de 15 pontos | Botão esmaecido e sem efeito | RN04 |
| M07 | Pausa e continuar | Pausa → Continuar | Cartas travadas e cronômetro parado durante a pausa; tudo retoma ao continuar | RF06 |
| M08 | Reiniciar | Pausa → Reiniciar | Pontos e tempo zerados; cartas reembaralhadas no mesmo nível | RF06, RN06 |
| M09 | Sair | Pausa → Sair | Volta ao menu; "Continuar partida" aparece | RF06, RF08 |
| M10 | Vitória | Encontrar todos os pares | Aguarda ~3 s; mostra Parabéns com pontos, tempo e selo de lugar | RN02 |
| M11 | Histórico | Vencer e abrir Histórico | Nova linha com pontos, tempo e lugar; abandonar partida não cria linha | RF07, RN05 |
| M12 | Autosave e retomada | Jogar, pausar/fechar o app, reabrir, Continuar partida | Mesmas cartas, mesmas figuras, pontos, dicas e tempo | RF08 |
| M13 | Tamanho da letra | Configurações → Grande / Muito Grande | Textos crescem em todas as telas, sem cortar | RNF02 |
| M14 | Volume e vibração | Alterar cada opção | Volume desligado silencia; vibração tem interruptor próprio | RF03 |
| M15 | Offline | Abrir com internet desligada | Funciona normalmente | RNF07 |
| M16 | Instalação | Instalar o APK em Android 8.0+ | Instala e abre | RNF10 |

## 6. Testes de acessibilidade (checklist)

| Item | Critério | Como verificar |
|---|---|---|
| Contraste | ≥ 4,5:1 entre texto e fundo | Cálculo WCAG de cada combinação do tema |
| Tipografia | ≥ 18 sp, sem serifa | Tamanhos do tema (28/32 px) e das cenas |
| Área de toque | ≥ 48 × 48 dp | `custom_minimum_size` de todos os botões |
| Feedback não punitivo | Sem cronômetro regressivo, alarme ou vermelho de erro | Inspeção das telas e sons |
| Não depender só de cor | Som, texto, movimento ou vibração acompanham a cor | Inspeção do feedback de acerto e erro |

## 7. Riscos e limitações
- Não houve teste com número maior de usuários do público-alvo (pessoas idosas); a lacuna foi
  coberta pela avaliação heurística e por testes com professores e conhecidos.
- As telas, animações, áudio e vibração são verificados **manualmente**; os testes automatizados
  cobrem as regras, não a interface.
- Os testes foram feitos em um conjunto limitado de aparelhos.

## 8. Cobertura de requisitos (resumo)

| Requisito | Verificação |
|---|---|
| RF01–RF03, RF13 | Automatizado + manual |
| RF04, RF05, RF07, RF08 | Automatizado (salvamento) + manual |
| RF06 | Manual |
| RNF01–RNF04, RNF06 | Acessibilidade (checklist) + avaliação heurística |
| RNF07, RNF10 | Manual (M15, M16) |
| RN01–RN06 | Automatizado |
