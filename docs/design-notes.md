# Notas de Design (a partir do print do Figma)

Origem: print enviado pelo usuário em 2026-09-11, já que o MCP do Figma não tem acesso de
edição ao arquivo (`YLYCb5Q3mEpYYXNq4yHjeh`, node `72-508`). **Cores abaixo são estimativas
visuais**, não valores extraídos do arquivo — trocar por tokens exatos assim que o acesso
ao Figma for liberado (via `figma-design-sync` / skill `new-screen-from-figma`) ou o
usuário exportar os hex reais.

## Inventário de telas (8, todas em proporção retrato de smartphone)

| Tela | Conteúdo principal | RF/RN relacionado |
|---|---|---|
| Tela Inicial | Título "Jogo da Memória Cuca Ativa", botão Jogar (círculo verde), atalhos Histórico/Configurações | RF01 (entrada) |
| Tela Dificuldade | Botões Fácil / Médio / Difícil, Voltar | RF01 |
| Tela Tutorial | Texto guiado ("Toque em 2 cartas para encontrar o par correto!"), botão Entendi! | RF05 |
| Tela Tabuleiro | Header "Pontuação NN", grade de cartas (viradas mostram ícones de animais/frutas), botão Dica (estrela) e botão Pausa (II) | RF02, RF03, RF13, RN01-RN04 |
| Tela Pausa | Continuar / Reiniciar / Sair | RF06, RN06 |
| Tela Parabéns | "Parabéns!", Pontuação final, Tempo, ilustração, Jogar novamente / Sair | RN02, RN05 |
| Tela Histórico | Tabela "PONTOS \| TEMPO", lista de partidas, Voltar | RF07 |
| Tela Configurações | Volume do jogo (Desligado/Médio/Alto), Tamanho da letra (Padrão/Grande/Muito Grande), Voltar | RNF01/02 (não é um RF numerado no documento original — é uma tela de acessibilidade extra do design; manter e tratar como parte da Fase 2/6) |

## Paleta aproximada (estimativa visual — confirmar antes de finalizar)

| Papel | Cor aprox. | Uso observado |
|---|---|---|
| Fundo | `#F5E1B0` (creme/areia) | fundo de todas as telas |
| Texto/título | `#16215C` (azul-marinho) | títulos, texto de pontuação |
| Ação primária | `#4CAF50` (verde) | Jogar, Continuar, Entendi!, Jogar novamente, Médio |
| Ação secundária/destaque | `#F2B705` (dourado/amarelo) | Fácil, Dica, ícone Configurações |
| Ação terciária | `#2F6FED` (azul) | Difícil, ícone Histórico |
| Perigo/saída | `#E8574E` (vermelho-coral) | Voltar, Sair |
| Atenção/reinício | `#F2994A` (laranja) | Reiniciar |
| Carta virada para baixo | branco/creme claro com borda | grade do tabuleiro |

Já apliquei o fundo creme + texto navy no tema placeholder
(`res://assets/theme/base_theme.tres`) — contraste calculado ≈ 11.6:1, acima do mínimo de
4.5:1 (RNF01). As cores de botão por variante (verde/dourado/azul/vermelho/laranja) ainda
não têm stylebox próprio no tema; isso é trabalho da Fase 2 (`godot-scene-builder`), que
deve validar contraste de cada combinação antes de aplicar.

## Pendências para maior precisão

Pedir ao usuário (ou extrair via Figma, uma vez liberado o acesso):
- Hex exatos de cada cor acima.
- Assets dos ícones de carta (animais/frutas vistos nas telas de tabuleiro — papagaio,
  peixe, leão, etc.) como imagens exportáveis, já que não podem ser inferidos com precisão
  a partir do print.
- Textos completos de tutorial/telas de configuração, caso haja mais conteúdo do que o
  visível no print.
