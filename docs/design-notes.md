# Notas de Design (a partir dos SVGs exportados do Figma)

Origem: SVGs de todas as 16 telas/variantes do protótipo, exportados pelo usuário e salvos
em `assets/icons/raw/telas/` em 2026-09-11, já que o MCP do Figma não tem acesso ao arquivo
(`YLYCb5Q3mEpYYXNq4yHjeh`, node `72-508` — conta conectada tem assento "View" num plano
Starter). **Toda a paleta abaixo vem de hex exatos extraídos dos SVGs**, não de estimativa
visual — o processo de estimativa por print está encerrado.

Arquivos recebidos: Tela Inicial, Tela Dificuldade, Tela Tutorial, Tela Pausa, Tela
Parabéns, Tela Histórico (+ Vazio), Tela Configurações (+ Volume, + Letra), Tela Tabuleiro
Fácil/Médio/Difícil (cada uma com variante "com Dica").

## Inventário de telas

| Tela | Conteúdo principal | RF/RN relacionado |
|---|---|---|
| Tela Inicial | Título, botão Jogar (círculo verde), atalhos Histórico/Configurações | RF01 (entrada) |
| Tela Dificuldade | Botões Fácil / Médio / Difícil, Voltar | RF01 |
| Tela Tutorial | Texto guiado, botão Entendi! | RF05 |
| Tela Tabuleiro (Fácil/Médio/Difícil) | Header "Pontuação NN", grade de cartas, botão Dica (estrela), botão Pausa (círculo) | RF02, RF03, RF13, RN01-RN04 |
| Tela Pausa | Continuar / Reiniciar / Sair (modal) | RF06, RN06 |
| Tela Parabéns | "Parabéns!", pontuação/tempo, Jogar novamente / Sair (modal) | RN02, RN05 |
| Tela Histórico (+ Vazio) | Painel com tabela "PONTOS \| TEMPO", Voltar | RF07 |
| Tela Configurações (+ Volume, + Letra) | Volume do jogo, Tamanho da letra, checkmarks de seleção, Voltar | RNF01/02 (tela extra do design, não é RF numerado — tratar na Fase 2/6) |

## Paleta de cores — completa e confirmada

### Base
| Papel | Hex |
|---|---|
| Fundo de todas as telas | `#FCE8B1` |
| Texto/título (navy) | `#0B2973` |
| Cartões/painéis com sombra | `#FFFFFF` |

`#000000` só aparece nas definições `feColorMatrix` dos filtros de drop-shadow — não é cor
de UI. Já apliquei fundo `#FCE8B1` + texto `#0B2973` no tema placeholder
(`res://assets/theme/base_theme.tres`).

### Botões por tela (fill / borda / cor do rótulo)

| Botão / elemento | Tela(s) | Fill | Borda | Rótulo |
|---|---|---|---|---|
| Jogar | Inicial | `#2A9E00` | `#185702` | ícone branco |
| Histórico (atalho) | Inicial | `#58ADEB` | `#5199CE` | ícone branco |
| Configurações (atalho) | Inicial | `#FECE33` | `#DFB838` | ícone branco |
| Cabeçalho "Dificuldade" / Difícil | Dificuldade | `#58ADEB` | `#5199CE` | preto |
| Fácil | Dificuldade | `#FECE33` | `#AD8E2A` | preto |
| Médio | Dificuldade | `#AED22E` | `#6C8611` | preto |
| Voltar (tela cheia) | Dificuldade | `#FF6767` | *(sem borda própria)* | preto |
| Entendi! | Tutorial | `#AED22E` | `#748C20` | preto |
| Continuar | Pausa (modal) | `#AED22E` | `#5199CE` | preto |
| Reiniciar | Pausa (modal) | `#FECE33` | `#5199CE` | preto |
| Sair | Pausa (modal) | `#FF6767` | `#5199CE` | preto |
| Jogar novamente | Parabéns (modal) | `#AED22E` | `#5199CE` | preto |
| Sair | Parabéns (modal) | `#FF6767` | `#5199CE` | preto |
| Painel de lista (grande, ~545px de altura) | Histórico (+ Vazio) | `#FECE33` | `#DFB838` | texto navy |
| Badges de ícone (Volume / Tamanho da letra) | Configurações (todas) | `#FECE33` (pequenos, ~86x99) | `#DFB838` | ícone navy |
| Checkmark de opção selecionada | Configurações (todas) | `#4ABA34` | — | — |
| Voltar | Histórico, Configurações | `#FF6767` | — | preto |
| Pausa (círculo, dentro do jogo) | Tabuleiro (todas) | `#FECE33` | `#FECE33` (mesma cor) | ícone preto/navy |
| Dica (estrela) | Tabuleiro (todas) | `#FF9F3F` | — | — |
| Carta virada para baixo | Tabuleiro (todas) | `#FFFFFF` | `#0B2973`, 3px | — |

### Padronização de bordas — decisão tomada (2026-09-11)

O protótipo tinha duas inconsistências reais entre telas: (1) botões dentro de modais
(Pausa, Parabéns) sempre usavam borda azul `#5199CE` não importa o preenchimento, enquanto
telas de página inteira (Dificuldade, Tutorial) usavam uma borda no tom do próprio
preenchimento; (2) o mesmo preenchimento tinha bordas de tons ligeiramente diferentes em
telas diferentes (verde: `#6C8611` vs `#748C20`; dourado: `#DFB838` vs `#AD8E2A`).

