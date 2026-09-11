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

## Fase 2 — Feedback e acessibilidade (RF03, RNF01-04)
- Sons/animações de acerto e erro.
- Tema com contraste ≥4.5:1, fontes ≥18sp.
- Áreas de toque ≥48x48dp em cartas/botões.
- Sem cronômetro regressivo/alarmes — cronômetro sempre progressivo, feedback nunca punitivo.
- Tela Configurações (volume + tamanho da letra) vista no protótipo — não é um RF numerado
  no documento original, mas serve diretamente RNF01/RNF02; tratar como parte desta fase.
- Agentes: `godot-scene-builder` implementa, `accessibility-qa` audita
  (skill `accessibility-audit`).

## Fase 3 — Persistência (RF04, RF07, RF08, RN05)
- `SaveManager` autoload: histórico e autosave em `user://save_data.json`.
- Autosave em `NOTIFICATION_APPLICATION_PAUSED` / perda de foco.
- Histórico só grava em vitória (RN05).
- Agente: `godot-gameplay-engineer`.

## Fase 4 — Telas de apoio (RF05, RF06, RF07, RN06)
- Tutorial interativo no primeiro acesso.
- Menu de pausa: continuar / reiniciar (RN06: zera pontuação, cronômetro, reembaralha) /
  menu principal.
- Tela de histórico (lista de pontuações e melhores tempos).
- Agentes: `godot-scene-builder` + `godot-gameplay-engineer`.

## Fase 5 — Dicas (RF13, RN04)
- Botão de dica: custo 15 pontos, exige saldo ≥15, máx. 3 por partida.
- Revela par ou vislumbre temporário do tabuleiro.
- Agente: `godot-gameplay-engineer`.

## Fase 6 — Polimento (RNF05, RNF06, RNF08)
- Latência de virada/transição ≤200ms.
- Layout responsivo em proporções variadas de tela.
- Auditoria de estabilidade (sem exceptions não tratadas, sem trava).
- Agentes: `godot-scene-builder` + `godot-qa-tester`.

## Fase 7 — Exportação Android (RNF09, RNF10)
- Preset de export Android, min SDK 26 (Android 8.0 Oreo).
- Confirmar ausência de coleta/telemetria de dados pessoais (LGPD).
- Agente: `godot-gameplay-engineer` (configuração de projeto).

## Fase 8 — QA contínua
- Antes de cada marco: rodar `accessibility-audit`, `test_run` completo, playtest manual
  via skill `run`.
- Agente: `godot-qa-tester` + `accessibility-qa`.

## Bloqueio conhecido
Sincronização com o Figma (`figma-design-sync`, skill `new-screen-from-figma`) está
bloqueada por falta de acesso de edição ao arquivo. Como interino, o usuário forneceu um
print das 8 telas do protótipo — ver [design-notes.md](design-notes.md) para o inventário
de telas e a paleta aproximada extraída dele. Assim que o acesso ao Figma for concedido (ou
o usuário exportar cores/assets exatos), a Fase 2 (e telas subsequentes) devem ser
revisadas contra o design real em vez das estimativas visuais.
