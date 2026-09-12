@tool
extends McpTestSuite
## Testa a persistência pura de SaveManager (RF04, RF07, RN05) —
## res://scripts/autoload/save_manager.gd. autosave_in_progress()/
## _on_game_won() dependem do autoload GameManager real, que só existe de
## fato com o jogo RODANDO (dentro do editor parado ele é um placeholder,
## sem estado) — esses dois métodos são verificados por smoke test manual
## via project_run + game_eval, não aqui. Aqui testamos load/save/
## histórico/in_progress isoladamente, manipulando os dicionários direto.

const SaveManagerScript := preload("res://scripts/autoload/save_manager.gd")
const TEMP_SAVE_PATH := "user://test_save_manager_tmp.json"


func suite_name() -> String:
	return "save_manager"


func _new_save_manager() -> Node:
	var sm: Node = track(SaveManagerScript.new())
	sm.save_path = TEMP_SAVE_PATH
	sm.load_data()
	return sm


func _delete_temp_file() -> void:
	if FileAccess.file_exists(TEMP_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP_SAVE_PATH))


func setup() -> void:
	_delete_temp_file()


func teardown() -> void:
	_delete_temp_file()


func test_missing_file_gives_empty_state() -> void:
	var sm := _new_save_manager()
	assert_eq(sm.history, [])
	assert_eq(sm.in_progress, {})
	assert_false(sm.has_in_progress())


func test_add_history_entry_persists_and_reloads() -> void:
	var sm := _new_save_manager()
	sm.add_history_entry("facil", 40, 12.5)
	var sm2 := _new_save_manager()
	assert_eq(sm2.history.size(), 1)
	assert_eq(sm2.history[0]["difficulty"], "facil")
	assert_eq(sm2.history[0]["score"], 40)
	assert_eq(sm2.history[0]["time_seconds"], 12.5)


func test_add_history_entry_appends_without_losing_previous() -> void:
	var sm := _new_save_manager()
	sm.add_history_entry("facil", 10, 5.0)
	sm.add_history_entry("medio", 20, 8.0)
	var sm2 := _new_save_manager()
	assert_eq(sm2.history.size(), 2)


func test_in_progress_persists_and_reloads() -> void:
	var sm := _new_save_manager()
	sm.in_progress = {"difficulty": "dificil", "score": 55}
	sm._write()
	assert_true(sm.has_in_progress())
	var sm2 := _new_save_manager()
	assert_true(sm2.has_in_progress())
	assert_eq(sm2.in_progress["difficulty"], "dificil")
	assert_eq(sm2.in_progress["score"], 55)


func test_clear_in_progress_empties_state_and_persists() -> void:
	var sm := _new_save_manager()
	sm.in_progress = {"difficulty": "facil"}
	sm._write()
	sm.clear_in_progress()
	assert_false(sm.has_in_progress())
	var sm2 := _new_save_manager()
	assert_false(sm2.has_in_progress(), "clear_in_progress deve persistir, não só em memória")


func test_resume_in_progress_returns_false_when_nothing_saved() -> void:
	var sm := _new_save_manager()
	assert_false(sm.resume_in_progress())


func test_history_write_does_not_touch_in_progress() -> void:
	var sm := _new_save_manager()
	sm.in_progress = {"difficulty": "medio"}
	sm._write()
	sm.add_history_entry("facil", 30, 9.0)
	assert_true(sm.has_in_progress(), "add_history_entry não deve mexer no autosave separado (RF07 vs RF08)")


func test_seen_tutorial_defaults_to_false() -> void:
	var sm := _new_save_manager()
	assert_false(sm.seen_tutorial)


func test_mark_tutorial_seen_persists() -> void:
	var sm := _new_save_manager()
	sm.mark_tutorial_seen()
	assert_true(sm.seen_tutorial)
	var sm2 := _new_save_manager()
	assert_true(sm2.seen_tutorial, "RF05: não deve mostrar o tutorial de novo após marcado")
