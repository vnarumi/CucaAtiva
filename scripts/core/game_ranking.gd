class_name GameRanking
extends RefCounted
## Posição de uma partida no ranking (tela de Parabéns). Puro, sem dependência
## de cena. O ranking é por nível: mais pontos fica na frente e, em empate de
## pontos, quem foi mais rápido. Compara só com partidas vencidas do mesmo nível
## (SaveManager.history), pois pontuações de níveis diferentes não se comparam.

const LEVEL_NAMES := {"facil": "Fácil", "medio": "Médio", "dificil": "Difícil"}


## Devolve {"rank": posição (1 = melhor), "total": nº de partidas do nível}.
## `history` já deve conter a partida atual (SaveManager grava a vitória antes
## da tela de Parabéns aparecer); partidas idênticas à atual (mesmos pontos e
## tempo) não passam à frente dela.
static func position(history: Array, difficulty: String, score: int, time_seconds: float) -> Dictionary:
	var better := 0
	var total := 0
	for entry in history:
		if str(entry.get("difficulty", "")) != difficulty:
			continue
		total += 1
		var s := int(entry.get("score", 0))
		var t := float(entry.get("time_seconds", 0.0))
		if s > score or (s == score and t < time_seconds):
			better += 1
	return {"rank": better + 1, "total": max(total, better + 1)}


## Selo da tela de Parabéns, em duas linhas: ["3º LUGAR", "entre 4 partidas no Fácil"].
## Tom sempre positivo (nada punitivo, RNF04).
static func parts(rank: int, total: int, difficulty: String) -> Array:
	var level: String = LEVEL_NAMES.get(difficulty, difficulty)
	var title := "%dº LUGAR" % rank
	if rank == 1 and total <= 1:
		return [title, "Você abriu o ranking do %s!" % level]
	if rank == 1:
		return [title, "Novo recorde no %s!" % level]
	return [title, "entre %d partidas no %s" % [total, level]]


## Texto positivo numa linha só (nada punitivo, RNF04).
static func message(rank: int, total: int, difficulty: String) -> String:
	var level: String = LEVEL_NAMES.get(difficulty, difficulty)
	if rank == 1 and total <= 1:
		return "Você abriu o ranking do %s: 1º lugar!" % level
	if rank == 1:
		return "Novo recorde! 1º lugar no ranking do %s!" % level
	return "Você ficou em %dº lugar entre %d partidas no %s." % [rank, total, level]
