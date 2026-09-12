class_name ScoreRules
extends RefCounted
## Regras puras de pontuação e vitória (RN01, RN02, RN03) — sem dependência de
## cena ou editor. Ver tests/test_score_rules.gd.

const MATCH_BASE_POINTS := 10
const MATCH_COMBO_STEP := 5
const MISMATCH_PENALTY := -2
const MIN_SCORE := 0


## Pontos ganhos por um par correto, dado o combo atual (nº de acertos
## consecutivos sem erro ANTES deste acerto). RN03: 1º acerto = 10, 2º = 15,
## 3º = 20, ...
static func points_for_match(combo_streak: int) -> int:
	return MATCH_BASE_POINTS + MATCH_COMBO_STEP * combo_streak


## Pontos (negativos) por uma tentativa incorreta. RN01: -2 por erro.
static func points_for_mismatch() -> int:
	return MISMATCH_PENALTY


## Aplica um delta à pontuação atual, respeitando o piso em 0 (RN01).
static func apply_delta(current_score: int, delta: int) -> int:
	return max(MIN_SCORE, current_score + delta)


## RN02: partida vencida quando todos os pares do nível foram encontrados.
static func is_won(matched_pairs: int, total_pairs: int) -> bool:
	return total_pairs > 0 and matched_pairs >= total_pairs
