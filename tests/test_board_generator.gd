@tool
extends McpTestSuite
## Testa BoardGenerator (RF01) — res://scripts/core/board_generator.gd.

func suite_name() -> String:
	return "board_generator"


func test_pairs_for_difficulty() -> void:
	assert_eq(BoardGenerator.pairs_for_difficulty("facil"), 8)
	assert_eq(BoardGenerator.pairs_for_difficulty("medio"), 15)
	assert_eq(BoardGenerator.pairs_for_difficulty("dificil"), 20)
	assert_eq(BoardGenerator.pairs_for_difficulty("desconhecida"), 0)


func test_generate_has_correct_card_count() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var board := BoardGenerator.generate("facil", rng)
	assert_eq(board.size(), 16, "Fácil deve ter 16 cartas (8 pares)")


func test_generate_each_id_appears_exactly_twice() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var board: Array = BoardGenerator.generate("medio", rng)
	var counts := {}
	for id in board:
		counts[id] = counts.get(id, 0) + 1
	assert_eq(counts.size(), 15, "Médio deve ter 15 ids distintos")
	for id in counts:
		assert_eq(counts[id], 2, "Cada id deve aparecer exatamente 2 vezes (par)")


func test_generate_unknown_difficulty_returns_empty() -> void:
	var board := BoardGenerator.generate("lendario")
	assert_eq(board.size(), 0)


func test_generate_is_shuffled_not_sorted() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var board: Array = BoardGenerator.generate("dificil", rng)
	var sorted_copy := board.duplicate()
	sorted_copy.sort()
	assert_ne(board, sorted_copy, "Embaralhado não deveria coincidir com a ordem crescente")
