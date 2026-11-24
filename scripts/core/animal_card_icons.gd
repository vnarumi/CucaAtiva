class_name MemoryCardIcons
extends RefCounted
## Fotos de animal usadas nas cartas do tabuleiro (RF01/RF02) — puro, sem
## dependência de cena. Cada nível tem a sua pasta e a sua lista: o Fácil usa
## animais bem diferentes entre si; o Médio tem mais variedade; o Difícil traz
## grupos de animais parecidos (felinos, aves pequenas, "cinzentões"...), que
## exigem mais atenção. Cada lista tem folga sobre o nº de pares do nível, então
## cada partida sorteia um subconjunto diferente.

const DIR := "res://assets/icons/cards/"

const FACIL: Array = [
	"vaca", "porco", "gato", "cachorro", "elefante", "leao", "pato", "galinha",
	"sapo", "girafa", "borboleta", "peixe_dourado",
]

const MEDIO: Array = [
	"cavalo", "ovelha", "urso", "jacare", "pombo", "coelho", "golfinho",
	"caranguejo", "caracol", "coala", "hipopotamo", "arara", "cabrito",
	"hamster", "leao_marinho", "tartaruga", "coruja", "macaco", "zebra",
	"pinguim",
]

const DIFICIL: Array = [
	# Pequenos peludos
	"porquinho_da_india", "hamster", "coelho", "esquilo",
	# Pássaros pequenos
	"pardal", "canario", "pombo", "periquito",
	# Felinos
	"leao", "chita", "tigre", "onca",
	# Cavalo e parecidos
	"cavalo", "zebra", "burro", "cabrito",
	# Fazenda
	"ovelha", "vaca", "bezerro",
	# Grandes e cinzentos
	"elefante", "rinoceronte", "hipopotamo", "bufalo",
	# Mar
	"golfinho", "cavalo_marinho", "tubarao", "baleia", "polvo",
	# Outros
	"vespa", "arara_azul", "spitz", "canguru",
]

## Caminhos (res://...) dos animais de um nível. Nível desconhecido ou vazio
## devolve os de todos os níveis (um animal que está em 2 níveis aparece 2x,
## pois cada nível tem a sua própria cópia da foto).
static func pool_for(difficulty: String) -> Array:
	var names: Array
	match difficulty:
		"facil":
			names = FACIL
		"medio":
			names = MEDIO
		"dificil":
			names = DIFICIL
		_:
			return _all_paths()
	var paths: Array = []
	for n in names:
		paths.append("%s%s/%s.jpg" % [DIR, difficulty, n])
	return paths


static func _all_paths() -> Array:
	var paths: Array = []
	for level in ["facil", "medio", "dificil"]:
		paths.append_array(pool_for(level))
	return paths


## Sorteia `count` ícones distintos do nível (sem repetir) pra um tabuleiro com
## esse número de pares. Passe uma seed fixa nos testes para determinismo; sem
## isso, usa uma seed aleatória real.
static func pick(count: int, difficulty: String = "", rng: RandomNumberGenerator = null) -> Array:
	var shuffled: Array = pool_for(difficulty)
	_shuffle(shuffled, rng)
	return shuffled.slice(0, count)


static func _shuffle(array: Array, rng: RandomNumberGenerator) -> void:
	var r := rng
	if r == null:
		r = RandomNumberGenerator.new()
		r.randomize()
	for i in range(array.size() - 1, 0, -1):
		var j := r.randi_range(0, i)
		var tmp = array[i]
		array[i] = array[j]
		array[j] = tmp
