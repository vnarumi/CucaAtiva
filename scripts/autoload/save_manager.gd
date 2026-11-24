extends Node
## Fase 3: persistência (RF04, RF07, RF08, RN05). Histórico de partidas
## vencidas + autosave do estado em andamento, em user://save_data.json.

const DEFAULT_SAVE_PATH := "user://save_data.json"

## Caminho do arquivo de save — var (não const) para poder ser trocado por um
## caminho temporário nos testes, sem tocar no save real do jogador.
var save_path: String = DEFAULT_SAVE_PATH

var history: Array = []
var in_progress: Dictionary = {}
## RF05: tutorial já foi mostrado nesta instalação (mostrado só uma vez).
var seen_tutorial: bool = false


func _ready() -> void:
	load_data()
	GameManager.game_won.connect(_on_game_won)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED \
			or what == NOTIFICATION_APPLICATION_FOCUS_OUT \
			or what == NOTIFICATION_WM_CLOSE_REQUEST:
		autosave_in_progress()


## Lê o save do disco (se existir) para `history`/`in_progress`. Se o
## arquivo não existir ou estiver corrompido, começa com estado vazio (não é
## um erro — é o caso normal na primeira execução do jogo).
func load_data() -> void:
	history = []
	in_progress = {}
	seen_tutorial = false
	if not FileAccess.file_exists(save_path):
		return
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	history = parsed.get("history", [])
	in_progress = parsed.get("in_progress", {})
	seen_tutorial = parsed.get("seen_tutorial", false)


func _write() -> void:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify({
		"history": history,
		"in_progress": in_progress,
		"seen_tutorial": seen_tutorial,
	}))
	file.close()


## RF05: marca o tutorial como já mostrado, para não aparecer de novo.
func mark_tutorial_seen() -> void:
	seen_tutorial = true
	_write()


## RN05: histórico (RF07) só é gravado em vitória — partidas abandonadas,
## reiniciadas ou pausadas nunca chegam aqui, pois esse método só roda em
## resposta ao sinal game_won.
func _on_game_won() -> void:
	add_history_entry(GameManager.difficulty, GameManager.score, GameManager.elapsed_seconds)
	clear_in_progress()


func add_history_entry(difficulty: String, score: int, time_seconds: float) -> void:
	history.append({
		"difficulty": difficulty,
		"score": score,
		"time_seconds": time_seconds,
		"date": Time.get_datetime_string_from_system(),
	})
	_write()


## RF08: salva o estado da partida em andamento para recuperação após
## fechamento inesperado/chamada — disparado automaticamente ao perder
## foco/pausar/fechar (ver _notification), e pode ser chamado manualmente.
func autosave_in_progress() -> void:
	if GameManager.difficulty == "" or not GameManager.is_running:
		return
	# Cópias (duplicate), não referências: senão `in_progress` e o estado vivo do
	# GameManager compartilhariam a mesma lista/dicionário, e retomar a partida
	# (que limpa o estado vivo) apagaria também o que acabou de ser salvo.
	in_progress = {
		"difficulty": GameManager.difficulty,
		"board": GameManager.board.duplicate(),
		"card_icons": GameManager.card_icons.duplicate(),
		"score": GameManager.score,
		"combo_streak": GameManager.combo_streak,
		"hints_used": GameManager.hints_used,
		"matched": GameManager.matched.duplicate(),
		"pairs_found": GameManager.pairs_found,
		"elapsed_seconds": GameManager.elapsed_seconds,
	}
	_write()


func has_in_progress() -> bool:
	return not in_progress.is_empty()


func clear_in_progress() -> void:
	in_progress = {}
	_write()


## Retoma a partida salva (RF08) de volta no GameManager, se houver uma.
## Retorna false sem efeito colateral se não há nada para retomar.
func resume_in_progress() -> bool:
	if not has_in_progress():
		return false
	GameManager.restore_state(in_progress)
	return true
