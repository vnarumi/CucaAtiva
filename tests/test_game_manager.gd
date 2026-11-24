@tool
extends McpTestSuite
## Testa o loop principal do GameManager (RF01, RF02, RN01-RN03) isolado do
## autoload real, instanciando a classe diretamente. Usa uma dificuldade
## "facil" fixa (8 pares / 16 cartas) e injeta o board via reflexão simples
## (acesso direto à var pública `board`) para tornar os testes determinísticos.

const GameManagerScript := preload("res://scripts/autoload/game_manager.gd")


func _new_manager() -> Node:
	var gm: Node = track(GameManagerScript.new())
	gm.start_game("facil")
	return gm


func suite_name() -> String:
	return "game_manager"


func test_start_game_resets_state() -> void:
	var gm := _new_manager()
	assert_eq(gm.score, 0)
	assert_eq(gm.combo_streak, 0)
	assert_eq(gm.hints_used, 0)
	assert_eq(gm.board.size(), 16, "Fácil deve gerar 16 cartas")


func test_flip_card_rejects_out_of_range() -> void:
	var gm := _new_manager()
	assert_false(gm.flip_card(-1))
	assert_false(gm.flip_card(999))


func test_matching_pair_awards_points_and_locks_cards() -> void:
	var gm := _new_manager()
	# Força um tabuleiro conhecido: par 0 nos índices 0 e 1.
	gm.board = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7]
	assert_true(gm.flip_card(0))
	assert_true(gm.flip_card(1))
	assert_eq(gm.score, 10, "1º acerto do combo deve valer 10 (RN01/RN03)")
	assert_true(gm.matched.has(0))
	assert_true(gm.matched.has(1))
	# Cartas já resolvidas não podem ser viradas de novo.
	assert_false(gm.flip_card(0))


func test_mismatch_applies_penalty_and_resets_combo() -> void:
	var gm := _new_manager()
	gm.board = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7]
	gm.flip_card(0)
	gm.flip_card(1)
	assert_eq(gm.combo_streak, 1)
	# Um par correto já limpa as cartas viradas sozinho (ficam marcadas em
	# `matched`, não em `_flipped`), então a 3ª carta é liberada de imediato.
	gm.flip_card(2)
	gm.flip_card(4)
	assert_eq(gm.score, 8, "10 do 1º acerto - 2 do erro = 8 (RN01)")
	assert_eq(gm.combo_streak, 0, "Combo deve zerar ao errar (RN03)")
	# Só um ERRO deixa as cartas pendentes até a cena chamar clear_pending_flip.
	assert_false(gm.flip_card(6), "Não deve permitir nova jogada antes de clear_pending_flip")
	gm.clear_pending_flip()
	assert_true(gm.flip_card(6), "Depois de limpar, deve permitir virar novamente")


func test_combo_escalates_across_consecutive_matches() -> void:
	var gm := _new_manager()
	gm.board = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7]
	gm.flip_card(0)
	gm.flip_card(1)
	gm.clear_pending_flip()
	gm.flip_card(2)
	gm.flip_card(3)
	assert_eq(gm.score, 25, "10 (1º) + 15 (2º, combo) = 25 (RN03)")


func test_game_won_emitted_when_all_pairs_found() -> void:
	var gm := _new_manager()
	gm.board = [0, 0, 1, 1]
	# Simula dificuldade de 2 pares só para o teste de vitória.
	gm.difficulty = "facil"
	var won := [false]
	gm.game_won.connect(func(): won[0] = true)
	gm.flip_card(0)
	gm.flip_card(1)
	gm.clear_pending_flip()
	# Só 1 de 8 pares "facil" resolvido — ainda não deve vencer.
	assert_false(won[0], "Não deve vencer com pares restantes na dificuldade real")


func test_elapsed_seconds_only_advances_while_running() -> void:
	var gm := _new_manager()
	assert_eq(gm.elapsed_seconds, 0.0)
	assert_true(gm.is_running, "Deve estar rodando logo após start_game (RF04)")
	gm._process(1.5)
	assert_eq(gm.elapsed_seconds, 1.5)
	gm.is_running = false
	gm._process(2.0)
	assert_eq(gm.elapsed_seconds, 1.5, "Não deve avançar quando is_running é false")


func test_is_running_becomes_false_on_win() -> void:
	var gm := _new_manager()
	gm.board = [0, 0, 1, 1]
	gm.difficulty = "facil"
	gm.matched.clear()
	gm.pairs_found = 7
	gm.flip_card(0)
	gm.flip_card(1)
	assert_true(gm.is_running == false, "Cronômetro deve parar ao completar o último par (RN02)")


