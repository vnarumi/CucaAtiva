extends Control
## Tela de seleção de dificuldade (RF01). Inicia a partida no GameManager e
## troca para a cena do tabuleiro.

func _on_facil_pressed() -> void:
	_start("facil")


func _on_medio_pressed() -> void:
	_start("medio")


func _on_dificil_pressed() -> void:
	_start("dificil")


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func _start(difficulty: String) -> void:
	GameManager.start_game(difficulty)
	get_tree().change_scene_to_file("res://scenes/game/board.tscn")
