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
const MISMATCH_REVEAL_SECONDS := 0.6
const HINT_REVEAL_SECONDS := 1.5

@onready var score_label: Label = $VBoxContainer/Header/ScoreLabel
@onready var grid: GridContainer = $VBoxContainer/CardGrid
@onready var pausa_button: Button = $VBoxContainer/Header/PausaButton
@onready var dica_button: Button = $VBoxContainer/Header/DicaButton
@onready var dica_count_label: Label = $VBoxContainer/Header/DicaButton/Count
@onready var pause_overlay: Control = $PauseOverlay

var _buttons: Array[Button] = []
var _pending_indices: Array[int] = []


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.match_found.connect(_on_match_found)
	GameManager.match_failed.connect(_on_match_failed)
	GameManager.game_won.connect(_on_game_won)
	pausa_button.pressed.connect(_on_pausa_pressed)
	dica_button.pressed.connect(_on_dica_pressed)
	_build_grid()
	_on_score_changed(GameManager.score)
	_refresh_dica_button()


func _build_grid() -> void:
	for child in grid.get_children():
		child.queue_free()
	_buttons.clear()
	_pending_indices.clear()
	var columns := _columns_for(GameManager.board.size())
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", int(GRID_SEPARATION))
	grid.add_theme_constant_override("v_separation", int(GRID_SEPARATION))
	var card_size := _card_size_for(columns)
	for i in GameManager.board.size():
		var btn := Button.new()
		btn.custom_minimum_size = card_size
		btn.pivot_offset = card_size / 2.0
		btn.theme_type_variation = &"CardButton"
		btn.text = "?"
		if GameManager.matched.has(i):
			btn.disabled = true
		btn.pressed.connect(_on_card_pressed.bind(i))
		grid.add_child(btn)
		_buttons.append(btn)


func _card_size_for(columns: int) -> Vector2:
	var viewport_width: float = get_viewport_rect().size.x
	var available: float = viewport_width - GRID_SIDE_MARGIN - GRID_SEPARATION * (columns - 1)
	var side: float = clamp(floor(available / columns), MIN_CARD_SIZE, MAX_CARD_SIZE)
	return Vector2(side, side)


func _columns_for(card_count: int) -> int:
	match card_count:
		16:
			return 4
		30:
			return 6
		40:
			return 8
		_:
			return 4


func _on_card_pressed(index: int) -> void:
	if _pending_indices.size() >= 2:
		return
	if _pending_indices.has(index) or GameManager.matched.has(index):
		return
	# Atualiza a UI e a lista de pendentes ANTES de chamar flip_card: quando
	# esta é a 2ª carta, flip_card resolve o par e emite match_found/
	# match_failed de forma síncrona, então os handlers precisam ver os 2
	# índices já registrados (senão o 2º card nunca volta a ficar oculto).
	_buttons[index].text = str(GameManager.board[index])
	_pending_indices.append(index)
	if not GameManager.flip_card(index):
		_buttons[index].text = "?"
		_pending_indices.erase(index)


func _on_match_found(_pair_id: int) -> void:
	AudioManager.play_correct()
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
		_buttons[i].text = "?"
	GameManager.clear_pending_flip()
	_pending_indices.clear()
	_refresh_dica_button()


func _on_score_changed(new_score: int) -> void:
	score_label.text = "Pontuação: %d" % new_score
	_refresh_dica_button()


func _on_game_won() -> void:
	score_label.text = "Parabéns! Pontuação final: %d" % GameManager.score
	for btn in _buttons:
		btn.disabled = true
	pausa_button.disabled = true
	dica_button.disabled = true


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
## e reembaralha.
func _on_reiniciar_pressed() -> void:
	GameManager.restart()
	_build_grid()
	_on_score_changed(GameManager.score)
	pausa_button.disabled = false
	get_tree().paused = false
	pause_overlay.visible = false


func _on_sair_pressed() -> void:
	get_tree().paused = false
	pause_overlay.visible = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


## RF13/RN04: revela temporariamente um par ainda não encontrado.
func _on_dica_pressed() -> void:
	var pair: Array = GameManager.use_hint()
	if pair.is_empty():
		return
	_refresh_dica_button()
	for i in pair:
		_buttons[i].text = str(GameManager.board[i])
	await get_tree().create_timer(HINT_REVEAL_SECONDS).timeout
	for i in pair:
		# Só esconde de novo se o jogador não tiver virado essa carta "pra
		# valer" nesse meio-tempo (aí ela já está pendente/resolvida).
		if not GameManager.matched.has(i) and not _pending_indices.has(i):
			_buttons[i].text = "?"


func _refresh_dica_button() -> void:
	var remaining: int = GameManager.MAX_HINTS - GameManager.hints_used
	dica_count_label.text = str(remaining)
	dica_button.disabled = not GameManager.can_use_hint()


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
