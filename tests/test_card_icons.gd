@tool
extends McpTestSuite
## Testa MemoryCardIcons (RF01/RF02) — res://scripts/core/animal_card_icons.gd.
## Cada nível tem a sua lista de animais e a sua pasta de fotos.

const LEVELS := {"facil": 8, "medio": 15, "dificil": 20}


func suite_name() -> String:
	return "card_icons"


func test_each_level_has_enough_icons_for_its_pairs() -> void:
	for level in LEVELS:
		var pool: Array = MemoryCardIcons.pool_for(level)
		assert_true(pool.size() >= LEVELS[level], "Nível %s precisa de >= %d animais (tem %d)" % [level, LEVELS[level], pool.size()])


func test_no_duplicate_paths_within_a_level() -> void:
	for level in LEVELS:
		var unique := {}
		for path in MemoryCardIcons.pool_for(level):
			unique[path] = true
		assert_eq(unique.size(), MemoryCardIcons.pool_for(level).size(), "Nível %s não deveria ter animal repetido" % level)


func test_every_listed_photo_exists_and_loads() -> void:
	for level in LEVELS:
		for path in MemoryCardIcons.pool_for(level):
			assert_true(ResourceLoader.exists(path), "Foto não encontrada: %s" % path)


func test_photos_live_in_the_folder_of_their_level() -> void:
	for level in LEVELS:
		for path in MemoryCardIcons.pool_for(level):
			assert_true(path.contains("/%s/" % level), "%s deveria estar na pasta %s" % [path, level])


func test_pick_returns_requested_count() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	assert_eq(MemoryCardIcons.pick(8, "facil", rng).size(), 8)


func test_pick_returns_distinct_icons_at_every_level() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2
	for level in LEVELS:
		var icons: Array = MemoryCardIcons.pick(LEVELS[level], level, rng)
		var unique := {}
		for path in icons:
			unique[path] = true
		assert_eq(unique.size(), LEVELS[level], "Os ícones sorteados em %s devem ser distintos" % level)


func test_pick_only_returns_paths_from_the_level_pool() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for level in LEVELS:
		var pool: Array = MemoryCardIcons.pool_for(level)
		for path in MemoryCardIcons.pick(LEVELS[level], level, rng):
			assert_true(pool.has(path), "Ícone sorteado deveria vir da lista de %s" % level)


func test_pick_varies_between_calls() -> void:
	var rng_a := RandomNumberGenerator.new()
	rng_a.seed = 10
	var rng_b := RandomNumberGenerator.new()
	rng_b.seed = 20
	var icons_a: Array = MemoryCardIcons.pick(8, "facil", rng_a)
	var icons_b: Array = MemoryCardIcons.pick(8, "facil", rng_b)
	assert_ne(icons_a, icons_b, "Seeds diferentes deveriam sortear conjuntos diferentes")