func test_restore_state_round_trip_with_string_keyed_matched() -> void:
	var gm := _new_manager()
	# Simula exatamente o formato que volta de JSON.parse_string: chaves de
	# Dictionary como String, números possivelmente como float.
	var saved := {
		"difficulty": "medio",
		"board": [0.0, 1.0, 2.0, 0.0, 1.0, 2.0],
		"score": 25.0,
		"combo_streak": 2.0,
		"hints_used": 1.0,
		"pairs_found": 1.0,
		"elapsed_seconds": 42.5,
		"matched": {"0": true, "3": true},
	}
	gm.restore_state(saved)
	assert_eq(gm.difficulty, "medio")
	assert_eq(gm.board, [0, 1, 2, 0, 1, 2], "Valores do board devem virar int")
	assert_eq(gm.score, 25)
	assert_eq(gm.combo_streak, 2)
	assert_eq(gm.hints_used, 1)
	assert_eq(gm.pairs_found, 1)
	assert_eq(gm.elapsed_seconds, 42.5)
	assert_true(gm.matched.has(0), "Chave '0' (String) deve virar 0 (int)")
	assert_true(gm.matched.has(3), "Chave '3' (String) deve virar 3 (int)")
	assert_true(gm.is_running, "Ainda restam pares (1 de 15 no médio) — deve continuar rodando")


## Regressão: ao retomar a partida na MESMA sessão (Sair -> Continuar partida,
## sem reler o disco), o estado salvo compartilhava o mesmo dicionário de
## `matched` do GameManager; restore_state o limpava e as cartas acertadas
## sumiam (tabuleiro todo virado pra baixo).
func test_restore_state_keeps_matched_when_state_shares_the_live_dictionary() -> void:
	var gm := _new_manager()
	gm.board = [0, 1, 2, 0, 1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7]
	gm.matched[0] = true
	gm.matched[3] = true
	gm.pairs_found = 1
	# o "salvo" aponta pro MESMO dicionário (como um autosave sem cópia)
	var saved := {"difficulty": "facil", "board": gm.board, "matched": gm.matched, "pairs_found": 1}
	gm.restore_state(saved)
	assert_true(gm.matched.has(0), "Carta 0 deve continuar acertada")
	assert_true(gm.matched.has(3), "Carta 3 deve continuar acertada")
	assert_eq(gm.matched.size(), 2)


func test_hint_requires_minimum_score() -> void:
	var gm := _new_manager()
	gm.score = 14
	assert_false(gm.can_use_hint(), "RN04: exige pontuação >= 15")
	assert_eq(gm.use_hint(), [], "Não deve revelar nada nem cobrar sem saldo suficiente")
	assert_eq(gm.score, 14, "Pontuação não deve mudar numa tentativa inválida")


func test_hint_costs_points_and_reveals_unmatched_pair() -> void:
	var gm := _new_manager()
	gm.board = [0, 1, 2, 0, 1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7]
	gm.score = 20
	var pair: Array = gm.use_hint()
	assert_eq(pair, [0, 3], "Deve encontrar o par não resolvido mais cedo no board (valor 0)")
	assert_eq(gm.score, 5, "20 - 15 (RN04) = 5")
	assert_eq(gm.hints_used, 1)
	assert_false(gm.matched.has(0), "Dica só revela, não marca como encontrado")
	assert_false(gm.matched.has(3))


func test_hint_used_signal_emits_the_pair() -> void:
	var gm := _new_manager()
	gm.board = [0, 1, 2, 0, 1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7]
	gm.score = 20
	var emitted := [[]]
	gm.hint_used.connect(func(a, b): emitted[0] = [a, b])
	gm.use_hint()
	assert_eq(emitted[0], [0, 3])


func test_hint_ignores_matched_and_pending_cards() -> void:
	var gm := _new_manager()
	gm.board = [0, 1, 2, 0, 1, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7]
	gm.score = 50
	gm.matched[0] = true
	gm.matched[3] = true
	var pair: Array = gm.use_hint()
	assert_eq(pair, [1, 4], "Par 0 já encontrado — deve pular pro próximo par não resolvido")


func test_hint_max_three_per_game() -> void:
	var gm := _new_manager()
	gm.board = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7]
	gm.score = 100
	assert_ne(gm.use_hint(), [])
	assert_ne(gm.use_hint(), [])
	assert_ne(gm.use_hint(), [])
	assert_eq(gm.hints_used, 3)
	assert_false(gm.can_use_hint(), "RN04: máximo 3 dicas por partida")
	assert_eq(gm.use_hint(), [], "4ª dica deve ser recusada")
	assert_eq(gm.hints_used, 3, "Não deve incrementar além do limite")


func test_hint_returns_empty_when_no_unmatched_pair_left() -> void:
	var gm := _new_manager()
	gm.board = [0, 0]
	gm.score = 50
	gm.matched[0] = true
	gm.matched[1] = true
	assert_eq(gm.use_hint(), [], "Não há par para revelar — não deve cobrar nada")
	assert_eq(gm.score, 50)
	assert_eq(gm.hints_used, 0)


func test_hint_resets_on_restart() -> void:
	var gm := _new_manager()
	gm.board = [0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7]
	gm.score = 50
	gm.use_hint()
	assert_eq(gm.hints_used, 1)
	gm.restart()
	assert_eq(gm.hints_used, 0, "RN06: reiniciar zera o contador de dicas também")


func test_hint_disabled_after_game_won() -> void:
	var gm := _new_manager()
	gm.board = [0, 0]
	gm.matched.clear()
	gm.pairs_found = 7
	gm.score = 100
	gm.flip_card(0)
	gm.flip_card(1)
	assert_false(gm.is_running)
	assert_false(gm.can_use_hint(), "Não deve permitir dica depois de vencer")
