# Plano de Desenvolvimento — Cuca Ativa

Roteiro por fases, cada uma mapeada aos requisitos de [requisitos.md](requisitos.md).
Esta conversa atua como orquestradora: cada fase é delegada aos subagentes definidos em
`.claude/agents/`, usando as skills em `.claude/skills/` para procedimentos recorrentes.

## Fase 0 — Scaffold do projeto (concluída nesta sessão)
Repositório git, estrutura de pastas, autoloads-esqueleto, tela principal mínima e
bootável, tema base com contraste/tipografia placeholder, subagentes/skills/hooks.
Sem lógica de jogo real ainda.

## Fase 1 — Loop principal (RF01, RF02, RN01, RN02, RN03)
- Seleção de dificuldade (16/30/40 cartas).
- Geração e embaralhamento do tabuleiro (`scripts/core/board_generator.gd`).
- Virar até 2 cartas, validar par.
- Pontuação com combo (`scripts/core/score_rules.gd`), lógica pura e testável.
- Agente: `godot-gameplay-engineer` (lógica) + `godot-scene-builder` (cena do tabuleiro).
- Testes: `tests/test_score_rules.gd`, `tests/test_board_generator.gd` via `godot-qa-tester`.

## Fase 2 — Feedback e acessibilidade (RF03, RNF01-04) — concluída nesta sessão
- Sons de acerto/erro (RF03): `AudioManager` gera tons curtos em memória (sem assets de
  áudio ainda) — acorde ascendente suave no acerto, tom grave curto no erro, sem nada
  alarmante (RNF04). Volume mestre ajustável via `set_master_volume`/`get_master_volume`.
- Animações de acerto/erro (RF03): `board.gd` faz um "pop" de escala no acerto e um leve
  balanço de rotação no erro — nenhuma cor piscando/estroboscópica (RNF04).
- Tema com contraste ≥4.5:1 (RNF01): 5 variações de tema (`GreenButton`, `BlueButton`,
  `YellowButton`, `LimeButton`, `RedButton`) com as cores padronizadas de
  [design-notes.md](design-notes.md), rótulo preto (contraste 6.0:1 a 14.1:1 conforme a cor)
  aplicadas em `main_menu`, `difficulty_select`, `settings` e a variação `CardButton`
  (branco/navy) nas cartas do tabuleiro.
- Fontes ≥18sp (RNF02): base 28px (botão)/32px (label), escaláveis em runtime via o novo
  autoload `SettingsManager.set_font_scale()` (1.0 normal / 1.25 grande) — muta o Theme
  carregado em memória, nunca grava no `.tres`.
- Áreas de toque ≥48x48dp (RNF03): cartas 64x64, botões 56-64px de altura em todas as
  telas novas.
- Sem cronômetro regressivo/alarmes (RNF04): nenhum timer regressivo existe; feedback
  sonoro/visual é suave e não-punitivo (ver acima).
- Tela Configurações (`scenes/game/settings.tscn`, não é um RF numerado, serve RNF01/02):
  badges discretos Mudo/Baixo/Alto ligados a `AudioManager` e Normal/Grande ligados a
  `SettingsManager`, cada um com um checkmark verde real (`#4ABA34`, label "✓" próprio,
  não texto embutido no botão) na opção ativa — corrigido depois do usuário apontar que a
  primeira versão (slider contínuo + "✓" em texto) fugia do protótipo, que usa badges com
  checkmark de cor fixa. Voltar para o menu. Acessível pelo botão "Configurações" no menu
  principal.
- Testado ao vivo: 25 testes automatizados passando (`score_rules`, `board_generator`,
  `game_manager`, `audio_manager`, `settings_manager`) + smoke test manual via cliques
  reais simulados (menu → dificuldade → tabuleiro → acerto/erro → configurações → volume
  → tamanho de letra), sem erros de runtime.
- Pendência conhecida, adiada de propósito: as cartas do tabuleiro ainda mostram o número
  do par (placeholder), não os ícones de animal reais em `assets/icons/cards/` — só 9 de
  até 20 ícones existem (insuficiente para Médio/Difícil), então a integração de ícones
  fica para quando o conjunto completo existir ou uma solução de fallback for definida.
  Estilos de hover/pressed dos botões (além de "normal") também não foram customizados —
  cosmético, não bloqueia nenhum RNF.

## Fase 3 — Persistência (RF04, RF07, RF08, RN05) — concluída nesta sessão
- `GameManager` ganhou cronômetro progressivo (RF04, `elapsed_seconds`/`is_running`, nunca
  regressivo — RNF04) e `restore_state(dict)` para repor um estado salvo, normalizando os
  tipos que voltam de JSON (chaves de Dictionary viram String, números podem virar float).
- `SaveManager` autoload (`scripts/autoload/save_manager.gd`), lendo/escrevendo
  `user://save_data.json` (JSON simples: `{"history": [...], "in_progress": {...}}`):
  - `autosave_in_progress()` (RF08): captura o estado atual do `GameManager` (dificuldade,
    board, pontuação, combo, pares encontrados, cronômetro) — disparado automaticamente em
    `NOTIFICATION_APPLICATION_PAUSED`/`FOCUS_OUT`/`WM_CLOSE_REQUEST`.
  - `resume_in_progress()`: repõe esse estado salvo de volta no `GameManager` via
    `restore_state`.
  - `_on_game_won()` (RF07/RN05): só grava uma entrada de histórico (dificuldade, pontuação,
    tempo, data) quando o sinal `game_won` dispara — partidas abandonadas/reiniciadas/
    pausadas nunca chegam a esse caminho, então nunca geram registro (RN05). Vitória também
    limpa o autosave (nada para retomar depois de vencer).
- Testado: 35 testes automatizados passando. A persistência pura de `SaveManager`
  (load/save/histórico/in_progress) é testada isolada via `test_run`; a integração com o
  autoload `GameManager` real (`autosave_in_progress`/sinal `game_won`) não dá para testar
  via `test_run` — dentro do editor parado, autoloads são só "placeholders" sem estado, não
  instâncias vivas — então foi verificada por smoke test manual com o jogo rodando de
  verdade (`project_run` + `game_eval`): autosave → "reabrir app" (perde o estado em
  memória) → retomada com todos os campos corretos, e vitória gravando exatamente 1
  entrada de histórico e limpando o autosave.
- Pendência adiada de propósito: ainda não há UI para o jogador ver o histórico (RF07,
  tela dedicada) nem para retomar uma partida salva a partir do menu — isso é trabalho da
  Fase 4 (`Tela de histórico`, menu de pausa), que consome a API já pronta aqui
  (`SaveManager.history`, `has_in_progress()`, `resume_in_progress()`).

## Fase 4 — Telas de apoio (RF05, RF06, RF07, RN06) — concluída nesta sessão
- Tutorial interativo (RF05): `scenes/game/tutorial.tscn` — texto guiado simples (a cópia
  exata do protótipo não foi capturada nos SVGs recebidos, só uma ilustração; escrevi um
  texto claro cobrindo RF01/RF02/RN01 como conteúdo funcional). Aparece automaticamente no
  primeiro acesso (`main_menu.gd` verifica `SaveManager.seen_tutorial`) e nunca mais depois
  do botão "Entendi!" (`SaveManager.mark_tutorial_seen()`, persistido).
- Menu de pausa (RF06): novo `PausaButton` no cabeçalho do tabuleiro abre um overlay
  (`PauseOverlay`, `process_mode = ALWAYS`) com Continuar/Reiniciar/Sair. Usa o pause nativo
  do Godot (`get_tree().paused`) — os botões do tabuleiro, sendo `PROCESS_MODE_INHERIT`
  (padrão), param de responder a clique sozinhos enquanto pausado, e o cronômetro do
  `GameManager` (`_process`) congela junto, sem nenhum código extra para isso.
  - Continuar: despausa e fecha o overlay.
  - Reiniciar (RN06): chama `GameManager.restart()` (zera pontuação/cronômetro/progresso e
    reembaralha o mesmo nível), reconstrói a grade, despausa.
  - Sair: despausa (importante — trocar de cena com a árvore pausada deixaria a próxima
    cena pausada também) e volta ao menu principal.
- Tela de histórico (RF07): `scenes/game/history.tscn`, lista as vitórias
  (`SaveManager.history`, mais recente primeiro) como "Dificuldade — Pontos — Tempo"
  (`TimeFormat.mmss`), com estado vazio ("Nenhuma partida vencida ainda...") quando não há
  registros. Acessível pelo novo botão "Histórico" no menu principal.
- Novo helper puro `scripts/core/time_format.gd` (`TimeFormat.mmss`) para formatar segundos
  como MM:SS, usado pela tela de histórico.
- Testado: 43 testes automatizados passando. Smoke test manual completo com o jogo
  rodando: primeiro acesso mostra tutorial → "Entendi!" vai pro menu → não aparece de novo
  → Histórico mostra estado real (inclusive uma entrada pré-existente do save real,
  confirmando persistência entre execuções) → Jogar → Pausa trava cliques nas cartas e
  congela o cronômetro (confirmado comparando `elapsed_seconds` entre duas checagens
  consecutivas) → Continuar libera tudo de novo → Reiniciar zera score/cronômetro/`matched`
  e reembaralha → Sair volta ao menu sem deixar a árvore pausada.
- Pendência adiada de propósito: não há botão "Continuar partida salva" no menu principal
  consumindo `SaveManager.resume_in_progress()` — a API está pronta desde a Fase 3, mas
  decidir a UX disso (quando oferecer, o que acontece se o jogador ignorar) não foi pedido
  explicitamente; fica como possível incremento futuro.

## Fase 5 — Dicas (RF13, RN04) — concluída nesta sessão
- `GameManager.can_use_hint()`/`use_hint()`: exige partida ativa, `hints_used < 3` e
  `score >= 15` (RN04). `use_hint()` procura o primeiro par ainda não encontrado (nem
  atualmente virado) via `_find_unmatched_pair()`, cobra 15 pontos, incrementa
  `hints_used` e emite `hint_used(a, b)` com os 2 índices — só revela, não marca como
  encontrado nem soma pontos de acerto. Sem par disponível (ou sem saldo/limite), retorna
  `[]` sem cobrar nada. `restart()` já zera `hints_used` (reaproveitado da Fase 1).
- Escolhi "revela um par" (não "vislumbre do tabuleiro inteiro") entre as duas
  interpretações que RF13 permite — mais controlado e fácil de entender para o público
  idoso do que piscar o tabuleiro inteiro.
- Botão "Dica (N)" no cabeçalho do tabuleiro (tema `OrangeButton`, `#FF9F3F`/borda mais
  escura `#CC7F32`, mesmo padrão de padronização das outras cores): mostra dicas
  restantes, desabilita sozinho quando indisponível (sem saldo, limite atingido, ou
  partida não ativa) — atualizado a cada mudança de pontuação e após cada uso. Ao usar,
  revela as 2 cartas do par por 1.5s e esconde de novo, a menos que o jogador já tenha
  virado uma delas "pra valer" nesse meio-tempo (nesse caso não mexe, pra não conflitar
  com o fluxo normal de virar carta).
