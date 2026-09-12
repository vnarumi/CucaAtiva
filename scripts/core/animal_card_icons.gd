class_name MemoryCardIcons
extends RefCounted
## Ícones de animal usados nas cartas do tabuleiro (RF01/RF02) — puro, sem
## dependência de cena. Pool com folga sobre o máximo de pares (20, nível
## Difícil) pra dar variedade entre partidas: cada jogo sorteia um
## subconjunto diferente do pool inteiro, não sempre os mesmos 20 primeiros.

const POOL := [
	"res://assets/icons/cards/urso.png",
	"res://assets/icons/cards/coala.png",
	"res://assets/icons/cards/chita.png",
	"res://assets/icons/cards/caracol.png",
	"res://assets/icons/cards/spitz.png",
	"res://assets/icons/cards/arara.png",
	"res://assets/icons/cards/porco.png",
	"res://assets/icons/cards/elefante.png",
	"res://assets/icons/cards/peixe_dourado.png",
	"res://assets/icons/cards/golfinho.jpg",
	"res://assets/icons/cards/caranguejo.jpg",
	"res://assets/icons/cards/sapo.jpg",
	"res://assets/icons/cards/borboleta.jpg",
	"res://assets/icons/cards/pombo.jpg",
	"res://assets/icons/cards/pardal.jpg",
	"res://assets/icons/cards/girafa.jpg",
	"res://assets/icons/cards/leao.jpg",
	"res://assets/icons/cards/gato.jpg",
	"res://assets/icons/cards/vespa.jpg",
	"res://assets/icons/cards/cachorro.jpg",
	"res://assets/icons/cards/coelho.jpg",
	"res://assets/icons/cards/canario.jpg",
	"res://assets/icons/cards/arara_azul.jpg",
	"res://assets/icons/cards/vaca.jpg",
	"res://assets/icons/cards/cavalo.jpg",
	"res://assets/icons/cards/jacare.jpg",
	"res://assets/icons/cards/hipopotamo.jpg",
	"res://assets/icons/cards/rinoceronte.jpg",
	"res://assets/icons/cards/leao_marinho.jpg",
	"res://assets/icons/cards/cavalo_marinho.jpg",
	"res://assets/icons/cards/pato.jpg",
	"res://assets/icons/cards/porquinho_da_india.jpg",
	"res://assets/icons/cards/galinha.jpg",
	"res://assets/icons/cards/cabrito.jpg",
	"res://assets/icons/cards/ovelha.jpg",
	"res://assets/icons/cards/hamster.jpg",
]


## Sorteia `count` ícones distintos do pool (sem repetir) pra um tabuleiro
## com esse número de pares. `count` nunca deve passar POOL.size() — os 3
## níveis de dificuldade (8/15/20) sempre cabem com folga. Passe uma seed
## fixa nos testes para determinismo; sem isso, usa uma seed aleatória real.
static func pick(count: int, rng: RandomNumberGenerator = null) -> Array:
	var shuffled: Array = POOL.duplicate()
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
