@tool
extends McpTestSuite
## Testa ScoreRules (RN01, RN02, RN03) — res://scripts/core/score_rules.gd.

func suite_name() -> String:
	return "score_rules"


func test_first_match_gives_base_points() -> void:
	assert_eq(ScoreRules.points_for_match(0), 10, "1º acerto do combo deve valer 10")


func test_combo_escalation() -> void:
	assert_eq(ScoreRules.points_for_match(1), 15, "2º acerto consecutivo deve valer 15")
	assert_eq(ScoreRules.points_for_match(2), 20, "3º acerto consecutivo deve valer 20")
	assert_eq(ScoreRules.points_for_match(3), 25, "4º acerto consecutivo deve valer 25")


func test_mismatch_penalty() -> void:
	assert_eq(ScoreRules.points_for_mismatch(), -2, "Erro deve custar 2 pontos")


func test_score_floor_at_zero() -> void:
	assert_eq(ScoreRules.apply_delta(1, -2), 0, "Pontuação nunca deve ficar negativa")
	assert_eq(ScoreRules.apply_delta(0, -2), 0, "Pontuação já em 0 permanece em 0")


func test_score_accumulates_normally_above_floor() -> void:
	assert_eq(ScoreRules.apply_delta(10, 15), 25, "Soma normal acima do piso não deve ser afetada")


func test_win_condition() -> void:
	assert_false(ScoreRules.is_won(7, 8), "Não deve vencer com pares faltando")
	assert_true(ScoreRules.is_won(8, 8), "Deve vencer ao encontrar todos os pares")
	assert_false(ScoreRules.is_won(0, 0), "Zero pares totais nunca é uma vitória válida")
