@tool
extends McpTestSuite
## Testa MemoryCardIcons (RF01/RF02) — res://scripts/core/animal_card_icons.gd.

func suite_name() -> String:
	return "card_icons"


func test_pool_has_enough_icons_for_hardest_difficulty() -> void:
	assert_true(MemoryCardIcons.POOL.size() >= 20, "Pool precisa ter pelo menos 20 ícones (Difícil)")


func test_pool_has_no_duplicate_paths() -> void:
	var unique := {}
	for path in MemoryCardIcons.POOL:
		unique[path] = true
	assert_eq(unique.size(), MemoryCardIcons.POOL.size(), "Não deveria haver ícone repetido no pool")


func test_pick_returns_requested_count() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var icons: Array = MemoryCardIcons.pick(8, rng)
	assert_eq(icons.size(), 8)


func test_pick_returns_distinct_icons() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2
	var icons: Array = MemoryCardIcons.pick(20, rng)
	var unique := {}
	for path in icons:
		unique[path] = true
	assert_eq(unique.size(), 20, "Os 20 ícones sorteados devem ser distintos entre si")


func test_pick_only_returns_paths_from_pool() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var icons: Array = MemoryCardIcons.pick(15, rng)
	for path in icons:
		assert_true(MemoryCardIcons.POOL.has(path), "Ícone sorteado deveria vir do pool")


func test_pick_varies_between_calls() -> void:
	var rng_a := RandomNumberGenerator.new()
	rng_a.seed = 10
	var rng_b := RandomNumberGenerator.new()
	rng_b.seed = 20
	var icons_a: Array = MemoryCardIcons.pick(8, rng_a)
	var icons_b: Array = MemoryCardIcons.pick(8, rng_b)
	assert_ne(icons_a, icons_b, "Seeds diferentes deveriam sortear conjuntos diferentes")
