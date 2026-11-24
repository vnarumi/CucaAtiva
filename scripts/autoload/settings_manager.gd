extends Node
## Fase 2: escala de tamanho de texto (RNF02), aplicada em tempo real ao
## Theme compartilhado (res://assets/theme/base_theme.tres). Nunca escreve
## no .tres — só muta a instância já carregada em memória, então o valor
## não é persistido em disco (isso é trabalho do tema/godot-scene-builder,
## não deste autoload).

signal font_scale_changed(scale: float)

const THEME_PATH := "res://assets/theme/base_theme.tres"
const BASE_BUTTON_FONT_SIZE := 28
const BASE_LABEL_FONT_SIZE := 32

var font_scale: float = 1.0

## Vibração do aparelho (acerto/erro/vitória). É um interruptor próprio das
## Configurações: independe do volume — desligar o som não desliga a vibração.
var vibration_enabled: bool = true

## Pulsos fortes o bastante pra sentir no celular (amplitude 0-1, Android 8+).
const VIBRATE_MATCH_MS := 160
const VIBRATE_MATCH_AMPLITUDE := 1.0
const VIBRATE_MISS_MS := 70
const VIBRATE_MISS_AMPLITUDE := 0.7
const VIBRATE_MISS_GAP_SECONDS := 0.12
const VIBRATE_WIN_MS := 450

var _theme: Theme


func _ready() -> void:
	_theme = load(THEME_PATH)


## RNF02: escala os tamanhos de fonte do tema compartilhado (ex.: 1.0 normal,
## 1.25 grande). Afeta toda tela que usa base_theme.tres imediatamente.
func set_font_scale(scale: float) -> void:
	font_scale = scale
	if _theme == null:
		_theme = load(THEME_PATH)
	_theme.set_font_size("font_size", "Button", roundi(BASE_BUTTON_FONT_SIZE * scale))
	_theme.set_font_size("font_size", "Label", roundi(BASE_LABEL_FONT_SIZE * scale))
	font_scale_changed.emit(font_scale)


func set_vibration_enabled(enabled: bool) -> void:
	vibration_enabled = enabled


## Um pulso de vibração, se estiver ligada. No computador não faz nada.
func vibrate(duration_ms: int, amplitude: float = 1.0) -> void:
	if not vibration_enabled:
		return
	Input.vibrate_handheld(duration_ms, amplitude)


## Acerto de par: um pulso firme.
func vibrate_match() -> void:
	vibrate(VIBRATE_MATCH_MS, VIBRATE_MATCH_AMPLITUDE)


## Erro (não punitivo, RNF04): dois toques curtos e mais suaves.
func vibrate_miss() -> void:
	vibrate(VIBRATE_MISS_MS, VIBRATE_MISS_AMPLITUDE)
	await get_tree().create_timer(VIBRATE_MISS_GAP_SECONDS + VIBRATE_MISS_MS / 1000.0).timeout
	vibrate(VIBRATE_MISS_MS, VIBRATE_MISS_AMPLITUDE)


## Vitória: um pulso longo.
func vibrate_win() -> void:
	vibrate(VIBRATE_WIN_MS, 1.0)


## Tamanho de fonte atualmente aplicado no tema para o tipo dado ("Button"/
## "Label"). Útil para a tela de Configurações e para QA confirmarem o
## valor real aplicado.
func get_font_size(theme_type: String) -> int:
	if _theme == null:
		_theme = load(THEME_PATH)
	return _theme.get_font_size("font_size", theme_type)
