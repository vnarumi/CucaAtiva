extends Control
## Tutorial interativo no primeiro acesso (RF05). Mostra um mini jogo da
## memória 2x2 (2 pares) para o jogador praticar virar/comparar cartas antes
## de ir pro tabuleiro de verdade — sem pontuação nem GameManager envolvidos,
## é só uma demonstração. Usa o mesmo verso e as mesmas fotos de animal do jogo
## (2 animais do nível Fácil, sorteados a cada rodada). Marca como visto no
## SaveManager e só aparece uma vez.

const CARD_SIZE := Vector2(110, 110)
const MISMATCH_REVEAL_SECONDS := 0.6
const RESHUFFLE_DELAY_SECONDS := 0.5
const PAIR_IDS := [0, 0, 1, 1]
## Mesmo verso das cartas do tabuleiro.
const CARD_BACK_TEXTURE := preload("res://assets/icons/cards/verso.svg")

@onready var grid: GridContainer = $Layout/CardGrid

var _buttons: Array[Button] = []
var _backs: Array[TextureRect] = []
var _icons: Array[TextureRect] = []
var _values: Array = []
var _pending_indices: Array[int] = []
var _matched: Array[int] = []


func _ready() -> void:
	_build_grid()


func _build_grid() -> void:
	for child in grid.get_children():
		child.queue_free()
	_buttons.clear()
	_backs.clear()
	_icons.clear()
	_pending_indices.clear()
	_matched.clear()
	_values = PAIR_IDS.duplicate()
	_values.shuffle()
	var animals: Array = MemoryCardIcons.pick(2, "facil")
	for i in _values.size():
		var btn := Button.new()
		btn.custom_minimum_size = CARD_SIZE
		btn.pivot_offset = CARD_SIZE / 2.0
		btn.theme_type_variation = &"CardButton"
		var back := TextureRect.new()
		back.texture = CARD_BACK_TEXTURE
		back.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		back.stretch_mode = TextureRect.STRETCH_SCALE
		back.anchor_right = 1.0
		back.anchor_bottom = 1.0
		back.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(back)
		var icon := TextureRect.new()
		icon.texture = load(animals[_values[i]])
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.anchor_right = 1.0
		icon.anchor_bottom = 1.0
		icon.offset_left = 6.0
		icon.offset_top = 6.0
		icon.offset_right = -6.0
		icon.offset_bottom = -6.0
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.visible = false
		btn.add_child(icon)
		btn.pressed.connect(_on_card_pressed.bind(i))
		grid.add_child(btn)
		_buttons.append(btn)
		_backs.append(back)
		_icons.append(icon)


func _reveal(index: int) -> void:
	_backs[index].visible = false
	_icons[index].visible = true


func _hide(index: int) -> void:
	_backs[index].visible = true
	_icons[index].visible = false


func _on_card_pressed(index: int) -> void:
	if _pending_indices.size() >= 2:
		return
	if _pending_indices.has(index) or _matched.has(index):
		return
	_reveal(index)
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
			await get_tree().create_timer(RESHUFFLE_DELAY_SECONDS + 0.8).timeout
			_build_grid()
	else:
		_wobble_incorrect(_buttons[a])
		_wobble_incorrect(_buttons[b])
		await get_tree().create_timer(MISMATCH_REVEAL_SECONDS).timeout
		_hide(a)
		_hide(b)
		_pending_indices.clear()


## Mesma "dancinha" suave do acerto no tabuleiro.
func _pop_correct(btn: Button) -> void:
	var tween := create_tween()
	tween.tween_property(btn, "scale", Vector2.ONE * 1.18, 0.14)
	for angle in [-8.0, 8.0, -6.0, 6.0, -3.0, 3.0, 0.0]:
		tween.tween_property(btn, "rotation_degrees", angle, 0.09)
	tween.tween_property(btn, "scale", Vector2.ONE, 0.16)


func _wobble_incorrect(btn: Button) -> void:
	var tween := create_tween()
	for angle in [-7.0, 7.0, -5.0, 5.0, 0.0]:
		tween.tween_property(btn, "rotation_degrees", angle, 0.07)


func _on_entendi_pressed() -> void:
	SaveManager.mark_tutorial_seen()
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
