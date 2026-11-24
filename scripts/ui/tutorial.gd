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
@onready var instruction_label: Label = $Layout/InstructionCard/InstructionLabel
@onready var _entendi_wrapper: Control = $Layout/EntendiWrapper

## Texto que substitui a instrução quando o exercício termina.
const INSTRUCTION_DONE := "Muito bem! Agora toque em “Entendi!” para começar a jogar."
## Destaque do botão "Entendi!": balanço suave, ~1,4 s por ciclo, nunca piscante.
const ENTENDI_PULSE_SCALE := 1.08
const ENTENDI_WOBBLE_DEGREES := 3.0
const ENTENDI_STEP_SECONDS := 0.18
const ENTENDI_PAUSE_SECONDS := 0.9

var _entendi_tween: Tween

var _buttons: Array[Button] = []
var _backs: Array[TextureRect] = []
var _icons: Array[TextureRect] = []
var _values: Array = []
var _pending_indices: Array[int] = []
var _matched: Array[int] = []


func _ready() -> void:
	_build_grid()
	_fit_instruction_card()


## Com a letra grande a instrução ocupa mais linhas: o cartão cresce pra caber
## o texto inteiro (senão ele vazaria pra fora do cartão).
func _fit_instruction_card() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var card: Control = $Layout/InstructionCard
	var label: Label = $Layout/InstructionCard/InstructionLabel
	card.custom_minimum_size.y = max(card.custom_minimum_size.y, label.get_combined_minimum_size().y + 40.0)


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
			_highlight_entendi()
			await get_tree().create_timer(RESHUFFLE_DELAY_SECONDS + 0.8).timeout
			_build_grid()
	else:
		_wobble_incorrect(_buttons[a])
		_wobble_incorrect(_buttons[b])
		await get_tree().create_timer(MISMATCH_REVEAL_SECONDS).timeout
		_hide(a)
		_hide(b)
		_pending_indices.clear()


## Quando a pessoa completa o exercício, o botão "Entendi!" balança e pulsa de
## leve (sem piscar) e o texto de cima diz o que fazer em seguida — antes a tela
## ficava parada e não ficava claro que o tutorial já tinha acabado.
func _highlight_entendi() -> void:
	if _entendi_tween != null and _entendi_tween.is_valid():
		return  # já está em destaque
	instruction_label.text = INSTRUCTION_DONE
	_fit_instruction_card()
	_entendi_wrapper.pivot_offset = _entendi_wrapper.size / 2.0
	_entendi_tween = create_tween().set_loops()
	_entendi_tween.set_parallel(true)
	_entendi_tween.tween_property(_entendi_wrapper, "scale", Vector2.ONE * ENTENDI_PULSE_SCALE, ENTENDI_STEP_SECONDS)
	_entendi_tween.tween_property(_entendi_wrapper, "rotation_degrees", -ENTENDI_WOBBLE_DEGREES, ENTENDI_STEP_SECONDS)
	_entendi_tween.chain().tween_property(_entendi_wrapper, "rotation_degrees", ENTENDI_WOBBLE_DEGREES, ENTENDI_STEP_SECONDS)
	_entendi_tween.chain().tween_property(_entendi_wrapper, "scale", Vector2.ONE, ENTENDI_STEP_SECONDS)
	_entendi_tween.parallel().tween_property(_entendi_wrapper, "rotation_degrees", 0.0, ENTENDI_STEP_SECONDS)
	_entendi_tween.chain().tween_interval(ENTENDI_PAUSE_SECONDS)


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
