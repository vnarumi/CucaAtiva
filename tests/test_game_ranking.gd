@tool
extends McpTestSuite
## Testa GameRanking — res://scripts/core/game_ranking.gd.

func suite_name() -> String:
	return "game_ranking"


func _h(difficulty: String, score: int, time_seconds: float) -> Dictionary:
	return {"difficulty": difficulty, "score": score, "time_seconds": time_seconds}


func test_only_game_is_first() -> void:
	var history := [_h("facil", 100, 60.0)]
	var p := GameRanking.position(history, "facil", 100, 60.0)
	assert_eq(p["rank"], 1)
	assert_eq(p["total"], 1)


func test_higher_score_ranks_first() -> void:
	var history := [_h("facil", 80, 50.0), _h("facil", 120, 70.0), _h("facil", 100, 60.0)]
	assert_eq(GameRanking.position(history, "facil", 120, 70.0)["rank"], 1)
	assert_eq(GameRanking.position(history, "facil", 100, 60.0)["rank"], 2)
	assert_eq(GameRanking.position(history, "facil", 80, 50.0)["rank"], 3)


func test_tie_on_score_is_broken_by_faster_time() -> void:
	var history := [_h("medio", 100, 90.0), _h("medio", 100, 60.0)]
	assert_eq(GameRanking.position(history, "medio", 100, 60.0)["rank"], 1)
	assert_eq(GameRanking.position(history, "medio", 100, 90.0)["rank"], 2)


func test_other_levels_do_not_count() -> void:
	var history := [_h("dificil", 999, 10.0), _h("facil", 100, 60.0)]
	var p := GameRanking.position(history, "facil", 100, 60.0)
	assert_eq(p["rank"], 1)
	assert_eq(p["total"], 1)


func test_identical_games_do_not_pass_each_other() -> void:
	var history := [_h("facil", 100, 60.0), _h("facil", 100, 60.0)]
	var p := GameRanking.position(history, "facil", 100, 60.0)
	assert_eq(p["rank"], 1)
	assert_eq(p["total"], 2)


func test_badge_parts() -> void:
	assert_eq(GameRanking.parts(1, 1, "facil"), ["1º LUGAR", "Você abriu o ranking do Fácil!"])
	assert_eq(GameRanking.parts(1, 6, "dificil"), ["1º LUGAR", "Novo recorde no Difícil!"])
	assert_eq(GameRanking.parts(3, 8, "medio"), ["3º LUGAR", "entre 8 partidas no Médio"])


func test_messages_are_positive() -> void:
	assert_eq(GameRanking.message(1, 1, "facil"), "Você abriu o ranking do Fácil: 1º lugar!")
	assert_eq(GameRanking.message(1, 5, "dificil"), "Novo recorde! 1º lugar no ranking do Difícil!")
	assert_eq(GameRanking.message(3, 8, "medio"), "Você ficou em 3º lugar entre 8 partidas no Médio.")
