extends Panel
## Menu principal (RF01 entrada). No primeiro acesso, redireciona para o
## tutorial (RF05) antes de qualquer outra coisa.

func _ready() -> void:
	if not SaveManager.seen_tutorial:
		get_tree().change_scene_to_file("res://scenes/game/tutorial.tscn")


func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/difficulty_select.tscn")


func _on_historico_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/history.tscn")


func _on_configuracoes_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/settings.tscn")
