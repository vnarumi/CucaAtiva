# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project status

Phase 0 (scaffold) is done: git is initialized, and the project boots to a placeholder main menu
(`scenes/main_menu/main_menu.tscn`) with skeleton autoloads (`GameManager`, `SaveManager`,
`AudioManager` in `scripts/autoload/`) and a placeholder accessible theme
(`assets/theme/base_theme.tres`). No real gameplay logic exists yet — `scripts/core/score_rules.gd`
and `scripts/core/board_generator.gd` are empty stubs filled in during Phase 1. See
`docs/requisitos.md` for the requirements (RF/RNF/RN ids) and `docs/plano-de-desenvolvimento.md`
for the phased roadmap. This chat/session acts as the orchestrator, delegating phases to the
subagents in `.claude/agents/`.

Figma sync is blocked: the MCP Figma tools report no edit access to the linked file. Grant the
connected Figma account edit (or at least viewer) access before using `figma-design-sync` or the
`new-screen-from-figma` skill — until then, scenes use the placeholder theme.

## Engine configuration

- Godot version: 4.7, using the **GL Compatibility** rendering method (not Forward+/Mobile) — keep
  this in mind when adding shaders or rendering features, since GL Compatibility has a reduced
  feature set (e.g. no compute shaders, limited light/shadow features).
- 3D physics engine: **Jolt Physics** (`3d/physics_engine="Jolt Physics"` in `project.godot`), not
  Godot's default GodotPhysics3D.
- Display stretch mode is `canvas_items` with `expand` aspect, implying this targets a 2D or
  UI-driven game with resolution-independent scaling.
- Windows rendering device driver is explicitly set to `d3d12`.

## Working with the project

- Edit `project.godot` directly only for settings not easily reached in the editor UI; prefer the
  Godot editor for project settings changes when possible.
- The `.godot/` directory is engine-generated cache/import data (ignored by git via `.gitignore`) —
  never hand-edit files under it.
- There is no Godot CLI binary on PATH in this environment — all running/testing goes through the
  `godot-ai` MCP plugin against the already-connected live editor session (see `session_manage`).
- **Run the game**: use the `run` skill (`.claude/skills/run/SKILL.md`), which wraps
  `mcp__godot-ai__project_run(mode="main")` + `editor_state` polling + `project_manage(op="stop")`.
- **Run tests**: GDScript suites live in `tests/` (see `tests/README.md`), using the `McpTestSuite`
  base class already bundled in `addons/godot_ai/testing/test_suite.gd` — no extra test framework
  (e.g. GUT) is installed or needed. Run them with `mcp__godot-ai__test_run`.