Decisão (a critério do orquestrador, aprovada pelo usuário): **uma borda fixa por cor de
preenchimento, aplicada em toda tela, inclusive modais** — mais simples de manter no tema
do Godot e mais previsível para o usuário idoso (mesma cor = mesmo significado + mesmo
contorno em qualquer lugar do app). Tabela final, que substitui as variações do protótipo:

| Preenchimento | Borda padronizada | Critério de escolha |
|---|---|---|
| `#2A9E00` (Jogar) | `#185702` | única ocorrência no protótipo, sem conflito |
| `#58ADEB` (Histórico / Difícil) | `#5199CE` | já era consistente em todas as ocorrências |
| `#FECE33` (Configurações / Fácil / Reiniciar / painel Histórico) | `#DFB838` | maioria (3 de 4 ocorrências no protótipo já usava este tom) |
| `#AED22E` (Médio / Entendi! / Continuar / Jogar novamente) | `#6C8611` | tom mais escuro que `#748C20`, dá mais definição de borda contra o preenchimento claro |
| `#FF6767` (Voltar / Sair) | `#C23B3B` | não existia borda própria no protótipo (só a azul de modal ou nenhuma); escolhido um vermelho mais escuro na mesma família, coerente com o padrão dos demais pares fill/borda |

Isso muda o comportamento de 4 botões em relação ao protótipo original: Continuar e Jogar
novamente (verde) e Reiniciar e Sair (dourado/vermelho) deixam de usar a borda azul de
modal e passam a usar a borda da própria família de cor. Implementação real (styleboxes no
`base_theme.tres`) é trabalho da Fase 2 (`godot-scene-builder`) — esta tabela é a
especificação que a fase deve seguir.

### Contraste WCAG (texto preto sobre fundo colorido, RNF01 ≥ 4.5:1)

Todos os botões com rótulo preto testados passam com folga:

| Fundo | Contraste |
|---|---|
| `#FECE33` | ≈ 14.1:1 |
| `#AED22E` | ≈ 12.1:1 |
| `#58ADEB` | ≈ 8.6:1 |
| `#FF6767` | ≈ 7.4:1 |

## Ícones das cartas — extraídos dos SVGs (não são mais estimativa nem pendência!)

As variantes "com Dica" dos tabuleiros continham os ícones dos animais embutidos como
PNGs em base64 dentro do próprio SVG (revelados pela mecânica de dica). Extraí e
deduplicados por hash, resultando em 9 ícones únicos inicialmente.

**Atualização (Fase de fidelidade visual)**: o usuário tinha exportado individualmente, em
`assets/icons/raw/`, mais 10 arquivos SVG com ícones embutidos (fora da pasta `telas/`,
não processados até agora). Comparei por hash MD5 contra os 9 já extraídos: 9 eram
duplicatas exatas dos mesmos animais (confirma que a extração anterior já tinha pego
essas espécies certas), e **1 era genuinamente novo** — uma arara-vermelha (scarlet
macaw), visualmente diferente da arara azul-e-amarela já catalogada. Total agora:
**10 ícones únicos**, salvos em `res://assets/icons/cards/`:

| Arquivo | Animal |
|---|---|
| `elefante.png` | Elefante |
| `caracol.png` | Caracol |
| `chita.png` | Chita (o arquivo fonte estava nomeado "Onça", mas o animal na foto é uma chita — mantive o nome pela aparência real) |
| `porco.png` | Porco |
| `urso.png` | Urso |
| `coala.png` | Coala |
| `peixe_dourado.png` | Peixe dourado |
| `spitz.png` | Cachorro (spitz/pomerania) |
| `arara.png` | Arara azul-e-amarela |
| `arara_vermelha.png` | Arara vermelha (scarlet macaw) — nova, achada nesta passada |

São fotos reais (não ilustrações vetoriais simples) em fundo transparente/branco (a maioria
125x125px originais; `arara_vermelha.png` veio numa resolução bem maior — ~ordem de
1000x1000 — funciona normalmente, só pesa mais no disco; redimensionar é opcional/cosmético).
Cobrem os 8 pares do nível Fácil e dão folga para começar o Médio; para completar Médio
(15 pares) e Difícil (20 pares) ainda faltam ícones — restam 5 para o Médio e 10 para o
Difícil.

## Pendências restantes

- Ícones adicionais para completar 15 pares (Médio) e 20 pares (Difícil) — 10 de 20
  confirmados até agora (metade do caminho).
- Textos completos de tutorial (o SVG do Tutorial tem uma ilustração no lugar do texto
  central — o texto atual em `scenes/game/tutorial.tscn` é conteúdo funcional escrito por
  mim, não uma transcrição do protótipo).
- Ícones de UI (Jogar, atalhos Histórico/Configurações, Pausa, Dica, checkmark) — existem
  como caminhos vetoriais dentro dos SVGs de tela já enviados, mas extrair isso às cegas
  (sem conseguir visualizar o resultado) é arriscado; pedi ao usuário exports isolados
  desses ícones em `assets/icons/raw/ui/`.