- Testado: 51 testes automatizados passando (9 novos cobrindo custo, limite de 3, par
  ignorando cartas já encontradas/viradas, reset no reinício, e bloqueio após vitória).
  Smoke test manual com o jogo rodando: botão nasce desabilitado (pontuação 0), habilita
  ao atingir 15 pontos, clique real cobra os 15 pontos e revela o par corretamente, e o
  par volta a ficar oculto sozinho depois do tempo, sem intervenção manual.

## Fase 6 — Polimento (RNF05, RNF06, RNF08) — concluída nesta sessão
- RNF05 (latência ≤200ms): medido de verdade em runtime, não estimado — virar uma carta
  (clique → `flip_card` → atualização visual) leva **~0.06ms**; uma transição de cena
  completa (`change_scene_to_file`, 2 frames) leva **~16ms**. Ambos com folga enorme sobre
  o limite; não havia nenhum delay artificial no caminho de clique pra começar.
- RNF06 (responsividade): achado real — `main_menu.tscn` era a única tela ainda usando
  botões com âncora central + offset fixo em vez de um container, sobrevivendo desde a
  Fase 0. Refeita com um `VBoxContainer` (`Layout`), igual às demais telas. Ao migrar,
  descobri que `HistoricoButton` e `ConfiguracoesButton` nunca tinham `custom_minimum_size`
  — dependiam do offset antigo pra ter tamanho, e dentro do container encolheram para
  ~47px de altura, abaixo do mínimo de toque de 48dp (RNF03). Corrigido (240x64, igual aos
  outros). Auditei `custom_minimum_size` em **todos** os botões do projeto (grep por
  arquivo) — os outros 5 arquivos de cena já tinham cada botão coberto corretamente.
  - Projeto usa `window/stretch/mode=canvas_items` + `aspect=expand` (herdado da Fase 0):
    nesse modo a dimensão mais restritiva fica fixa no valor base (1152 de largura ou 648
    de altura) e a outra dimensão só cresce, nunca encolhe abaixo da base — ou seja, em
    qualquer celular em retrato (mais estreito que 16:9) a largura lógica disponível para
    o tabuleiro nunca fica abaixo de 1152px, dando folga de sobra para os 8 cards x 64px
    (512px) do nível Difícil. Não consegui redimensionar a janela embutida do editor via
    script para confirmar isso empiricamente (o `godot-ai` roda o jogo numa view embutida
    que ignora `window.size` alterado por código) — essa conclusão vem da aritmética do
    modo `expand` documentada pela engine, não de um teste visual direto; vale confirmar
    num dispositivo Android real antes do lançamento (Fase 7).
- RNF08 (estabilidade): rodei uma partida "Fácil" completa até a vitória de verdade pela
  primeira vez nesta sessão (as fases anteriores só testavam trechos/tabuleiros forçados)
  — 8/8 pares, pontuação 220 (combo perfeito), sinal `game_won` disparado, histórico
  gravado corretamente, zero erros no log do jogo. Revisão de código não achou acesso a
  array/dicionário sem guarda (`matched.has`, `_flipped.has`, checagens de índice já
  presentes desde a Fase 1).
- Testado: 51 testes automatizados continuam passando após a refatoração do menu.
- Agentes: `godot-scene-builder` + `godot-qa-tester`.

## Fase 7 — Exportação Android (RNF09, RNF10) — auditoria feita, export manual pendente
- RNF09 (LGPD) — auditado e confirmado: `grep` em todo `scripts/` por
  `HTTPRequest`/`HTTPClient`/`WebSocket`/`OS.get_unique_id`/`OS.request_permission`/nomes de
  SDKs de analytics/anúncios (`Analytics`, `Telemetry`, `AdMob`, `Firebase`) não encontrou
  nada — o jogo não faz nenhuma chamada de rede nem coleta identificador algum. Toda
  persistência é local (`user://save_data.json` via `SaveManager`), sem transmissão.
- **Achado real durante a auditoria**: o autoload `_mcp_game_helper`
  (`addons/godot_ai/runtime/game_helper.gd`, do plugin que uso pra desenvolver) está
  registrado no `project.godot` incondicionalmente — ou seja, ele entra em **qualquer**
  build, inclusive um APK final. Li o código-fonte: ele só reage ao canal de debug remoto
  nativo do Godot e fica inerte sem ele (não abre um socket próprio, não funciona num APK
  de release rodando fora do editor) — não é uma falha de RNF07/RNF09 em si, mas deixar
  uma ferramenta de desenvolvimento embutida num build de produção não é boa prática.
  **Ação obrigatória antes do export final de release**: remover o autoload
  `_mcp_game_helper` de `project.godot` (`autoload_manage(op="remove")`) e desabilitar o
  plugin Godot AI — só depois disso gerar o APK que vai pra loja/usuário final. Isso deve
  ser feito por último, depois que não precisar mais de mim conectado ao editor.
- RNF10 (min SDK 26) e o export do `.apk` em si **não puderam ser feitos nesta sessão**:
  não existe uma ferramenta MCP para criar/validar `export_presets.cfg` ou rodar o export,
  e isso exige Android SDK, JDK, keystore e os export templates do Godot 4.7 instalados
  localmente — só a UI do editor consegue configurar isso com segurança (o arquivo de
  preset carrega checksums/UIDs de template que a UI valida). Perguntei ao usuário se
  deveria tentar escrever esse arquivo à mão mesmo assim; a resposta foi não arriscar —
  documentar os passos manuais em vez disso.

### Passos manuais para o usuário (fazer na UI do Godot, fora desta sessão)
1. **Editor → Manage Export Templates...** → baixar/instalar os templates da versão 4.7
   (precisa bater com a versão do editor, `4.7.2-stable` neste projeto).
2. **Editor → Editor Settings → Export → Android**: apontar `Android SDK Path` (precisa do
   Android SDK + `cmdline-tools`/`platform-tools` instalados), e configurar o debug
   keystore (o Godot gera um automaticamente se não houver um customizado).
3. **Project → Export... → Add... → Android**: criar o preset.
   - **Min SDK**: `26` (Android 8.0 Oreo) — atende RNF10 diretamente.
   - **Target SDK**: deixar o padrão sugerido pelo editor (geralmente a versão mais
     recente suportada pelos templates instalados).
   - **Package → Unique Name**: um nome de pacote reverso-DNS único, ex.
     `com.<seuNome>.cucaativa` (obrigatório, não pode ser o padrão de exemplo do Godot).
   - **Permissions**: não marcar nenhuma permissão de rede/localização/armazenamento
     externo — o jogo não precisa de nenhuma (RNF07 offline + RNF09 LGPD reforçados pela
     ausência de permissões, não só pela ausência de código).
4. **Antes de gerar o `.apk` final**: remover `_mcp_game_helper` dos autoloads e
   desabilitar o plugin Godot AI (ver "Achado real" acima).
5. **Export Project...** → gerar o `.apk` (debug primeiro, pra testar num aparelho/emulador
   real; release só depois de validar).
- Agente: `godot-gameplay-engineer` (configuração de projeto) — mas a etapa final de
  clicar em "Export" é do usuário, não automatizável por aqui.

## Fase 8 — QA contínua — primeira passada completa feita nesta sessão
- `test_run`: 51/51 passando.
- Auditoria de acessibilidade (RNF01-04, RN aplicáveis) em todas as 6 telas, seguindo o
  procedimento de `accessibility-audit`:
  - **RNF01 (contraste ≥4.5:1)**: recalculei WCAG para toda combinação fill/texto do
    tema. **Achado real, corrigido**: o checkmark verde do protótipo (`#4ABA34`) sobre o
    fundo amarelo dos badges de Configurações (`#FECE33`) dava só **~1,7:1** — bem abaixo
    do mínimo, um problema de verdade pra quem tem baixa visão (o público-alvo do app).
    Troquei para `#185702` (verde escuro já usado como borda do botão Jogar) — mesma
    família de cor, mas ~5,9:1 de contraste contra o amarelo, dentro do exigido. Todo o
    resto (botões coloridos com texto preto, texto navy sobre fundo creme/branco) já
    passava com folga (6,0:1 a 14,1:1, ver Fase 2).
  - **RNF02 (tipografia ≥18sp, sem serifa)**: base 28px/32px (35px/40px em "Grande"),
    todos bem acima de 18sp; fonte padrão do Godot (sans-serif) em todo o app.
  - **RNF03 (toque ≥48x48dp)**: reauditei todos os botões do projeto por grep depois do
    achado da Fase 6 (`HistoricoButton`/`ConfiguracoesButton` sem `custom_minimum_size`) —
    hoje todos os botões de todas as 6 cenas têm tamanho mínimo explícito ≥48x48.
  - **RNF04 (nada punitivo)**: sem cronômetro regressivo, sem alarme, sem flash de cor;
    feedback de erro é um leve balanço + tom suave (Fase 2); dica é sempre opcional, nunca
    forçada.
  - **RN05/RN06**: confirmados via testes automatizados + smoke test de vitória real
    (Fase 6) e de reinício via pausa (Fase 4).
- Playtest manual final com o jogo rodando (não só leitura de código): percorri
  Configurações (conferindo o novo checkmark), Dificuldade → Médio (30 cartas, grade
  6x5 renderiza sem estourar a tela nem sobrepor o cabeçalho Pontuação/Dica/Pausa) — sem
  nenhum erro no log em nenhuma tela.
- Pendências que ficam registradas para o futuro (não bloqueiam o estado atual, mas não
  foram pedidas explicitamente nesta sessão): passada de fidelidade visual completa
  (formas/ícones do protótipo — ver Fase 2), ícones de carta para Médio/Difícil (só 9 de
  até 20 existem — ver Fase 1/2), UI de "continuar partida salva" no menu (API pronta
  desde a Fase 3), e validação em dispositivo Android real antes do lançamento (Fase 7).
- Agente: `godot-qa-tester` + `accessibility-qa`.

## Bloqueio conhecido (contornado)
Sincronização automática com o Figma (`figma-design-sync`, skill `new-screen-from-figma`)
continua bloqueada por falta de acesso de edição ao arquivo (conta conectada tem assento
"View" num plano Starter). Isso deixou de ser um bloqueio prático: o usuário exportou
manualmente os SVGs das 16 telas/variantes do protótipo (`assets/icons/raw/telas/`), o que
deu hex exatos de toda a paleta e permitiu extrair 9 ícones reais de animais das cartas
(`assets/icons/cards/`) embutidos nas variantes "com Dica". Ver
[design-notes.md](design-notes.md) para a paleta completa e a lista de ícones. Only
pendência: completar os ícones que faltam para os 15/20 pares dos níveis Médio/Difícil.

## Fase de fidelidade visual (pós Fase 8) — feita nesta sessão

Trabalho pedido depois do usuário observar que Volume/Tamanho da letra (e o app em geral)
estavam visualmente diferentes do protótipo. Escopo final acabou bem maior que "só cores"
por causa de dois bugs sérios encontrados no meio do caminho — ver abaixo.

