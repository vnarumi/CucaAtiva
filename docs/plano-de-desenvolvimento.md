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
- Bloco do título ainda não tem o "card" branco de fundo com sombra que o protótipo usa
  (só o contorno branco por letra) — o espaçamento entre as duas linhas também está mais
  solto que no protótipo. Ambos são polimento menor, não pedidos explicitamente ainda.
