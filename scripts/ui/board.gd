extends Control
## Cena do tabuleiro (RF02, RF03, RF06, RF13, RN01-RN04, RN06). Constrói a
## grade de cartas a partir de GameManager.board, reage aos sinais de
## pontuação/par/vitória com som (AudioManager) e uma animação curta e
## suave — nunca piscante, per RNF04 — controla o menu de pausa
## (continuar/reiniciar/sair) e o botão de dica.

const MIN_CARD_SIZE := 48.0
const MAX_CARD_SIZE := 96.0
const GRID_SEPARATION := 2.0
const GRID_SIDE_MARGIN := 32.0
## Margem do topo (offset_top do VBoxContainer) + folga.
const GRID_VERTICAL_MARGIN := 40.0
const MISMATCH_REVEAL_SECONDS := 0.6
## Dica (RF13): as 2 cartas do par ganham uma moldura amarela que pulsa suave
## por este tempo, sem mostrar o animal.
const HINT_HIGHLIGHT_SECONDS := 2.5
const HINT_FRAME_COLOR := Color("FFD23F")
const HINT_FRAME_WIDTH := 8
const HINT_PULSE_SECONDS := 0.6
const PRESS_SCALE := 0.92
const PRESS_ANIM_SECONDS := 0.08
const DISABLED_MODULATE := Color(1, 1, 1, 0.5)
## Verso das cartas (a face virada para baixo).
const CARD_BACK_TEXTURE := preload("res://assets/icons/cards/verso.svg")

@onready var score_value_label: Label = $VBoxContainer/ScoreGroup/ScoreValueLabel
@onready var grid: GridContainer = $VBoxContainer/GridScroll/GridCenter/CardGrid
@onready var pausa_button: Button = $VBoxContainer/Footer/PausaButton
@onready var dica_button: Button = $VBoxContainer/Footer/DicaButton
@onready var dica_count_label: Label = $VBoxContainer/Footer/DicaButton/Count
@onready var pause_overlay: Control = $PauseOverlay
@onready var win_overlay: Control = $WinOverlay
@onready var win_score_label: Label = $WinOverlay/Layout/ScoreLabel
@onready var win_time_label: Label = $WinOverlay/Layout/TimeLabel

var _buttons: Array[Button] = []
var _icons: Array[TextureRect] = []
var _backs: Array[TextureRect] = []
var _frames: Array[Panel] = []
var _hint_tween: Tween
var _pending_indices: Array[int] = []


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.match_found.connect(_on_match_found)
	GameManager.match_failed.connect(_on_match_failed)
	GameManager.game_won.connect(_on_game_won)
	pausa_button.pressed.connect(_on_pausa_pressed)
	dica_button.pressed.connect(_on_dica_pressed)
	for btn in [pausa_button, dica_button]:
		_update_pivot(btn)
		btn.resized.connect(_update_pivot.bind(btn))
		btn.button_down.connect(_on_image_button_down.bind(btn))
		btn.button_up.connect(_on_image_button_up.bind(btn))
	_build_grid()
	_on_score_changed(GameManager.score)
	_refresh_dica_button()


## Botões de ícone completo (imagem única exportada do Figma, sombra/halo já
## embutidos) não têm feedback visual nativo de "pressionado" — o Button por
## trás é transparente em todos os estados. Compensa com uma leve animação de
## escala, importante pro usuário idoso confirmar que o toque registrou.
func _update_pivot(btn: Button) -> void:
	btn.pivot_offset = btn.size / 2.0


func _on_image_button_down(btn: Button) -> void:
	var tween := create_tween()
	tween.tween_property(btn, "scale", Vector2.ONE * PRESS_SCALE, PRESS_ANIM_SECONDS)


func _on_image_button_up(btn: Button) -> void:
	var tween := create_tween()
	tween.tween_property(btn, "scale", Vector2.ONE, PRESS_ANIM_SECONDS)


## Mesma imagem única não escurece sozinha quando o Button fica disabled —
## sem isso o botão pareceria clicável mesmo quando não é.
func _set_image_button_enabled(btn: Button, enabled: bool) -> void:
	btn.disabled = not enabled
	btn.modulate = Color.WHITE if enabled else DISABLED_MODULATE