### Achado crítico 1 — cores de botão nunca renderizaram de verdade
`theme_manage(op="set_stylebox_flat"/"set_color")` grava os dados de estilo sob um nome de
tipo customizado (`YellowButton`, `GreenButton`, etc.), mas **nunca chama
`Theme.set_type_variation(tipo, "Button")`** — uma metadado separada que o Godot exige para
reconhecer esse nome como uma variação válida quando um Control tem
`theme_type_variation = "YellowButton"`. Sem isso, o motor cai silenciosamente no tema
escuro padrão do Godot para QUALQUER botão customizado — sem erro, sem aviso. Isso estava
acontecendo desde a Fase 2 e nunca foi percebido porque toda verificação anterior usava
`get_ui_elements` (só texto/posição/tipo) ou raciocínio sobre o arquivo de tema, nunca um
`editor_screenshot` de verdade. A primeira captura real de tela (pedida nesta fase) revelou
tudo cinza-escuro. Corrigido registrando `set_type_variation` para todos os 10 tipos de
botão via `game_eval` + `ResourceSaver.save()`. **Detalhe importante**: qualquer chamada
futura a `theme_manage` para criar/editar um estilo **apaga esse registro de novo** (mesmo
para tipos não relacionados) — é preciso re-registrar todos os tipos como último passo
sempre que `theme_manage` for usado depois disso. Documentado em memória para não esquecer
em sessões futuras.

### Achado crítico 2 — fundo creme nunca existia nas telas de jogo
Toda tela exceto o menu principal usa `Control` puro como raiz (não `Panel`), então o
`Panel/styles/panel` do tema (a cor creme `#FCE8B1`) nunca tinha nó nenhum pra aplicar —
essas telas mostravam o cinza padrão de limpeza de tela do Godot por trás do conteúdo,
invisível até o mesmo `editor_screenshot` real. Corrigido adicionando um `ColorRect`
`Background` (full-rect, `#FCE8B1`, `mouse_filter` ignorado) como primeiro filho de
`difficulty_select`, `board`, `settings`, `history` e `tutorial`.

### Ícones reais aplicados
O usuário exportou do Figma (isolados, não a tela inteira) os ícones: Jogar, Histórico,
Configurações (engrenagem), Pausa, Dica (estrela), Checkmark, Som, Texto — salvos em
`assets/icons/raw/ui/`. Processei cada um (corrigi cores fora do padrão: 2 traços pretos
perdidos no ícone de Histórico viraram branco; Som/Texto vieram em preto puro, recoloridos
para navy `#0B2973`; o Checkmark repetia o verde `#4ABA34` que já tinha falhado no teste de
contraste da Fase 8, recolorido para `#185702`) e organizei em `assets/icons/ui/`.
Aplicados via a propriedade nativa `icon` do `Button` (`expand_icon=true`, `text=" "` —
ícone puro, sem rótulo de texto, fiel ao protótipo):
- Menu principal: Jogar virou um círculo de verdade (`GreenCircleButton`, tema novo,
  corner_radius=metade do tamanho); Histórico/Configurações viraram uma linha horizontal
  lado a lado (`ShortcutsRow`), como no protótipo, em vez de empilhados.
- Tabuleiro: Pausa virou círculo (`YellowCircleButton`); Dica virou a estrela de verdade
  (`TransparentButton`, ícone ocupando o botão inteiro) com um Label `Count` sobreposto
  mostrando as dicas restantes (o número não cabe dentro da forma de estrela como texto de
  botão comum).
- Configurações: o "✓" de texto virou o ícone real (`TextureRect` no lugar do `Label`,
  mesma lógica de visibilidade já existente); ícones de Som/Texto adicionados ao lado dos
  títulos "Volume do jogo"/"Tamanho da letra" (só existe 1 ícone de cada no protótipo, não
  um por opção — confirmado pelo usuário na hora do export).
- Achado bônus: 10 arquivos de ícone de animal não processados apareceram em
  `assets/icons/raw/` (fora de `telas/`) — 9 eram duplicatas exatas (por hash MD5) dos já
  extraídos, 1 era uma arara vermelha genuinamente nova. Total de ícones de carta agora:
  **10 de até 20** (facilita Médio, ainda falta pra Difícil).

### Verificação
Toda alteração desta fase foi confirmada com `editor_screenshot(source="game")` real — não
só `get_ui_elements` — em todas as 6 telas mais o overlay de pausa, incluindo depois de um
restart completo do jogo (pra garantir que a correção do tema persiste, não é só um patch
em memória). 51/51 testes automatizados continuam passando. Smoke test final: partida
completa até a vitória usando uma dica no meio do caminho, tudo funcionando (pontuação,
histórico, estado desabilitado dos botões ao final).

### Ajuste pós-comparação visual direta (usuário mandou print lado a lado)
O usuário comparou um print real do app com o protótipo e apontou 3 diferenças no menu
principal, todas corrigidas:
- **Título**: virou duas linhas de verdade ("Jogo da Memória" navy + "Cuca Ativa" verde
  `#2A9E00`), fonte bem maior (44px/48px) e com contorno branco (`font_outline_color` +
  `outline_size=8`) pra imitar o efeito "cartoon" do protótipo — sem um asset de fonte
  customizada exportado, contorno + tamanho é a aproximação possível com a fonte padrão do
  Godot.
- **Legendas**: "Histórico"/"Configurações" agora aparecem como texto abaixo dos ícones
  (o protótipo mantém isso, mesmo os botões sendo icon-only) — cada atalho virou um
  `VBoxContainer` [ícone, legenda].
- **Halo branco**: os 3 botões (Jogar, Histórico, Configurações) ganharam um anel/fundo
  branco atrás da cor (replicando a estrutura real do SVG do protótipo, descoberta ainda
  na Fase 2: um retângulo/elipse branco ligeiramente maior por trás do preenchimento
  colorido) — implementado como um `Panel` (`HaloCirclePanel`/`HaloRectPanel`, variações
  novas de tema) atrás do `Button`, dentro de um `Control` wrapper que centraliza os dois.
  **Mesmo cuidado do achado crítico 1** foi necessário aqui: registrar `HaloCirclePanel`/
  `HaloRectPanel` como type variation de `Panel` (não `Button`) e re-registrar TODOS os
  tipos (botões + painéis) juntos, já que criar esses 2 novos tipos via `theme_manage`
  apagou de novo o registro dos 10 tipos de botão já corrigidos (`CardButton` voltou a
  renderizar cinza até a re-registragem em conjunto).
- Confirmado com `editor_screenshot` real, restart completo, clique real (Jogar →
  Dificuldade) e 51/51 testes passando.

### Correção: ícone do botão Play (e demais botões só-ícone) descentralizado
Usuário mandou print recortado mostrando o triângulo do Play visivelmente deslocado pra
esquerda dentro do círculo verde, com verde liso sobrando à direita. Diagnóstico:

- Primeira hipótese (errada): sobrava `text = " "` (placeholder de acessibilidade) no botão
  empurrando o ícone. Removido via edição direta do `.tscn` (`Read`+`Edit`, já que
  `node_set_property` com valor string vazio quebra com erro de JSON malformado nesse
  ambiente) — não resolveu, o ícone continuou deslocado.
- Causa real: `Button.icon` + `expand_icon=true` do Godot não centraliza corretamente um
  ícone não-quadrado (o `jogar.svg` é 95x104) dentro de um botão quadrado (168x168),
  independente de `icon_alignment`/`vertical_icon_alignment` estarem em CENTER. É uma
  limitação do sistema nativo de ícone de `Button`, não um problema do asset.
- Correção: trocado `Button.icon` nativo por um `TextureRect` filho (`stretch_mode=5`
  KEEP_ASPECT_CENTERED, ancorado full-rect com margens internas, `mouse_filter=2` IGNORE
  pra clique atravessar até o Button). Aplicado nos 5 botões só-ícone do projeto: Jogar,
  Histórico, Configurações (menu principal) e Pausa, Dica (tabuleiro).
- **Bug adicional pego no processo**: o `TextureRect` recém-criado usa por padrão
  `expand_mode = EXPAND_KEEP_SIZE` (0), que faz o nó herdar o tamanho *nativo* do SVG como
  tamanho mínimo — ignorando os offsets/âncoras sempre que a textura for maior que a caixa
  do botão. Isso estourava visivelmente o ícone da Dica (`dica_estrela.svg`, 185x107 nativo)
  pra fora do botão (64x64), e afetava sutilmente Histórico/Configurações também (seus SVGs,
  89x87 e 103x87, passavam um pouco da caixa disponível de 112x82). Corrigido setando
  `expand_mode = EXPAND_IGNORE_SIZE` (1) em todos os 5 `TextureRect` de ícone.
- **Bug relacionado, mesmo lugar**: com o ícone estourando, ficou visível que o
  `TransparentButton` (usado só no botão Dica) só tinha stylebox `normal` definida — ao
  ficar `disabled` (sem dicas disponíveis / pontuação insuficiente), caía no estilo padrão
  cinza/bege do `Button` base em vez de continuar transparente. Corrigido adicionando
  styleboxes `disabled`/`hover`/`pressed`/`focus` transparentes (`bg_color` alpha 0) ao
  `TransparentButton`.
- Confirmado com `editor_screenshot` real em ambas as telas (menu e tabuleiro, incluindo
  navegação por clique real Jogar → Fácil), e 51/51 testes automatizados passando depois.

## Pivô: prioridade mobile (celular) antes de continuar fidelidade visual
Usuário pediu para pausar mais ajustes visuais e focar em fazer o jogo funcionar bem em
celular, que é a plataforma-alvo real (RNF10: exclusivo Android, mín. SDK 26).

- **Achado crítico**: os 16 frames exportados do Figma (`assets/icons/raw/telas/*.svg`) são
  todos 412x917 (retrato, proporção típica de celular Android — 412dp é literalmente a
  largura de referência "medium phone" do Android). O projeto, porém, estava configurado e
  sendo testado inteiro em **1152x648 (paisagem)**, o padrão de novo projeto do Godot — ou
  seja, todo o trabalho de fidelidade visual das fases anteriores foi verificado na
  orientação errada.
- **Correção**: `project.godot` atualizado via `project_manage(settings_set)`:
  `display/window/size/viewport_width=412`, `viewport_height=917`,
  `display/window/handheld/orientation="portrait"`. Mantido `stretch/mode="canvas_items"` +
  `aspect="expand"` (já configurado, escala bem pra qualquer tela real).
- Verificado com `editor_screenshot` + cliques reais em todas as 6 telas + overlay de pausa
  na nova resolução: menu principal, seleção de dificuldade e tela de pausa se adaptaram
  bem sem nenhuma mudança de código (graças a `VBoxContainer`/âncoras já usados em vez de
  posicionamento absoluto).
- **Bug real encontrado e corrigido**: o tabuleiro usava `CARD_SIZE` fixo (64x64px) em
  `scripts/ui/board.gd`. Na dificuldade Difícil (20 pares = 40 cartas, grid 8 colunas), isso
  exigia 512px+ de largura — **estourava a tela de 412px**, cortando 2+ colunas de cartas
  fora da área visível (bug bloqueante em qualquer celular real, não só um detalhe visual).
  Corrigido: `_card_size_for(columns)` agora calcula o tamanho da carta dinamicamente a
  partir da largura real do viewport (`get_viewport_rect().size.x`), respeitando um mínimo
  de 48px (RNF03 — touch target 48x48dp) e máximo de 96px. Separação do `GridContainer`
  reduzida de 4px (padrão) para 2px via `add_theme_constant_override`, só o suficiente pra
  sobrar uma margem lateral mínima quando o cálculo bate no piso de 48px (caso do Difícil:
  8×48px + 7×2px = 398px, com ~7px de margem de cada lado, em vez de 0).
  Confirmado: Fácil (4 col), Médio (6 col) e Difícil (8 col) cabem sem cortar, cartas ≥48px
  em todos os casos, jogo real testado (flip, match, mismatch) na nova resolução, 51/51
  testes automatizados continuam passando.
