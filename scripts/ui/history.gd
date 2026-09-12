extends Control
## Tela de Histórico (RF07). Lista pontuações e tempos de partidas vencidas
## (SaveManager.history) — abandonadas/reiniciadas/pausadas não aparecem
## (RN05), pois nunca chegam a virar entrada de histórico.
## Tabela de 2 colunas (Pontos/Tempo), fiel ao protótipo — a dificuldade da
## partida continua salva em SaveManager.history, só não aparece nessa tabela.

const ROW_FONT := preload("res://assets/fonts/FredokaOne-Regular.ttf")
const ROW_FONT_SIZE := 28
const DIVIDER_COLOR := Color(0, 0, 0, 1)

@onready var scroll: ScrollContainer = $Layout/CardWrapper/CardPanel/CardMargin/CardVBox/ScrollContainer
@onready var list_container: VBoxContainer = $Layout/CardWrapper/CardPanel/CardMargin/CardVBox/ScrollContainer/List
@onready var empty_label: Label = $Layout/CardWrapper/CardPanel/CardMargin/CardVBox/EmptyLabel


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
	for i in range(entries.size() - 1, -1, -1):
		var entry: Dictionary = entries[i]
		var score: int = int(entry.get("score", 0))
		var time_str := TimeFormat.mmss(float(entry.get("time_seconds", 0.0)))
		_add_row(str(score), time_str)


func _add_row(pontos_text: String, tempo_text: String) -> void:
	var row := HBoxContainer.new()
	row.add_child(_make_cell(pontos_text))
	row.add_child(_make_cell(tempo_text))
	list_container.add_child(row)
	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(0, 2)
	divider.color = DIVIDER_COLOR
	list_container.add_child(divider)


func _make_cell(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_override("font", ROW_FONT)
	label.add_theme_font_size_override("font_size", ROW_FONT_SIZE)
	label.add_theme_color_override("font_color", Color(0, 0, 0, 1))
	return label


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