func _build_grid() -> void:
	for child in grid.get_children():
		child.queue_free()
	_buttons.clear()
	_icons.clear()
	_backs.clear()
	_frames.clear()
	_clear_hint()
	_pending_indices.clear()
	var columns := _columns_for(GameManager.board.size())
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", int(GRID_SEPARATION))
	grid.add_theme_constant_override("v_separation", int(GRID_SEPARATION))
	var card_size := _card_size_for(columns, ceili(GameManager.board.size() / float(columns)))
	var icon_paths: Array = GameManager.card_icons
	for i in GameManager.board.size():
		var btn := Button.new()
		btn.custom_minimum_size = card_size
		btn.pivot_offset = card_size / 2.0
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
		icon.texture = load(icon_paths[GameManager.board[i]])
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
		var frame := Panel.new()
		var frame_style := StyleBoxFlat.new()
		frame_style.bg_color = Color(0, 0, 0, 0)
		frame_style.border_color = HINT_FRAME_COLOR
		frame_style.set_border_width_all(HINT_FRAME_WIDTH)
		frame_style.set_corner_radius_all(8)
		frame.add_theme_stylebox_override("panel", frame_style)
		frame.anchor_right = 1.0
		frame.anchor_bottom = 1.0
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame.visible = false
		btn.add_child(frame)
		if GameManager.matched.has(i):
			btn.disabled = true
			back.visible = false
			icon.visible = true
		btn.pressed.connect(_on_card_pressed.bind(i))
		grid.add_child(btn)
		_buttons.append(btn)
		_icons.append(icon)
		_backs.append(back)
		_frames.append(frame)


## O lado da carta é o menor entre o que cabe na largura e o que cabe na altura
## que sobra depois do cabeçalho e do rodapé: assim o tabuleiro inteiro aparece
## sem rolar a tela. Só em telas muito baixas, onde as cartas ficariam abaixo do
## mínimo de toque (MIN_CARD_SIZE), a rolagem do GridScroll entra como reserva.
func _card_size_for(columns: int, rows: int) -> Vector2:
	var viewport: Vector2 = get_viewport_rect().size
	var avail_w: float = viewport.x - GRID_SIDE_MARGIN - GRID_SEPARATION * (columns - 1)
	var avail_h: float = viewport.y - _reserved_height() - GRID_SEPARATION * (rows - 1)
	var side: float = floor(min(avail_w / columns, avail_h / rows))
	side = clamp(side, MIN_CARD_SIZE, MAX_CARD_SIZE)
	return Vector2(side, side)


## Altura ocupada pelo que não é a grade: pontuação, espaçador, rodapé e as
## separações do VBoxContainer.
func _reserved_height() -> float:
	var box: VBoxContainer = $VBoxContainer
	var reserved := 0.0
	for child in box.get_children():
		if child != $VBoxContainer/GridScroll:
			reserved += child.get_combined_minimum_size().y
	reserved += box.get_theme_constant("separation") * (box.get_child_count() - 1)
	return reserved + GRID_VERTICAL_MARGIN


func _columns_for(card_count: int) -> int:
	match card_count:
		16:
			return 4
		30:
			return 5
		40:
			return 5
		_:
			return 4


func _reveal_card(index: int) -> void:
	_backs[index].visible = false
	_icons[index].visible = true
	_frames[index].visible = false


func _hide_card(index: int) -> void:
	_backs[index].visible = true
	_icons[index].visible = false


func _on_card_pressed(index: int) -> void:
	if _pending_indices.size() >= 2:
		return
	if _pending_indices.has(index) or GameManager.matched.has(index):
		return
	# Atualiza a UI e a lista de pendentes ANTES de chamar flip_card: quando
	# esta é a 2ª carta, flip_card resolve o par e emite match_found/
	# match_failed de forma síncrona, então os handlers precisam ver os 2
	# índices já registrados (senão o 2º card nunca volta a ficar oculto).
	_reveal_card(index)
	_pending_indices.append(index)
	if not GameManager.flip_card(index):
		_hide_card(index)
		_pending_indices.erase(index)


func _on_match_found(pair_id: int) -> void:
	AudioManager.play_correct()
	if pair_id >= 0 and pair_id < GameManager.card_icons.size():
		AudioManager.play_animal(GameManager.card_icons[pair_id])
	for i in _pending_indices:
		_buttons[i].disabled = true
		_pop_correct(_buttons[i])
	_pending_indices.clear()
	_refresh_dica_button()


