# Testes

Suítes GDScript usando `McpTestSuite` (`addons/godot_ai/testing/test_suite.gd`), a
base já incluída no plugin godot-ai. Convenção: um arquivo `test_*.gd` por suíte, métodos
`test_*`, rodados via `mcp__godot-ai__test_run` (descobre tudo em `res://tests/`).

Preferir testar `scripts/core/*.gd` (lógica pura, sem dependência de cena/editor) — é onde
vivem as regras de negócio RN01-RN06. Ver `docs/plano-de-desenvolvimento.md` Fase 1 e
`docs/requisitos.md`.
