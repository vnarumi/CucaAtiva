extends Node
## Fase 1-3: loop principal da partida (RF01, RF02, RN01-RN03) + cronômetro
## progressivo (RF04, RNF04 — nunca regressivo) + restauração de estado
## salvo (RF08, usado pelo SaveManager).

signal score_changed(new_score: int)
signal match_found(pair_id: int)
signal match_failed
signal game_won
## RF13: emitido quando uma dica é usada com sucesso, com os 2 índices do
## par revelado (para a cena mostrar/esconder de novo).
signal hint_used(a: int, b: int)

## RN04: custo em pontos e limite de dicas por partida.
const HINT_COST := 15
const MAX_HINTS := 3

var difficulty: String = ""
var score: int = 0
var combo_streak: int = 0
var hints_used: int = 0

## Array de ids de carta (2x por par), na ordem embaralhada do tabuleiro atual.
var board: Array = []
## Caminhos dos ícones sorteados para a partida (índice = id do par). Guardado
## aqui (e no save) para que retomar a partida mostre as mesmas figuras.
var card_icons: Array = []
## Índices do board já resolvidos como par encontrado.
var matched: Dictionary = {}
## Nº de pares já encontrados na partida atual (RN02).
var pairs_found: int = 0
## Até 2 índices atualmente virados, aguardando resolução ou limpeza pela cena.
var _flipped: Array = []

## Cronômetro da partida (RF04) — sempre progressivo (RNF04), nunca regressivo.
var elapsed_seconds: float = 0.0
## true enquanto há uma partida ativa e não vencida — controla se o
## cronômetro avança e é usado por SaveManager para decidir se há algo para
## retomar (RF08).
var is_running: bool = false


func _process(delta: float) -> void:
	if is_running:
		elapsed_seconds += delta


## RF01: inicia uma partida nova na dificuldade dada ("facil"/"medio"/"dificil").
func start_game(new_difficulty: String) -> void:
	difficulty = new_difficulty
	score = 0
	combo_streak = 0
	hints_used = 0
	matched.clear()
	pairs_found = 0
	_flipped.clear()
	elapsed_seconds = 0.0
	is_running = true
	board = BoardGenerator.generate(difficulty)
	card_icons = MemoryCardIcons.pick(int(board.size() / 2.0), difficulty)
	score_changed.emit(score)


## RN06: reinicia a mesma dificuldade, zerando progresso/pontuação e reembaralhando.
func restart() -> void:
	start_game(difficulty)


## RF08: repõe um estado salvo (de SaveManager.in_progress) sem reembaralhar
## nem zerar nada — usado para retomar uma partida interrompida. `state`
## vem de JSON (chaves de Dictionary viram String, números viram float),
## então os tipos são normalizados aqui.
func restore_state(state: Dictionary) -> void:
	difficulty = str(state.get("difficulty", ""))
	board = []
	for v in state.get("board", []):
		board.append(int(v))
	card_icons = []
	for p in state.get("card_icons", []):
		card_icons.append(str(p))
	# Saves antigos não têm os ícones (ou apontam pra fotos que não existem
	# mais): sorteia de novo (as figuras mudam só nesse caso).
	var icons_ok := card_icons.size() >= int(board.size() / 2.0)
	for p in card_icons:
		if not ResourceLoader.exists(p):
			icons_ok = false
	if not icons_ok:
		card_icons = MemoryCardIcons.pick(int(board.size() / 2.0), difficulty)
	score = int(state.get("score", 0))
	combo_streak = int(state.get("combo_streak", 0))
	hints_used = int(state.get("hints_used", 0))
	pairs_found = int(state.get("pairs_found", 0))
	elapsed_seconds = float(state.get("elapsed_seconds", 0.0))
	matched.clear()
	for k in state.get("matched", {}).keys():
		matched[int(k)] = true
	_flipped.clear()
	var total_pairs := BoardGenerator.pairs_for_difficulty(difficulty)
	is_running = difficulty != "" and not ScoreRules.is_won(pairs_found, total_pairs)
	score_changed.emit(score)


## RF02: tenta virar a carta em `index`. Retorna false se a jogada for inválida
## (índice fora do tabuleiro, carta já resolvida/virada, ou já há 2 viradas
## aguardando resolução — a cena deve chamar clear_pending_flip() antes de
## permitir uma nova jogada).
func flip_card(index: int) -> bool:
	if index < 0 or index >= board.size():
		return false
	if matched.has(index) or _flipped.has(index):
		return false
	if _flipped.size() >= 2:
		return false
	_flipped.append(index)
	if _flipped.size() == 2:
		_resolve_flip()
	return true


## Limpa as 2 cartas viradas sem par depois que a cena terminar de mostrar o
## feedback de erro (RF03) e virá-las de volta para baixo.
func clear_pending_flip() -> void:
	_flipped.clear()


func _resolve_flip() -> void:
	var a: int = _flipped[0]
	var b: int = _flipped[1]
	if board[a] == board[b]:
		matched[a] = true
		matched[b] = true
		pairs_found += 1
		score = ScoreRules.apply_delta(score, ScoreRules.points_for_match(combo_streak))
		combo_streak += 1
		_flipped.clear()
		score_changed.emit(score)
		match_found.emit(board[a])
		var total_pairs := BoardGenerator.pairs_for_difficulty(difficulty)
		if ScoreRules.is_won(pairs_found, total_pairs):
			is_running = false
			game_won.emit()
	else:
		score = ScoreRules.apply_delta(score, ScoreRules.points_for_mismatch())
		combo_streak = 0
		score_changed.emit(score)
		match_failed.emit()


## RN04: true se uma dica pode ser usada agora (partida ativa, pontuação
## suficiente, limite de dicas não atingido).
func can_use_hint() -> bool:
	return is_running and hints_used < MAX_HINTS and score >= HINT_COST


## RF13/RN04: gasta uma dica, se possível, e retorna os 2 índices de um par
## ainda não encontrado (nem virado no momento) para a cena revelar
## temporariamente. Retorna [] sem cobrar nada se não for possível usar uma
## dica agora ou se não houver par disponível para revelar.
func use_hint() -> Array:
	if not can_use_hint():
		return []
	var pair := _find_unmatched_pair()
	if pair.is_empty():
		return []
	hints_used += 1
	score = ScoreRules.apply_delta(score, -HINT_COST)
	score_changed.emit(score)
	hint_used.emit(pair[0], pair[1])
	return pair


func _find_unmatched_pair() -> Array:
	var seen: Dictionary = {}
	for i in board.size():
		if matched.has(i) or _flipped.has(i):
			continue
		var value = board[i]
		if seen.has(value):
			return [seen[value], i]
		seen[value] = i
	return []
