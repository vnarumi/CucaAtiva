extends Control
## Tutorial interativo no primeiro acesso (RF05). Texto guiado simples;
## marca como visto no SaveManager e só aparece uma vez.

func _on_entendi_pressed() -> void:
	SaveManager.mark_tutorial_seen()
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