func _on_match_failed() -> void:
	AudioManager.play_incorrect()
	var indices := _pending_indices.duplicate()
	for i in indices:
		_wobble_incorrect(_buttons[i])
	await get_tree().create_timer(MISMATCH_REVEAL_SECONDS).timeout
	for i in indices:
		_hide_card(i)
	GameManager.clear_pending_flip()
	_pending_indices.clear()
	_refresh_dica_button()


func _on_score_changed(new_score: int) -> void:
	score_value_label.text = str(new_score)
	_refresh_dica_button()


func _on_game_won() -> void:
	for btn in _buttons:
		btn.disabled = true
	_set_image_button_enabled(pausa_button, false)
	_set_image_button_enabled(dica_button, false)
	win_score_label.text = "Pontuação: %d" % GameManager.score
	win_time_label.text = "Tempo: %s" % TimeFormat.mmss(GameManager.elapsed_seconds)
	win_overlay.visible = true


## RF06: abre o menu de pausa. Pausar a árvore (get_tree().paused) já
## impede automaticamente os cliques nas cartas (Buttons comuns não
## processam input pausados) — só o overlay (process_mode ALWAYS) continua
## respondendo.
func _on_pausa_pressed() -> void:
	get_tree().paused = true
	pause_overlay.visible = true


func _on_continuar_pressed() -> void:
	get_tree().paused = false
	pause_overlay.visible = false


## RN06: reinicia a mesma dificuldade — zera progresso/cronômetro/pontuação
## e reembaralha. Usado tanto pelo "Reiniciar" da Pausa quanto pelo "Jogar
## novamente" da tela de Parabéns.
func _restart_game() -> void:
	GameManager.restart()
	_build_grid()
	_on_score_changed(GameManager.score)
	_set_image_button_enabled(pausa_button, true)
	get_tree().paused = false
	pause_overlay.visible = false
	win_overlay.visible = false


func _on_reiniciar_pressed() -> void:
	_restart_game()


func _on_jogar_novamente_pressed() -> void:
	_restart_game()


func _on_sair_pressed() -> void:
	get_tree().paused = false
	pause_overlay.visible = false
	win_overlay.visible = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


## RF13/RN04: revela temporariamente um par ainda não encontrado.
func _on_dica_pressed() -> void:
	var pair: Array = GameManager.use_hint()
	if pair.is_empty():
		return
	_refresh_dica_button()
	_clear_hint()
	var frames: Array[Panel] = []
	for i in pair:
		_frames[i].visible = true
		_frames[i].modulate.a = 1.0
		frames.append(_frames[i])
	# Pulsa de leve (só a opacidade da moldura, sem piscar forte).
	_hint_tween = create_tween().set_loops()
	for f in frames:
		_hint_tween.parallel().tween_property(f, "modulate:a", 0.45, HINT_PULSE_SECONDS)
	_hint_tween.chain()
	for f in frames:
		_hint_tween.parallel().tween_property(f, "modulate:a", 1.0, HINT_PULSE_SECONDS)
	await get_tree().create_timer(HINT_HIGHLIGHT_SECONDS).timeout
	for f in frames:
		if is_instance_valid(f):
			f.visible = false
	if _hint_tween != null and _hint_tween.is_valid():
		_hint_tween.kill()


## Apaga qualquer destaque de Dica em andamento.
func _clear_hint() -> void:
	if _hint_tween != null and _hint_tween.is_valid():
		_hint_tween.kill()
	for f in _frames:
		if is_instance_valid(f):
			f.visible = false


func _refresh_dica_button() -> void:
	var remaining: int = GameManager.MAX_HINTS - GameManager.hints_used
	dica_count_label.text = str(remaining)
	_set_image_button_enabled(dica_button, GameManager.can_use_hint())


## Feedback visual de acerto (RF03): um "pop" curto e suave, sem piscar.
func _pop_correct(btn: Button) -> void:
	var tween := create_tween()
	tween.tween_property(btn, "scale", Vector2(1.15, 1.15), 0.12)
	tween.tween_property(btn, "scale", Vector2.ONE, 0.12)


## Feedback visual de erro (RF03): um leve balanço, não punitivo (RNF04) —
## nada de flash vermelho nem tremor de tela inteira.
func _wobble_incorrect(btn: Button) -> void:
	var tween := create_tween()
	tween.tween_property(btn, "rotation_degrees", -6.0, 0.06)
	tween.tween_property(btn, "rotation_degrees", 6.0, 0.06)
	tween.tween_property(btn, "rotation_degrees", 0.0, 0.06)
