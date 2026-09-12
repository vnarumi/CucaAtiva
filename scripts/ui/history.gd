extends Control
## Tela de Histórico (RF07). Lista pontuações e tempos de partidas vencidas
## (SaveManager.history) — abandonadas/reiniciadas/pausadas não aparecem
## (RN05), pois nunca chegam a virar entrada de histórico.

const DIFFICULTY_LABELS := {
	"facil": "Fácil",
	"medio": "Médio",
	"dificil": "Difícil",
}

@onready var scroll: ScrollContainer = $Layout/ScrollContainer
@onready var list_container: VBoxContainer = $Layout/ScrollContainer/List
@onready var empty_label: Label = $Layout/EmptyLabel


func _ready() -> void:
	_populate()


func _populate() -> void:
	for child in list_container.get_children():
		child.queue_free()
	var entries: Array = SaveManager.history
	var is_empty := entries.is_empty()
	empty_label.visible = is_empty
	scroll.visible = not is_empty
	# Mais recente primeiro.
	var row_width: float = get_viewport_rect().size.x - 40.0
	for i in range(entries.size() - 1, -1, -1):
		var entry: Dictionary = entries[i]
		var row := Label.new()
		var difficulty_key: String = str(entry.get("difficulty", ""))
		var difficulty_label: String = DIFFICULTY_LABELS.get(difficulty_key, difficulty_key)
		var score: int = int(entry.get("score", 0))
		var time_str := TimeFormat.mmss(float(entry.get("time_seconds", 0.0)))
		row.text = "%s — Pontos: %d — Tempo: %s" % [difficulty_label, score, time_str]
		row.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.custom_minimum_size = Vector2(row_width, 0)
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		list_container.add_child(row)


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