- **Bloqueio confirmado (não contornável por aqui)**: não há Android SDK/`adb`/JDK
  instalados nesta máquina (`ANDROID_HOME`/`ANDROID_SDK_ROOT` vazios, `where adb` não
  encontra nada) — bate com o que já estava documentado na Fase 7: o export real do `.apk`
  (presets, keystore, templates) só pode ser feito pela UI do editor, manualmente, pelo
  usuário. Ver checklist já existente na seção da Fase 7 acima.
- **Pendências mobile que ficam**: testar em mais proporções de tela reais (celulares mais
  altos/estreitos que 412x917, ex. 20:9 ou com notch) quando houver um dispositivo/emulador
  disponível; a tela de pausa (`Card` 400px de largura fixa) fica com margem lateral bem
  apertada (~6px) em telas de 412px — funciona mas está no limite, vale revisar se aparecer
  um device mais estreito; instalar Android SDK/templates localmente pra finalmente gerar e
  testar um `.apk` de verdade (ver Fase 7).

### Bug adicional de mobile: tela de Histórico estourava a largura
Ao revisar as telas restantes em retrato, a tela de Histórico mostrou texto cortado à
direita e o botão Voltar parcialmente fora da tela. Causa: os `Label` de cada linha do
histórico (`scripts/ui/history.gd`) não tinham `autowrap` nem largura definida — o texto
"Difícil — Pontos: 999 — Tempo: 59:59" sem quebra tem ~550px de largura natural, forçando o
`VBoxContainer` pai a ficar mais largo que os 412px da tela (o mesmo mecanismo do bug do
Card Grid: minimum_size vence sobre âncoras). Corrigido: cada linha agora recebe
`autowrap_mode = AUTOWRAP_WORD_SMART` e `custom_minimum_size.x` calculado a partir da
largura real do viewport (`get_viewport_rect().size.x - 40`), quebrando em 2 linhas quando
necessário em vez de estourar. `EmptyLabel`/`ScrollContainer` também tinham
`custom_minimum_size` fixo em 600px, corrigido pra 0 + `size_flags_horizontal = 3` (fill) +
`horizontal_scroll_mode = 0` (nunca scroll horizontal, só vertical). Confirmado com
`editor_screenshot` real: histórico cabe, com scroll vertical funcionando quando há mais
entradas do que a altura da lista.

### Troca de ícone-só-o-ícone para botão completo exportado do Figma
Usuário perguntou se não seria mais simples exportar o botão inteiro (fundo + sombra/halo +
ícone) do Figma em vez de reconstruir o fundo/sombra manualmente no tema do Godot — e sim,
era. Processo:
- Primeira tentativa em SVG falhou: o Godot **ignora inteiramente** qualquer grupo SVG
  envolto em `<g filter="url(#...)">` (o filtro de drop-shadow blur do Figma) — não é só o
  blur que some, o grupo inteiro (incluindo o fundo branco/colorido sólido) desaparece na
  importação. Confirmado visualmente: um `TextureRect` de teste isolado mostrou só o
  triângulo do ícone, sem nenhum fundo. Sem solução viável em SVG sem editar o arquivo à
  mão removendo os filtros (perderia a sombra suave).
- Segunda tentativa em PNG (rasterizado, mesma resolução 1x do frame Figma) funcionou
  perfeitamente — PNG não depende de filtros SVG, a sombra já vem "cozida" nos pixels.
  5 botões trocados: `assets/icons/ui/buttons/{jogar,historico,configuracoes,pausa,
  dica}_button.png`. Os ícones antigos (`jogar.svg`, `historico.svg`, `configuracoes.svg`,
  `pausa.svg`, `dica_estrela.svg`) foram removidos por não terem mais nenhuma referência.
- Estrutura simplificada: os nós `Halo` (Panel com sombra via tema) viraram desnecessários e
  foram deletados — a sombra já está na imagem. Cada `Button` agora ocupa 100% do wrapper
  (antes era menor, centralizado, com o Halo maior atrás) e o `TextureRect` filho cobre o
  botão inteiro sem inset, com `expand_mode = EXPAND_IGNORE_SIZE` (mesma lição do bug do
  ícone do Dica na Fase mobile — sem isso o `TextureRect` tentaria usar o tamanho nativo do
  PNG como mínimo).
- Novo tipo de tema `ImageButton` (stylebox transparente em todos os estados:
  normal/hover/pressed/disabled/focus) substitui os antigos `GreenCircleButton`/
  `BlueButton`/`YellowButton`/`YellowCircleButton`/`TransparentButton` nesses 5 botões — a
  cor/forma agora vem inteiramente da imagem, o Button por trás só cuida de clique/foco.
  **Gotcha do `theme_manage` de novo**: dessa vez especificamente o tipo `ImageButton` NÃO
  teve o `base_type` registrado automaticamente (diferente das sessões anteriores, onde o
  plugin já cobria isso sozinho) — sintoma idêntico ao bug antigo (botão caía no estilo
  cinza padrão do Godot). Corrigido adicionando a linha `ImageButton/base_type = &"Button"`
  direto no `.tres` (mesmo formato que as outras 12 entradas já tinham, então seguro copiar
  o padrão à mão neste caso specific).
- **Acessibilidade**: como o stylebox do `ImageButton` é transparente em todo estado, o
  feedback visual nativo do Godot (mudar de cor ao pressionar, escurecer ao desabilitar)
  deixou de existir. Compensado em código (`main_menu.gd` e `board.gd`): uma leve animação
  de escala (0.92x, 0.08s) em `button_down`/`button_up` confirma visualmente que o toque
  registrou, e um helper `_set_image_button_enabled()` aplica `modulate` a 50% de opacidade
  quando o botão fica desabilitado (usado no botão de Dica sem saldo/hints e no botão de
  Pausa após vencer a partida) — sem isso os botões pareceriam sempre clicáveis mesmo
  quando não estão, o que seria uma regressão de acessibilidade real, não só estética.
  Textos de botão (Fácil/Médio/Difícil, Continuar/Reiniciar/Sair, Voltar, Entendi!)
  continuam de fora dessa troca — teto de imagem não escala com a opção "Tamanho da letra",
  então só os 5 botões 100% ícone (sem texto embutido no gráfico) foram convertidos.
- Confirmado com `editor_screenshot` real (menu e tabuleiro), captura do estado pressionado
  em pleno toque (botão visivelmente menor), captura do estado desabilitado (dica esmaecida
  com pontuação 0, corretamente abaixo do custo de 15), overlay de pausa abrindo normal, e
  51/51 testes automatizados passando.

### Pendências que ficam
- Painel de lista do Histórico (protótipo pede fundo `#FECE33`/borda `#DFB838`; hoje é só
  texto no fundo creme).
- Ícones de carta: faltam 5 para completar Médio (15) e 10 para completar Difícil (20).
- Botões de dificuldade/pausa/parabéns/voltar continuam com texto, não ícone — não fazem
  parte do pedido original de ícones desta fase.
- ~~Fonte "cartoon" com contorno grosso do protótipo~~ — resolvido: usuário identificou as
  fontes exatas (Fredoka One Regular pro título, Gabarito Black pras legendas dos atalhos),
  baixei do Google Fonts (`assets/fonts/FredokaOne-Regular.ttf`,
  `assets/fonts/Gabarito-Black.ttf`, licença SIL Open Font — uso livre) e apliquei via
  `theme_override_fonts/font` em `TitleLabel`/`SubtitleLabel` (Fredoka) e nas legendas
  `HISTÓRICO`/`CONFIGURAÇÕES`, agora em caixa alta (Gabarito Black). Confirmado com
  `editor_screenshot` real; 51/51 testes continuam passando.
- ~~Bloco do título sem o "card" branco de fundo~~ — resolvido (ver seção abaixo).

### Título do menu e tela de Dificuldade redesenhados (fiéis ao protótipo)
Usuário apontou que o "fundo branco" do título não era um cartão retangular atrás do texto,
e sim um contorno (`outline`) de fonte muito mais grosso — grosso o bastante pra que o
contorno de letras vizinhas se funda visualmente num blob só, dando a aparência de
"adesivo". Confirmado analisando o SVG do protótipo (`Tela Inicial.svg`): o texto foi
exportado como path (sem `<text>`), usando a técnica de máscara "outside stroke" do Figma —
tecnicamente um contorno de fonte espesso, não uma forma separada atrás do texto.

- `TitleLabel`/`SubtitleLabel` movidos pra um `TitleGroup` (`VBoxContainer` com
  `separation` negativo, -16) só pra eles, separado do espaçamento do `Layout` principal
  (que continua controlando o espaço até o botão Jogar). Fonte subiu de 44/48px pra 68/64px,
  `autowrap_mode` ligado no título (agora quebra "Jogo da" / "Memória" em duas linhas, como
  no protótipo), `line_spacing` negativo (-10) pra aproximar as linhas, e `outline_size`
  subiu de 8px pra **68px** (dobrado 2x a pedido do usuário: 8→20→34→68) — só nesse ponto o
  contorno das 3 linhas ("Jogo da" / "Memória" / "Cuca Ativa") se funde num bloco branco
  único e orgânico igual ao protótipo. Legendas `HISTÓRICO`/`CONFIGURAÇÕES` ganharam o mesmo
  tratamento (outline branco 16px, texto preto — antes eram navy sem contorno).
- **Bug de UX encontrado e corrigido**: o feedback de toque (animação de escala 0.92x) dos
  botões-imagem (Jogar, Histórico, Pausa, Dica) encolhia na diagonal superior-esquerda em
  vez de encolher pro centro. Causa: `pivot_offset` só era recalculado dentro do callback do
  sinal `resized` — mas esse sinal não dispara de novo depois que o layout inicial do
  Control já resolveu o tamanho final (que acontece antes do `_ready()` do script rodar),
  então o callback nunca executava e `pivot_offset` ficava no padrão `(0,0)` (canto
  superior-esquerdo). Corrigido chamando `_update_pivot(btn)` diretamente dentro do
  `_ready()` de `main_menu.gd`/`board.gd`, além de manter a conexão ao sinal `resized` como
  proteção extra pra mudanças futuras de tamanho.
- **Tela de Dificuldade** reconstruída pra bater com `Tela Dificuldade.svg`: título trocado
  de "Escolha a dificuldade" pra "Dificuldade" (Fredoka One 52px, mesmo tratamento de
  contorno branco do menu principal). Os 3 botões (Fácil/Médio/Difícil) e o Voltar ganharam
  wrapper + `Halo` (`HaloRectPanel`, mesmo componente já usado no menu principal) atrás,
  dobrando de tamanho (240x60 → 290x110 pros 3 de dificuldade, 204x80 pro Voltar) com fonte
  bem maior (36px/28px) e cantos mais arredondados. Cores extraídas com precisão de pixel
  do SVG do protótipo — na prática já batiam quase exatamente com o tema existente
  (`YellowButton`/`LimeButton`/`BlueButton`/`RedButton`), só precisou: corner_radius 12→20
  em todos os 4, e a cor da borda do `YellowButton` corrigida de `#DFB838` pra `#AD8E2A`
  (a borda daquele tom mais escuro é a que o Fácil realmente usa no protótipo; `#DFB838` era
  usado em outro contexto, o botão circular de Configurações). `VoltarButton` ganhou uma
  seta "←" antes do texto (`"← VOLTAR"`, caixa alta), igual ao protótipo.
