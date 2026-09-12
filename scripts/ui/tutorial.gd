extends Control
## Tutorial interativo no primeiro acesso (RF05). Mostra um mini jogo da
## memória 2x2 (2 pares) para o jogador praticar virar/comparar cartas antes
## de ir pro tabuleiro de verdade — sem pontuação nem GameManager envolvidos,
## é só uma demonstração. Marca como visto no SaveManager e só aparece uma vez.

const CARD_SIZE := Vector2(110, 110)
const MISMATCH_REVEAL_SECONDS := 0.6
const RESHUFFLE_DELAY_SECONDS := 0.5
const PAIR_VALUES := [1, 1, 2, 2]

@onready var grid: GridContainer = $Layout/CardGrid

var _buttons: Array[Button] = []
var _values: Array = []
var _pending_indices: Array[int] = []
var _matched: Array[int] = []


func _ready() -> void:
	_build_grid()


func _build_grid() -> void:
	for child in grid.get_children():
		child.queue_free()
	_buttons.clear()
	_pending_indices.clear()
	_matched.clear()
	_values = PAIR_VALUES.duplicate()
	_values.shuffle()
	for i in _values.size():
		var btn := Button.new()
		btn.custom_minimum_size = CARD_SIZE
		btn.theme_type_variation = &"CardButton"
		btn.text = "?"
		btn.pressed.connect(_on_card_pressed.bind(i))
		grid.add_child(btn)
		_buttons.append(btn)


func _on_card_pressed(index: int) -> void:
	if _pending_indices.size() >= 2:
		return
	if _pending_indices.has(index) or _matched.has(index):
		return
	_buttons[index].text = str(_values[index])
	_pending_indices.append(index)
	if _pending_indices.size() < 2:
		return
	var a: int = _pending_indices[0]
	var b: int = _pending_indices[1]
	if _values[a] == _values[b]:
		_matched.append(a)
		_matched.append(b)
		_buttons[a].disabled = true
		_buttons[b].disabled = true
		_pop_correct(_buttons[a])
		_pop_correct(_buttons[b])
		_pending_indices.clear()
		if _matched.size() == _values.size():
			await get_tree().create_timer(RESHUFFLE_DELAY_SECONDS).timeout
			_build_grid()
	else:
		_wobble_incorrect(_buttons[a])
		_wobble_incorrect(_buttons[b])
		await get_tree().create_timer(MISMATCH_REVEAL_SECONDS).timeout
		_buttons[a].text = "?"
		_buttons[b].text = "?"
		_pending_indices.clear()


func _pop_correct(btn: Button) -> void:
	var tween := create_tween()
	tween.tween_property(btn, "scale", Vector2(1.15, 1.15), 0.12)
	tween.tween_property(btn, "scale", Vector2.ONE, 0.12)


func _wobble_incorrect(btn: Button) -> void:
	var tween := create_tween()
	tween.tween_property(btn, "rotation_degrees", -6.0, 0.06)
	tween.tween_property(btn, "rotation_degrees", 6.0, 0.06)
	tween.tween_property(btn, "rotation_degrees", 0.0, 0.06)


func _on_entendi_pressed() -> void:
	SaveManager.mark_tutorial_seen()
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
