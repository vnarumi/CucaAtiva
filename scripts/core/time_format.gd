class_name TimeFormat
extends RefCounted
## Formatação pura de tempo (RF04/RF07) — sem dependência de cena ou editor.

## Converte segundos (float, sempre >= 0) para "MM:SS" arredondado ao segundo.
static func mmss(total_seconds: float) -> String:
	var total := int(round(max(0.0, total_seconds)))
	var minutes := total / 60
	var seconds := total % 60
	return "%02d:%02d" % [minutes, seconds]
