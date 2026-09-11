---
name: accessibility-audit
description: Checklist and math for auditing a Cuca Ativa screen against RNF01-04 and RNF06 (contrast, typography, touch targets, non-punitive feedback, responsive layout). Use before signing off on any scene godot-scene-builder produces.
---

Requirement ids and thresholds are defined in `docs/requisitos.md` — this skill is the
*procedure* for checking them, not the source of truth for the numbers.

## 1. Contrast (RNF01, >= 4.5:1)

Read the theme resource (`res://assets/theme/*.tres` — plain text, readable directly) or
the node's effective `font_color`/background via `node_get_properties`, and compute WCAG
relative luminance:

```
linearize(c) = c/12.92                        if c <= 0.03928
             = ((c + 0.055) / 1.055) ^ 2.4     otherwise   # c is the 0-1 sRGB channel
L = 0.2126 * linearize(R) + 0.7152 * linearize(G) + 0.0722 * linearize(B)
contrast = (L_lighter + 0.05) / (L_darker + 0.05)
```

Compute for every distinct (foreground, background) pair actually on screen — text over a
panel, a button's label over its own stylebox fill, etc. Report the worst one found.

## 2. Typography (RNF02, >= 18sp, sans-serif)

Check `font_size` on `Label`/`Button`/etc. via the theme or per-node overrides. There is no
enforced px-per-sp constant in this project yet — until Phase 6 settles a DPI/scale
convention, treat any base font size below ~28px as suspect and flag it for confirmation
rather than auto-passing. Confirm the font resource is a sans-serif family (the placeholder
theme uses Godot's built-in default font, which is sans-serif) — flag anything serif.

## 3. Touch targets (RNF03, >= 48x48dp)

For every interactive `Control` (`Button`, `TouchScreenButton`, a card's clickable area),
read `size` (or `custom_minimum_size` if layout hasn't run) via `node_get_properties`.
Same caveat as above: no project-wide dp conversion is settled yet, so compare against
project resolution/stretch settings (`canvas_items` + `expand`, per `project.godot`) rather
than assuming 1px = 1dp, and flag ambiguous cases for confirmation instead of guessing.

## 4. Non-punitive feedback (RNF04)

Grep the scene/scripts for countdown-style timers (a `Timer` or label counting *down*
during play), alarm-like audio cues, or screen shake/flash on error. A stopwatch counting
*up* is fine; anything that could read as a deadline or a penalty flash is not.

## 5. Responsiveness (RNF06)

Check that interactive/text nodes use anchors or container nodes (`VBoxContainer`,
`CenterContainer`, `MarginContainer`, full-rect anchors) rather than fixed
`position`/`size` with anchors left at the top-left default (`anchor_* == 0`). Fixed pixel
layout on anything the player must see or tap is a finding.

## Reporting

One line per finding: `node path — requirement id — measured vs required`. If a screen
passes everything, say so explicitly.
