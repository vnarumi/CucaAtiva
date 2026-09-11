extends Node
## Fase 1+ preenche a lógica de partida (RF01, RF02, RN01-RN03).

signal score_changed(new_score: int)
signal match_found(pair_id: int)
signal match_failed
signal game_won

var difficulty: String = ""
var score: int = 0
var combo_streak: int = 0
var hints_used: int = 0
