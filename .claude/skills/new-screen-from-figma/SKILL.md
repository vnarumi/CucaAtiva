---
name: new-screen-from-figma
description: Procedure for turning one Figma screen node into a Godot scene for Cuca Ativa, once Figma access is granted. Bridges figma-design-sync's output to godot-scene-builder's implementation.
---

Blocked until the Figma file (`YLYCb5Q3mEpYYXNq4yHjeh`) grants edit/viewer access to the
connected account — see `docs/plano-de-desenvolvimento.md` "Bloqueio conhecido". Confirm
with a single `get_metadata` call before running the rest of this procedure; if it still
errors on permissions, stop and report that, don't retry.

1. **Extract**: run the `figma-design-sync` agent (or its steps directly) on the target
   node to produce `docs/design-spec/<screen-name>.md` — a token table (colors, font
   sizes, spacing) plus a component list.
2. **Tokens into the theme**: for colors/font sizes that are new or differ from
   `res://assets/theme/base_theme.tres`, extend that theme via `theme_manage`
   (`set_color`/`set_font_size`/`set_stylebox_flat`) rather than creating a
   per-screen theme — keep one shared theme so accessibility fixes apply everywhere.
   Before writing a token, check it against RNF01/RNF02 (see the `accessibility-audit`
   skill) — don't blindly copy a Figma value that fails contrast or is under 18sp.
3. **Structure**: build the scene with `scene_manage(op="create")` +
   `node_create`/`node_manage`/`node_set_property`, matching the component list from the
   spec doc. Use containers/anchors, not fixed positions (RNF06).
4. **Verify**: `scene_save`, then compare a live screenshot
   (`mcp__godot-ai__editor_screenshot`, `source="viewport_2d"` for 2D scenes — see the
   `run` skill for its limitations) against the Figma `get_screenshot` render for the same
   node. They won't be pixel-identical (different rendering engines) — check structure and
   proportions, not exact pixels.
5. **Hand off**: run the `accessibility-audit` checklist (or dispatch `accessibility-qa`)
   before marking the screen done.