- **Gotcha do `theme_manage` de novo**: ao editar `YellowButton`/`LimeButton`/`BlueButton`/
  `RedButton` nesta sessão, o `base_type` do `ImageButton` (não relacionado, criado numa
  sessão anterior) sumiu de novo — mesmo padrão já registrado em
  [[theme-type-variation-gotcha]]. Confirmado que os outros 12 tipos mantiveram o registro
  intacto dessa vez; só o `ImageButton` foi afetado. Corrigido de novo hand-editando a linha
  no `.tres`. Reforça a recomendação de sempre conferir `base_type` de TODOS os tipos depois
  de qualquer sessão de `theme_manage`, não só do tipo que acabou de ser criado/editado.
- Nota: `LimeButton`/`YellowButton`/`RedButton` também são usados no menu de pausa
  (Continuar/Reiniciar/Sair) — o corner_radius maior (20) se propaga pra lá também. Ainda
  não comparado contra `Tela Pausa.svg` especificamente; deve ficar consistente, mas vale
  conferir quando essa tela receber sua própria passada de fidelidade visual.
- Confirmado com `editor_screenshot` real, clique real em Fácil navegando pro tabuleiro, e
  51/51 testes automatizados passando.
- Ajustes finos pedidos em seguida, ambos aplicados a "Jogo da Memória"/"Cuca Ativa" e
  "Dificuldade": tamanho do texto dos 3 botões de dificuldade aumentado 1.5x (40→60px) e
  contorno branco do título dobrado (24→48px).
- Botão Voltar recebeu ícone de seta de verdade (`assets/icons/ui/seta_voltar.svg`, exportado
  pelo usuário e movido da raiz do projeto) no lugar do caractere Unicode "←" usado antes —
  mais nítido e sem depender da fonte ter esse glifo. Alinhamento também corrigido: Voltar
  estava centralizado (`size_flags_horizontal=4`) mas o protótipo alinha à esquerda, na mesma
  margem dos botões de dificuldade acima — resolvido envolvendo `VoltarWrapper` num
  `HBoxContainer` com um `Control` espaçador fixo (46px, igual à margem lateral dos outros
  wrappers) antes dele, em vez de tentar usar apenas size_flags (que não davam controle fino
  sobre uma margem específica, só "centro" ou "início").
- **Sombra do título não aparecia**: a propriedade `font_shadow_color`/`shadow_offset_x/y`
  do `Label` sombreia só o preenchimento colorido da letra, não o contorno grosso — como o
  contorno (48-68px) é muito maior que a letra em si, a sombra da letra ficava inteiramente
  escondida atrás do próprio contorno, invisível. A propriedade que faltava:
  `theme_override_constants/shadow_outline_size`, que faz a sombra copiar o contorno inteiro
  (não só o preenchimento) — só com ela a sombra do "blob" branco inteiro apareceu. Ajustado
  em 2 rodadas: primeiro com cor muito escura/offset grande (opacidade 80%, offset 8/10) a
  pedido do usuário — ficou forte demais — depois suavizado pra opacidade 30% e offset 4/5
  (igual ao valor original usado nos halos dos botões), que bateu com o protótipo. Aplicado
  em `TitleLabel`/`SubtitleLabel` (menu) e `Title` (Dificuldade).

### Tela do Tabuleiro: pontuação restilizada e rodapé de ações reposicionado
- `ScoreLabel` (`"Pontuação: %d"` numa linha só, fonte padrão) substituído por duas labels
  empilhadas (`ScoreGroup` — mesmo padrão `TitleGroup` do menu/Dificuldade): "Pontuação"
  (sem dois-pontos) e o número embaixo, ambos Fredoka One 52px com o mesmo contorno/sombra
  branco grosso dos outros títulos. `board.gd` atualizado: `score_label` virou
  `score_title_label` + `score_value_label`; `_on_game_won` agora troca o título pra
  "Parabéns!" e mantém o número (antes era uma frase única "Parabéns! Pontuação final: X"
  que não cabia mais nesse formato de 2 linhas); `_on_reiniciar_pressed` restaura o título
  "Pontuação" caso o reinício aconteça depois de vencer.
- `Header` (HBoxContainer com Score+Dica+Pausa lado a lado no topo) removido. Dica e Pausa
  agora moram num novo `Footer` (`Control`, altura 90px) logo depois do `CardGrid`: Dica
  ancorada ao centro horizontal, Pausa ancorada ao canto inferior direito (20px de margem),
  ambos na mesma altura — batendo com o protótipo (`Tela Tabuleiro Fácil.svg` etc.), que
  também não coloca esses botões ao lado da pontuação, e sim abaixo do tabuleiro.
- Confirmado com `editor_screenshot` real jogando através do fluxo normal (menu → Fácil →
  tabuleiro), clique real no Pausa abrindo o overlay corretamente, e 51/51 testes
  automatizados passando.
- Ajustes finos pedidos em seguida: separação do `ScoreGroup` (-4→+6) pra desgrudar
  "Pontuação" do número, espaçador de 24px antes do `CardGrid` (título estava colado no
  tabuleiro), estrela da Dica ampliada em 2 rodadas (100→140→180→270px de largura, mantendo
  a proporção real do asset 224:131 desde a 2ª rodada) e Pausa reposicionado pro canto
  inferior direito de fato (ancorado no rodapé do `Footer`, não mais alinhado à mesma altura
  da Dica). Texto "DICA" adicionado dentro da estrela: Fredoka One 29px (55% do tamanho da
  "Pontuação", 52px), branco com contorno preto fino (não o contorno branco grosso dos
  títulos) e sombra sutil — só `outline_size`/`font_shadow_color`, sem
  `shadow_outline_size`, pra não criar o efeito "adesivo" nesse texto menor.

### Tela de Configurações: mesmo padrão de título/texto e botão Voltar
Usuário apontou que a tela de Configurações ficou bem diferente do protótipo e pediu pra
aplicar "o mesmo padrão anterior" — mesmo tratamento de texto e mesmo componente de Voltar
já usados nas outras telas, sem redesenhar a mecânica de seleção (manteve os botões
Mudo/Baixo/Alto/Normal/Grande como estão, não a lista com checkmark do protótipo, que exigiria
mudança funcional maior — só a parte visualmente descrita foi pedida).
- "Configurações" (título): Fredoka One 52px, contorno branco 48px + sombra + shadow_outline
  — idêntico ao "Dificuldade"/"Pontuação".
- "Volume do jogo" e "Tamanho da letra" (subtítulos de seção): mesmo tratamento, só menor
  (32px, contorno 24px) — mantém a hierarquia visual entre título da página e títulos de
  seção.
- Texto dos botões (Mudo/Baixo/Alto/Normal/Grande): trocado pra Fredoka One 26px, igual ao
  padrão já usado nos botões de dificuldade (preto, sem contorno — o contorno grosso é só
  para texto sobre o fundo creme, não para texto dentro de um botão colorido).
- `VoltarButton`: reconstruído com o mesmo componente usado no resto do jogo —
  `VoltarWrapper` (halo `HaloRectPanel` atrás) + ícone de seta
  (`assets/icons/ui/seta_voltar.svg`) + texto "VOLTAR" em caixa alta, RedButton.
- **Falso alarme**: primeira captura mostrou o Voltar cinza em vez de vermelho — não é bug,
  é o estado de :hover (o cursor simulado ainda estava sobre o botão no momento do
  `editor_screenshot`, já que `RedButton` só define stylebox `normal`, então hover/pressed
  caem no cinza padrão do Godot — mesma causa-raiz do gotcha já documentado do
  `TransparentButton`, mas aqui é comportamento aceitável, não pedido para corrigir). Segunda
  captura movendo o mouse pra longe antes do screenshot confirmou vermelho normal.
- Confirmado com `editor_screenshot` real (cursor afastado do botão) e 51/51 testes
  automatizados passando.

### Configurações: mecânica de seleção trocada pra lista com checkmark (igual ao protótipo)
Depois da passada de estilo acima, usuário pediu pra ir além e trocar a MECÂNICA em si:
sair dos botões-caixa coloridos (Mudo/Baixo/Alto, Normal/Grande) e adotar o padrão real do
protótipo — uma caixa de ícone grande (com halo) à esquerda de cada seção, e a lista de
opções como texto simples (contorno branco fino + sombra, sem fundo colorido) à direita,
com um checkmark verde ao lado da opção selecionada.
- Extraído do SVG do protótipo (`Tela Configurações.svg`, via `filter`s + cores): caixa do
  ícone é branca com borda `#DFB838` 3px, corner radius ~20, com halo atrás (mesmo
  `HaloRectPanel` já usado em botões); texto das opções é navy `#0B2973` com contorno
  branco (bem mais fino que o dos títulos — 14px, não 24-48px) e sombra sutil; checkmark é
  verde `#4ABA34` (o `checkmark.svg` já existente já usa esse tom).
- **3ª opção nova**: o protótipo tem "Muito Grande" além de "Padrão"/"Grande" — não existia
  no código. Como `SettingsManager.set_font_scale()` já aceita qualquer float (não é
  hardcoded a 2 níveis), só precisou adicionar a chave nova no dicionário `FONT_SCALES` de
  `settings.gd` (`"muito_grande": 1.5`) e criar o botão correspondente — nenhuma mudança no
  autoload.
- Reestruturação por seção: `TitleRow` (ícone pequeno 36px inline + subtítulo) virou só o
  subtítulo sozinho; a antiga `VolumeButtons`/`FontSizeButtons` (`HBoxContainer` de botões
  coloridos) virou `OptionsRow` (`HBoxContainer`) contendo `IconWrapper` (halo + caixa do
  ícone, 110x122, ícone antigo de 36px reaproveitado dentro) e `OptionsList`
  (`VBoxContainer` com um botão por opção).
- Cada opção: `Button` com `theme_type_variation="ImageButton"` (mesmo tipo transparente já
  usado nos botões-imagem — aqui escolhido de propósito porque TODOS os estados
  (normal/hover/pressed/disabled) já são transparentes, evitando o "flash cinza" que
  `RedButton`/etc. têm ao passar o mouse) com `text=" "` (placeholder, meesmo workaround do
  espaço em branco já documentado pro bug de string vazia) e um `Row` (`HBoxContainer`,
  `mouse_filter=2` IGNORE) filho contendo o `OptionLabel` (texto de verdade, estilizado) e
  o `Check` (reaproveitado do botão antigo, só recolocado dentro do `Row` com tamanho fixo
  28x28 em vez de posicionamento absoluto por anchors).
- **Bug corrigido on-the-fly**: primeiro teste travou o jogo com "Node not found: Check" —
  o script (`settings.gd`) ainda buscava `get_node("Check")` direto no botão, mas o `Check`
  agora mora um nível mais fundo, em `Row/Check`. Um `replace_all` trocando pra
  `get_node("Row/Check")` resolveu.
