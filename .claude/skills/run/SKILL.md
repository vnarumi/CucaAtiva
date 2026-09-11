---
name: run
description: Launch, verify, and stop the Cuca Ativa Godot project through the connected godot-ai MCP editor session. Use whenever asked to run, boot, or smoke-test the game, or to confirm a change works end-to-end. Takes precedence over the global run skill for this project.
---

There is no Godot CLI binary on PATH in this environment. The project always runs through
the live editor session the `godot-ai` MCP plugin is already connected to.

1. Confirm a session is connected: `mcp__godot-ai__session_manage(op="list")`. There
   should be exactly one entry with `project_path` pointing at this repo — note its
   `session_id` (only needed if more than one session is ever connected; otherwise omit it
   and calls target the active session).
2. Launch: `mcp__godot-ai__project_run(mode="main")` (or `mode="custom"` +
   `scene="res://path/to/scene.tscn"` to boot a specific screen instead of the full flow).
   Pass `autosave=false` if you want a throwaway smoke test that shouldn't persist
   in-memory editor mutations to disk.
3. Check the result's `game_status.status`. `"live"` means it booted cleanly. `"break"`
   means a GDScript parse/load error froze it before the game helper registered — the
   response names the failing script; call `project_manage(op="stop")`, fix the error, and
   relaunch. `"no_helper"` / `"not_live"` mean it didn't come up as expected — check
   `recent_errors` and `mcp__godot-ai__logs_read`.
4. To inspect the running game: `mcp__godot-ai__game_manage` with `get_scene_tree` /
   `get_ui_elements` / `get_node_info`, or drive it with `input_key` / `input_mouse` /
   `input_action` to exercise a flow (e.g. tap a difficulty button, flip two cards).
5. Stop when done: `mcp__godot-ai__project_manage(op="stop")`. It's idempotent — safe to
   call even if nothing is running.

`mcp__godot-ai__editor_screenshot` renders the **editor's** 3D/2D viewport, not the running
game window — for a 2D project like this one it usually needs `source="viewport_2d"`, and
even then it may not reflect the live game view. Prefer `game_manage`'s `get_ui_elements`/
`get_scene_tree` to verify running-game state; treat a screenshot as a nice-to-have, not
the verification step.
