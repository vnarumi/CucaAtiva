class_name BoardGenerator
extends RefCounted
## Geração/embaralhamento do tabuleiro (RF01) — puro, sem dependência de cena
## ou editor. Ver tests/test_board_generator.gd.

const PAIRS_PER_DIFFICULTY := {
	"facil": 8,
	"medio": 15,
	"dificil": 20,
}


## Número de pares para uma dificuldade válida ("facil"/"medio"/"dificil"),
## ou 0 se desconhecida.
static func pairs_for_difficulty(difficulty: String) -> int:
	return PAIRS_PER_DIFFICULTY.get(difficulty, 0)


## Gera o tabuleiro embaralhado: um Array com 2x pairs_for_difficulty(difficulty)
## ints, cada valor de 0..pairs-1 aparecendo exatamente duas vezes (o par).
## Passe um RandomNumberGenerator com seed fixa nos testes para determinismo;
## sem isso, usa uma seed aleatória real.
static func generate(difficulty: String, rng: RandomNumberGenerator = null) -> Array:
	var pairs := pairs_for_difficulty(difficulty)
	if pairs <= 0:
		return []
	var ids: Array = []
	for i in pairs:
		ids.append(i)
		ids.append(i)
	_shuffle(ids, rng)
	return ids


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