- **Ajuste de layout pedido pelo usuário**: primeira versão deixava a caixa de ícone
  "flutuando" no meio da tela e cortava "Muito Grande" na borda direita. Causa: `OptionsRow`
  e `OptionsList` mantinham `size_flags_horizontal` padrão (não-fill) herdado dos nós
  antigos, então só ocupavam a largura mínima do conteúdo em vez de esticar até a borda —
  isso empurrava tudo (ícone incluso) pro centro da tela em vez de grudar na esquerda.
  Usuário pediu explicitamente pra NÃO reduzir a fonte da opção mais longa; a correção
  certa foi `size_flags_horizontal = 3` (fill) em `VolumeSection`/`FontSizeSection`/
  `OptionsRow`/`OptionsList`, deixando o ícone fixo grudado na esquerda (`custom_minimum_size`
  fixo, sem fill) e a lista esticando até a borda direita real da tela — "Muito Grande"
  passou a caber exatamente (rect termina em x=412, a largura exata da tela) sem tocar em
  nenhum tamanho de fonte.
- Confirmado com `editor_screenshot` real, clique real trocando Volume (Desligado) e Tamanho
  da Letra (Muito Grande — inclusive viu a UI inteira escalar em tempo real, confirmando
  RNF02 funcionando ponta a ponta com o nível novo), Voltar navegando de volta pro menu, e
  51/51 testes automatizados passando.

### Configurações: ajustes finos da caixa de ícone e margens laterais
Duas rodadas de ajuste pedidas depois da troca de mecânica acima, ambas nas caixas de ícone
(`IconWrapper` de Volume e Tamanho da letra):
- **1ª rodada**: usuário mandou 2 prints recortados do ícone de som mostrando que o ícone
  ocupava a caixa branca quase até a borda (pouco respiro) comparado ao protótipo, mais
  espaçoso. Corrigido aumentando o inset do `Icon` (`TextureRect`) dentro do `IconBox` de
  18px para 28px em cada lado, em ambas as seções.
- **2ª rodada**: usuário pediu 3 coisas juntas — dobrar o tamanho do ícone dentro da caixa,
  trocar a caixa "branca com borda amarela fina" por uma "borda amarela grossa com o branco
  só por dentro" (a caixa branca deve ficar visualmente dentro da amarela, não a amarela
  como um filete fino em volta do branco), e resolver o ícone/opções colados na lateral da
  tela. Todas resolvidas:
  - `IconBox` (`StyleBoxFlat` de cada seção): `border_width` aumentado de 3px para 10px —
    como o preenchimento (`bg_color`) continua branco e a borda é a cor dourada
    (`#DFB838`), uma borda desse porte já cria o efeito "moldura amarela grossa com miolo
    branco" pedido, sem precisar de uma 3ª camada de painel.
    Fica documentado que, embora a esteira mantida (`Halo` branco atrás, mesmo componente
    `HaloRectPanel` de sombra usado em todo o app) ainda deixa uma faixa branca fininha
    visível nos cantos do `IconWrapper` por trás da caixa — é a mesma sombra usada em todos
    os outros halos do jogo, não um problema novo.
  - Inset do `Icon` reduzido de 28px para 10px em cada lado (compensando o espaço que a
    borda mais grossa consumiu) — o ícone agora ocupa quase toda a área branca interna da
    caixa, visivelmente maior que antes.
  - Margem lateral: `Layout` (o `VBoxContainer` raiz da tela) não tinha nenhum respiro
    lateral (`offset_left`/`offset_right` em 0, esticado ponta a ponta), então tanto a
    caixa do ícone quanto a lista de opções ficavam colados nas bordas de 412px da tela.
    Corrigido com `offset_left=32`/`offset_right=-32` no próprio `Layout` — mais simples
    que adicionar um `MarginContainer` novo, já que todo o conteúdo já é filho direto dele.
- Confirmado com `editor_screenshot` real navegando Menu → Configurações via clique
  simulado real (não só leitura do `.tscn`), e 51/51 testes automatizados continuam
  passando.

- **3ª rodada**: usuário apontou 2 problemas remanescentes na mesma caixa de ícone,
  batendo exatamente com o que eu tinha documentado como "esperado" na rodada anterior —
  a sombra branca do `Halo` (mesmo componente de sombra usado no resto do jogo) vazando
  visivelmente para fora da borda amarela, e a borda encostando direto no ícone (sem
  respiro). Corrigido nas duas seções (Volume e Tamanho da letra), mantendo o centro/
  posição de tudo igual:
  - `IconBox` (a caixa branca com borda) aumentada de 94x106 para 106x118 — a margem entre
    ela e o `Halo` atrás caiu de 8px para 2px de cada lado, escondendo quase toda a sombra
    branca que antes vazava para fora da borda amarela.
  - `border_width` do `IconBox` subiu de 10px para 12px (amarelo ligeiramente mais grosso,
    como pedido).
  - Inset do `Icon` aumentado de 10px para 18px em cada lado — como isso é maior que os
    12px da borda, sobra ~6px de branco visível entre a borda e o ícone, resolvendo o
    "borda encostando no ícone".
- Confirmado com `editor_screenshot` real (Menu → Configurações via clique real) e 51/51
  testes automatizados passando.

- **Botão Voltar recentralizado → alinhado à esquerda**: mesmo bug/correção já aplicada na
  tela de Histórico — `VoltarWrapper` tinha `size_flags_horizontal = 4` (centralizado),
  diferente do padrão usado nas telas de Dificuldade/Histórico (alinhado à esquerda, rente
  à borda esquerda do conteúdo acima). Corrigido pra `size_flags_horizontal = 0`. Confirmado
  com `editor_screenshot` real e 51/51 testes automatizados passando.

- **4ª rodada**: usuário pediu pra mudar todos os textos (exceto o título) e os 2 ícones
  pra preto, além de aumentar o espaçamento entre as seções (Volume/Tamanho da letra
  ficavam muito espremidas no meio da tela). `VolumeLabel`/`FontSizeLabel` e as 6
  `OptionLabel` (Desligado/Médio/Alto/Padrão/Grande/Muito Grande) ganharam
  `font_color = preto` (título continua navy, de propósito). Os ícones (`som.svg`/
  `texto.svg`) são navy no arquivo — em vez de recriar os SVGs, apliquei
  `modulate = preto` nos 2 `TextureRect`: como modulate multiplica a cor da textura,
  qualquer cor não-transparente vira preto (RGB × 0 = 0), preservando o alfa/silhueta do
  ícone sem precisar editar o asset. `Layout` (o `VBoxContainer` raiz) ganhou
  `theme_override_constants/separation = 32` (não tinha valor customizado antes, caía no
  padrão baixo do tema, por isso "condensadas no meio da tela" com `alignment=1` CENTER).
- Confirmado com 51/51 testes automatizados passando (verificação visual desta rodada
  específica ficou pendente — a mensagem seguinte do usuário mudou de assunto pra tela de
  Histórico antes de eu capturar o `editor_screenshot`).

- **5ª rodada (última pedida)**: reduzir a espessura da borda amarela pela metade e garantir
  que o fundo branco fique inteiramente dentro do quadro amarelo. Duas mudanças nas 2
  seções (Volume e Tamanho da letra):
  - `border_width` do `IconBox` reduzido de 12px para 6px (metade, como pedido).
  - `Halo` (o painel branco de sombra atrás do `IconBox`, antes do tamanho do `IconWrapper`
    inteiro — só 2px maior que o `IconBox` de cada lado) redimensionado pra ocupar
    exatamente o mesmo retângulo do `IconBox` (mesmos offsets ±53/±59 a partir do centro,
    em vez de `anchor_right/bottom=1` preenchendo o wrapper inteiro) — eliminando de vez a
    faixa branca que ainda vazava um pouco por fora da borda amarela (bem mais perceptível
    agora que a borda ficou mais fina). A sombra do `HaloRectPanel` continua funcionando
    normalmente, já que `shadow_size` desenha para fora dos limites do painel independente
    do tamanho dele.
- Confirmado com `editor_screenshot` real (Menu → Configurações via clique real) e 51/51
  testes automatizados passando.

