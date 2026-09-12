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


## Tamanho de fonte atualmente aplicado no tema para o tipo dado ("Button"/
## "Label"). Útil para a tela de Configurações e para QA confirmarem o
## valor real aplicado.
func get_font_size(theme_type: String) -> int:
	if _theme == null:
		_theme = load(THEME_PATH)
	return _theme.get_font_size("font_size", theme_type)
