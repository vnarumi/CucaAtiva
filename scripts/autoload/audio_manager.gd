extends Node
## Fase 2 preenche feedback sonoro (RF03, RNF04 — sem alarmes estressantes).

var _sfx_player: AudioStreamPlayer


func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	add_child(_sfx_player)