### Tela de Histórico: do zero, tabela de 2 colunas fiel ao protótipo
Tela estava sem nenhum trabalho de fidelidade visual desde a Fase 4 (texto solto "Difícil —
Pontos: 999 — Tempo: 59:59" em uma linha, fonte padrão do Godot, botão Voltar genérico).
Usuário mandou a imagem do protótipo (cartão branco com borda azul, cabeçalho "PONTOS"/
"TEMPO" em negrito, linhas divisórias pretas finas entre cada registro) e pediu a mesma
fonte Fredoka One Regular em todos os textos e números.

- Reescrita completa de `scenes/game/history.tscn` (editado direto no arquivo, não via MCP
  node tools, por ser mais prático numa reestruturação grande — depois recarregado no
  editor ao vivo via `scene_open(force_reload=true)`):
  - Título "Histórico": mesmo tratamento sticker (Fredoka One 52px, contorno branco 48px +
    sombra + shadow_outline) usado em "Dificuldade"/"Configurações"/"Pontuação" — antes
    usava a fonte/cor padrão do Godot, sem nenhum estilo.
  - Card novo (`CardWrapper > CardPanel > CardMargin > CardVBox`): `Panel` com
    `StyleBoxFlat` local — fundo branco, borda azul 5px (`#4FAAE2`), corner_radius 24,
    sombra sutil (mesmo padrão de opacidade 30%/offset 3,5 usado nos halos) — cor extraída
    visualmente do print do protótipo (não havia SVG exportado desta tela pra medir em
    pixel exato). Dentro: `HeaderRow` com "PONTOS"/"TEMPO" (Fredoka One 30px, preto,
    centralizados cada um ocupando metade da largura) + `HeaderDivider` (linha preta 3px)
    + `ScrollContainer`/`List` (linhas dinâmicas) + `EmptyLabel` (mesma mensagem de estado
    vazio de antes, agora preta/Fredoka, ocupando o espaço do card quando não há histórico).
  - `VoltarButton` reconstruído com o mesmo padrão usado no resto do jogo (`VoltarWrapper` +
    `Halo` + ícone de seta `seta_voltar.svg` + texto "VOLTAR" em caixa alta, `RedButton`) —
    antes era um `Button` genérico sem halo/ícone/fonte customizada.
- `scripts/ui/history.gd` reescrito: cada entrada do histórico virou uma linha de 2 colunas
  (`_add_row`/`_make_cell`) em vez de uma única `Label` com string concatenada — pontos e
  tempo cada um centralizado na sua metade, fonte Fredoka One 28px preta aplicada via
  `add_theme_font_override`/`add_theme_color_override` (os `Label` são criados em runtime
  por script, então não dá pra herdar de um nó de cena, precisou de override explícito por
  linha). Uma `ColorRect` de 2px preta é adicionada como divisória depois de cada linha.
  **Simplificação deliberada**: a coluna de dificuldade (que existia antes, "Difícil — ...")
  foi removida da exibição pra bater exatamente com as 2 colunas do protótipo — o dado
  continua salvo em `SaveManager.history` (`difficulty`), só não aparece mais nessa tabela.
- Confirmado com `editor_screenshot` real (Menu → Histórico via clique real, mostrando
  entradas de partidas já salvas de sessões anteriores) e 51/51 testes automatizados
  passando.
- **Ajuste fino**: usuário pediu a borda do card em amarelo (`#DFB838`, a mesma cor
  dourada usada em todo o resto do app) em vez do azul usado na 1ª versão — eu tinha
  escolhido azul só por aproximação visual do print do protótipo, sem SVG pra medir o hex
  exato; corrigido pra manter consistência com o resto da paleta. Também corrigido o
  `VoltarButton`, que estava centralizado e colado na margem inferior — igual ao padrão já
  usado na tela de Dificuldade, `VoltarWrapper` mudou de `size_flags_horizontal = 4`
  (centralizado) para `0` (alinhado à esquerda), ficando rente à borda esquerda do card
  acima, do jeito que o Voltar da tela de Dificuldade fica alinhado com os botões de
  dificuldade. Confirmado com `editor_screenshot` real e 51/51 testes automatizados
  passando.
- **Teste de estresse (muitas partidas)**: usuário pediu pra confirmar que o painel não
  "fura" (o conteúdo não vaza pra fora do card) quando há muitas partidas no histórico.
  Sem uma partida real de verdade pra gerar 30+ vitórias, semeei temporariamente
  `SaveManager.history` com 30 entradas falsas direto no `_ready()` de `history.gd`
  (comentário `TEMP STRESS TEST`), rodei o jogo, capturei `editor_screenshot` real com as
  34 entradas totais (30 falsas + 4 reais já salvas) — confirmado: o `ScrollContainer`
  contém a lista inteira, mostra a barra de rolagem, e nenhuma linha vaza pra fora dos
  cantos arredondados do card, com o cabeçalho "PONTOS"/"TEMPO" permanecendo fixo acima da
  área de rolagem. Removi o código de teste logo em seguida (não é uma mudança real, só
  verificação) e confirmei 51/51 testes automatizados continuando a passar depois de
  reverter.
- **Margem vertical**: título e Voltar ficaram colados nas bordas superior/inferior da
  tela — causa: `Layout` só tinha inset lateral (`offset_left=32`/`offset_right=-32`), sem
  nenhum no topo/base, e o `CardWrapper` (único filho com `size_flags_vertical=3`,
  expand+fill) consome todo o espaço vertical sobrando, empurrando literalmente o título
  pro topo (y=0) e o Voltar pro fundo (borda inferior) da tela. Corrigido adicionando
  `offset_top=32`/`offset_bottom=-32` no `Layout`, mesmo valor já usado nas laterais.
  Confirmado com `editor_screenshot` real e 51/51 testes automatizados passando.

### Telas de Pausa e Parabéns implementadas (protótipo fielmente seguido)
Usuário mandou o print lado a lado das duas telas do protótipo ("Tela Pausa"/"Tela
Parabéns") apontando que nenhuma das duas batia com o app: a Pausa era um diálogo modal
genérico (card cinza padrão do Godot sobre o tabuleiro escurecido, sem estilo nenhum) e a
tela de Parabéns nem existia de verdade — `_on_game_won()` só trocava o texto do título de
pontuação no próprio tabuleiro, sem imagem, sem botões "Jogar novamente"/"Sair".

- **Pausa** (`PauseOverlay` em `board.tscn`, reescrito): trocado o antigo `Dim`
  (`ColorRect` preto 55% opacidade) + `Card` (`Panel` com estilo padrão cinza) por um
  `Background` creme opaco (mesma cor de fundo do resto do app) cobrindo a tela inteira —
  o protótipo mostra uma tela cheia, não um diálogo flutuante sobre o jogo escurecido.
  Título "Pausa" ganhou o mesmo tratamento sticker (Fredoka One 52px, contorno branco 48px
  + sombra) de "Dificuldade"/"Pontuação". Os 3 botões (Continuar/Reiniciar/Sair) ganharam
  `Halo` atrás (`HaloRectPanel`, o mesmo componente de sombra usado em todo o app) e fonte
  Fredoka One 32px — antes eram botões `Button` padrão sem halo nem fonte customizada.
- **Parabéns** (`WinOverlay`, node novo em `board.tscn`, não existia): mesma estrutura de
  tela cheia da Pausa (`Background` creme opaco cobrindo o tabuleiro). Contém: título
  "Parabéns!" (sticker, 56px), "Pontuação: X" e "Tempo: MM:SS" (sticker menor, populados de
  verdade a partir de `GameManager.score`/`GameManager.elapsed_seconds` no momento da
  vitória), a ilustração da arara (`assets/icons/cards/arara_vermelha.png` — o mesmo PNG
  1024x1024 de fundo transparente já usado como ícone de carta, reaproveitado aqui em
  tamanho grande) e 2 botões com halo: "Jogar novamente" (verde, texto em 2 linhas via
  `Label` filho com `autowrap_mode`, já que `Button.text` nativo do Godot não quebra linha)
  e "Sair" (vermelho). Os botões usam `theme_override_constants/separation = -60` no
  container pai (`ImageButtonsGroup`) pra sobrepor levemente a parte de baixo da
  ilustração, aproximando do efeito do protótipo onde os botões "descansam" sobre a cauda
  da arara.
  - **Bug pego na 1ª verificação visual**: a arara não aparecia — `size` real do
    `TextureRect` em runtime (`game_manage get_node_info`) mostrava `x=0`, porque só o
    `custom_minimum_size.y` tinha sido setado (320), sem `x`, e `size_flags_horizontal=4`
    (SHRINK_CENTER) não força nenhuma largura própria. Corrigido: `size_flags_horizontal=3`
    (fill, ocupa a largura do container) + `custom_minimum_size` ajustado.
    [[theme_type_variation_gotcha]]-adjacent — mais um caso de "só ficou visível depois de
    um `editor_screenshot` de verdade", não de leitura de código.
  - **Ajuste fino**: mesmo depois de visível, sobrava um vão grande entre "Tempo" e a
    arara — causa: `stretch_mode = KEEP_ASPECT_CENTERED` (5) centraliza a imagem
    (quadrada, 1024x1024) dentro de uma caixa retangular mais alta que larga, deixando
    faixas vazias em cima e embaixo. Trocado para `stretch_mode = KEEP_ASPECT` (4), que
    ancora a imagem escalada no topo-esquerda da caixa em vez de centralizar — a arara
    agora encosta direto embaixo do texto, e o vazio (inevitável, já que a caixa é mais
    alta que a proporção 1:1 da imagem) sobra embaixo, onde é absorvido pela sobreposição
    negativa dos botões em vez de aparecer como um buraco entre o texto e a imagem.
  - `board.gd`: `_on_game_won()` agora popula `win_score_label`/`win_time_label` e mostra
    `win_overlay` (em vez de mutar `ScoreTitleLabel`/`ScoreValueLabel` do tabuleiro, que
    ficam escondidos atrás do overlay de qualquer forma — lógica antiga removida, incluindo
    o `@onready var score_title_label` que ficou sem nenhum uso). Lógica de reinício
    extraída pra um `_restart_game()` privado compartilhado entre "Reiniciar" (da Pausa) e
    o novo "Jogar novamente" (da tela de Parabéns) — ambos fazem exatamente a mesma coisa
    (zera progresso, reconstrói a grade, reabilita os botões, esconde qualquer overlay
    aberto). "Sair" da tela de Parabéns reusa o mesmo `_on_sair_pressed()` já existente.
- **Verificação sem jogar uma partida inteira**: pra conferir a tela de Parabéns sem
  precisar resolver o tabuleiro de verdade a cada teste visual, adicionei uma linha
  temporária em `_ready()` (`GameManager.score = 220; _on_game_won()`, comentário `TEMP WIN
  SCREEN TEST`) só durante o desenvolvimento, tirei os screenshots reais precisando dela,
  e removi a linha antes de fechar a tarefa — mesmo padrão já usado no teste de estresse do
  Histórico (dado de teste nunca fica no código final).
- Fluxo completo confirmado com o jogo rodando de verdade: Pausa abre/fecha corretamente
  (Continuar), tela de Parabéns aparece com pontuação/tempo reais, "Jogar novamente" reinicia
  o tabuleiro do zero (pontuação 0, cartas viradas pra baixo, overlay escondido) e "Sair"
  volta ao menu — mais 51/51 testes automatizados passando depois da limpeza do código de
  teste.
- **Ajuste pedido em seguida**: usuário achou a arara pequena demais e pediu pra colocá-la
  "no fundo, bem maior, podendo passar por trás de alguns elementos como no print" —
  diferente da 1ª versão (que ficava contida entre o texto e os botões, sem sobrepor nada).
  Restruturado: `ParrotImage` saiu de dentro do `VBoxContainer` de texto/botões e virou uma
  camada de fundo própria, direto em `WinOverlay` (entre o `Background` creme e o `Layout`
  do texto/botões na ordem de desenho — visível atrás de tudo, na frente só do fundo
  sólido). `Layout` ganhou um `Spacer` (`Control`, `size_flags_vertical=3`) entre o bloco de
  texto e o `ButtonsBox`, empurrando os botões pro rodapé da tela e deixando o meio livre
  pra arara aparecer por trás. Título/Score/Time/Spacer/ButtonsBox ganharam
  `mouse_filter=2` (IGNORE) pra não bloquear cliques por cima da imagem sem necessidade
  (nenhum deles precisa capturar clique, só os botões dentro do `ButtonsBox`).
  `ParrotImage` passou a usar âncora de tela cheia com offsets negativos/positivos
  (`offset_left/top` negativos, `offset_right/bottom` positivos) pra criar uma caixa maior
  que a própria tela, e `stretch_mode = KEEP_ASPECT_CENTERED` (5) escala a imagem quadrada
  proporcionalmente dentro dessa caixa maior — o excesso que passa da borda real da tela
  (412px de largura) simplesmente não é desenhado (cortado pela janela do jogo), dando o
  efeito de "zoom" sem distorcer a imagem.
  - Depois de ver o resultado ainda meio contido, usuário pediu "dobre o tamanho atual":
    dobrado o cálculo (offsets que geravam uma imagem renderizada de ~492x492 viraram
    ~984x984 de bounding box) — resultado final: a arara ocupa quase a tela inteira,
    com a ponta da asa direita passando visivelmente atrás do texto "Pontuação"/"Tempo" e a
    cauda passando atrás do botão "Sair", batendo com o print de referência.
  - Confirmado de novo com o mesmo truque de teste temporário em `_ready()` (revertido
    depois) e 51/51 testes automatizados passando.
  - **Ajuste fino final**: usuário achou o resultado grande demais e pediu "diminua 25%".
    Como só a largura da caixa (`offset_left`/`offset_right`) determina o tamanho
    renderizado (a imagem é quadrada e o encaixe é sempre limitado pela largura, já que a
    caixa é sempre mais alta que larga), reduzir o tamanho final em 25% exigiu resolver a
    largura-alvo (984px → 738px, 75% da anterior) e, a partir dela, o novo
    `offset_left`/`offset_right` (±163, contra os ±286 anteriores) — não bastava multiplicar
    os offsets antigos por 0.75 diretamente, já que a relação entre offset e tamanho final
    renderizado não é 1:1 (a largura da caixa cresce 2x mais rápido que cada offset
    individual). `offset_top`/`offset_bottom` mantidos inalterados de propósito: como só a
    SOMA deles determina a posição vertical do centro da imagem (a altura da caixa em si
    não afeta o tamanho renderizado, contanto que continue maior que a largura), mexer neles
    teria deslocado o pássaro verticalmente sem necessidade. Confirmado com
    `editor_screenshot` real e 51/51 testes automatizados passando.

### Tela de Tutorial: reescrita com mini jogo da memória 2x2 de verdade
A tela de Tutorial (RF05) nunca tinha recebido nenhuma passada de fidelidade visual — era
só texto padrão do Godot em 3 parágrafos, sem fonte/cor customizada, sem elemento visual
nenhum. Usuário mandou o print do protótipo ("Tela Tutorial": título sticker, um card
branco com uma frase curta de instrução, uma grade 2x2 de cartas, botão "Entendi!") e pediu
pra implementar com um jogo 2x2 de verdade, não só a imagem estática.

- `scenes/game/tutorial.tscn` reescrito do zero: título "Tutorial" com o mesmo tratamento
  sticker (Fredoka One 52px, contorno branco 48px + sombra) de todas as outras telas;
  `InstructionCard` (`Panel`, `StyleBoxFlat` local branco com corner_radius 24 + sombra
  sutil, sem borda colorida — bate com o card simples do protótipo) contendo a frase única
  "Toque em 2 cartas para encontrar o par correto!" (Fredoka One 24px, navy, substituindo o
  texto antigo de 3 parágrafos); `CardGrid` (`GridContainer` 2 colunas) que o script povoa
  em runtime; `EntendiButton` ganhou o padrão halo+Fredoka já usado em todos os outros
  botões (antes era um `Button` `LimeButton` liso, sem halo).
- `scripts/ui/tutorial.gd` reescrito com uma mini-implementação de jogo da memória
  independente do `GameManager` (2 pares, 4 cartas, `theme_type_variation = CardButton` —
  o mesmo estilo branco/borda navy das cartas do tabuleiro de verdade): embaralha os
  valores, cria os 4 botões, e reimplementa localmente a lógica de virar/comparar/
  desfazer já usada em `board.gd` (`_pop_correct`/`_wobble_incorrect` copiados do mesmo
  jeito — sem pontuação, sem `GameManager`, é só uma demonstração). Quando os 2 pares são
  encontrados, a grade se reembaralha automaticamente após 0.5s pra permitir praticar de
  novo sem precisar sair e voltar à tela.
- Testado com o jogo rodando de verdade (`project_run(mode="custom", scene=".../
  tutorial.tscn")`, já que o tutorial só apareceria automaticamente no primeiro acesso, e o
  save real já tinha `seen_tutorial=true` de sessões anteriores): cliques reais nas 4
  cartas confirmaram o par certo desabilitando/"pop"-ando e a re-embaralhagem automática
  depois (novos nós de botão, textos resetados pra "?"), e "Entendi!" navegando de volta
  pro menu principal corretamente. 51/51 testes automatizados continuam passando.

## Checkpoint: commit da fidelidade visual + reauditoria de acessibilidade
Toda a fase de fidelidade visual (títulos sticker, Dificuldade, Tabuleiro, Configurações,
Histórico, Pausa/Parabéns, Tutorial) foi commitada (`5485f25`, 31 arquivos) depois do
usuário confirmar que o app está visualmente fiel ao protótipo. Antes de seguir pros
próximos passos (ícones de carta reais, "continuar partida salva", export Android),
reauditei RNF01-04 — a auditoria original é da Fase 8, anterior a toda essa fase visual.

- **RNF01 (contraste ≥4.5:1)**: recalculado WCAG (luminância relativa) pra cada par
  texto/fundo usado nas telas redesenhadas. Tudo passa com folga:
  - Texto preto sobre os botões coloridos: `YellowButton` 14.1:1, `LimeButton` 12.1:1,
    `RedButton` 7.4:1, `BlueButton` 8.6:1, `GreenButton` 6.0:1, `OrangeButton` 10.3:1.
  - Texto navy sobre branco (cartas do tabuleiro, tabela do Histórico, lista de opções de
    Configurações, card de instrução do Tutorial): 13.3:1.
  - Checkmark verde (`#185702`) sobre creme e sobre branco: 7.2:1 e 8.7:1.
  - **Único ponto sem 3:1** (não é falha de RNF01, que é sobre texto): a borda amarela
    `#DFB838` da caixa de ícone contra o fundo branco interno dá só 1.9:1 — mas essa borda é
    puramente decorativa (não é limite de um controle interativo nem carrega informação por
    si só, o ícone dentro dela já é claramente visível), então não se aplica o critério de
    contraste não-textual (WCAG 1.4.11) que exigiria 3:1. Registrado só pra referência
    futura, não é uma pendência.
- **RNF02 (tipografia ≥18sp)**: todo texto novo (labels de opção 28px, instrução do
  tutorial 24px, tabela do histórico 28-30px, "DICA" 29px, pontuação/tempo da tela de
  Parabéns 32px) segue bem acima do mínimo.
- **RNF03 (toque ≥48x48dp)**: todos os novos botões interativos (opções de Configurações,
  Voltar de todas as telas, cartas do mini-jogo do Tutorial, botões da tela de Parabéns,
  botões da Pausa) têm `custom_minimum_size` explícito de pelo menos 48px de altura, a
  maioria bem maior (74-158px).
- **RNF04 (nada punitivo)**: nenhuma tela nova introduziu cronômetro regressivo, alarme ou
  flash de cor; as animações usadas (pop de acerto, wobble de erro, re-embaralhagem do
  tutorial) seguem o mesmo padrão suave já auditado na Fase 2/8.
- Nenhuma correção foi necessária nesta rodada — só confirmação. `test_run` não precisou
  rodar de novo (nenhum código de lógica mudou nesta reauditoria, só a fase visual anterior
  já tinha os 51/51 confirmados).

### Pendências que ficam (próximos passos, em ordem de prioridade sugerida)
1. **Ícones reais de animal nas cartas do tabuleiro**: `board.gd` ainda mostra o número do
   par como texto (`str(GameManager.board[i])`) em vez de um ícone — nunca foi ligado aos
   PNGs em `assets/icons/cards/`. Só existem 9-10 ícones (`arara`, `arara_vermelha`,
   `caracol`, `chita`, `coala`, `elefante`, `peixe_dourado`, `porco`, `spitz`, `urso`),
   suficiente pra Fácil (8 pares) mas insuficiente pra Médio (15) e Difícil (20) — precisa
   de mais ícones ou uma estratégia de fallback antes de religar isso.
2. **"Continuar partida salva" no menu principal**: `SaveManager.resume_in_progress()`/
   `has_in_progress()` existem desde a Fase 3, mas nada no menu principal expõe isso ao
   jogador — hoje uma partida salva fica invisível.
3. **Exportação Android (RNF10)**: ainda bloqueada nesta máquina (sem Android SDK/JDK/
   templates instalados) — passos manuais já documentados na Fase 7, precisam ser feitos
   pelo usuário fora desta sessão, incluindo remover o autoload `_mcp_game_helper` e
   desabilitar o plugin Godot AI antes do build final.
4. Testar em mais proporções de tela reais (celulares mais altos/estreitos que 412x917)
   quando houver um dispositivo/emulador disponível.

## Ícones reais de animal nas cartas do tabuleiro (item 1 dos próximos passos, resolvido)
Usuário forneceu uma pasta com 30 fotos de animal isoladas (fundo branco, mesmo estilo dos
9 ícones já existentes) — o suficiente pra cobrir os 20 pares do nível Difícil sem repetir.

- 27 fotos novas processadas e renomeadas (português, `snake_case`) pra
  `assets/icons/cards/`: `golfinho`, `caranguejo`, `sapo`, `borboleta`, `pombo`, `pardal`,
  `girafa`, `leao`, `gato`, `vespa`, `cachorro`, `coelho`, `canario`, `arara_azul`, `vaca`,
  `cavalo`, `jacare`, `hipopotamo`, `rinoceronte`, `leao_marinho`, `cavalo_marinho`, `pato`,
  `porquinho_da_india`, `galinha`, `cabrito`, `ovelha`, `hamster` (mantidas como `.jpg`,
  sem necessidade de converter pra `.png` — o Godot importa JPG normalmente como
  Texture2D, e o `TextureRect` já escala/centraliza qualquer proporção). 3 fotos do lote
  eram duplicatas de animais já existentes (elefante, peixe dourado, porco) e foram
  descartadas.
- Novo `scripts/core/animal_card_icons.gd` (`class_name MemoryCardIcons`, puro, sem
  dependência de cena — mesmo padrão de `board_generator.gd`): `POOL` com as 36 imagens
  (10 antigas + 26 novas) e `pick(count, rng)`, que embaralha o pool inteiro e retorna os
  primeiros `count` — cada partida sorteia um subconjunto diferente dos 36, não sempre os
  mesmos ícones nem sempre na mesma ordem. Testado em `tests/test_card_icons.gd` (6 casos:
  pool sem duplicata, pool com pelo menos 20, `pick` retorna a quantidade certa, os ícones
  sorteados são distintos entre si, só vêm do pool, e variam entre seeds diferentes).
- `board.gd` (`_build_grid`): cada carta ganhou um `TextureRect` filho (escondido por
  padrão) com a textura de `MemoryCardIcons.pick(pares)[GameManager.board[i]]` — antes o
  texto revelado era só o número do índice do par (`str(GameManager.board[i])`). Extraído
  `_reveal_card`/`_hide_card` (mostra/esconde o ícone e limpa/restaura o texto "?") e
  reaproveitado em `_on_card_pressed`, `_on_match_failed` e `_on_dica_pressed` — o dado
  central do jogo (`GameManager.board`, os ids de par) não mudou nada, só a representação
  visual de cada id virou um ícone em vez de um número.
- **Gotcha real do ambiente**: a 1ª tentativa de criar o script com `class_name CardIcons`
  travou o editor num loop de "GDScript reload failed (error 43)" que **persistia mesmo
  reescrevendo o conteúdo do zero** — só depois de várias rodadas de bisseção ficou claro
  que era o **path do arquivo** que tinha ficado num estado de reload quebrado no cache de
  scripts do editor (não o conteúdo, não o nome da classe em si — comprovado testando o
  mesmo conteúdo num path novo, que funcionou de primeira). Corrigido apagando os arquivos
  problemáticos (`card_icons.gd`, depois também `card_icon_pool.gd`, que herdou o problema
  ao reusar path) e recriando do zero num path nunca usado
  (`scripts/core/animal_card_icons.gd`, classe `MemoryCardIcons`). Vale lembrar como
  solução futura: se um `script_create`/`script_patch` travar em "reload failed" mesmo com
  conteúdo válido, o path em si pode estar com cache quebrado — apagar e recriar com um
  nome de arquivo novo resolve, `filesystem_manage(op="scan")` sozinho não resolve.
- Testado com o jogo rodando de verdade nas 3 dificuldades: Fácil mostrou ícones variados
  (leão, ovelha, coala, hipopótamo, sapo, pombo, golfinho, entre outros) sem repetição
  indevida, um par de sapos foi casado de propósito (posições identificadas via
  `game_manage get_node_info` lendo a textura de cada carta ainda oculta) confirmando que
  acerto mostra os dois ícones e mantém revelado (pontuação foi a 10), e o nível Difícil
  (40 cartas, 20 pares) carregou a grade inteira sem erro, incluindo o 20º ícone distinto
  (jacaré) na última carta. 57/57 testes automatizados passando (51 anteriores + 6 novos de
  `card_icons`).
