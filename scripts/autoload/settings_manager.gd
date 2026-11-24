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


## Textos com tamanho fixo na cena (theme_override_font_sizes/font_size) a partir
## deste tamanho são títulos decorativos e NÃO crescem com a escala — a 150% eles
## passariam da largura do celular. Só os textos de leitura (menores) crescem.
const TITLE_MIN_BASE_SIZE := 36
## Grupo para marcar textos que nunca devem mudar de tamanho (ex.: o "DICA" que
## precisa caber dentro da estrela).
const FIXED_FONT_GROUP := &"fixed_font"
## Grupo para marcar a RAIZ de uma cena cujos textos não devem mudar de tamanho.
const FIXED_FONT_SCENE_GROUP := &"fixed_font_scene"
## Grupo para textos que crescem, mas no máximo até esta escala (ex.: a legenda
## do animal, que aparece num espaço de altura fixa no tabuleiro).
const CAPPED_FONT_GROUP := &"capped_font"
const CAPPED_MAX_SCALE := 1.25
const BASE_SIZE_META := &"base_font_size"


func _ready() -> void:
	_theme = load(THEME_PATH)
	get_tree().node_added.connect(_on_node_added)


## RNF02: escala os tamanhos de fonte do tema compartilhado (ex.: 1.0 normal,
## 1.25 grande) e também os textos com tamanho fixo nas cenas. Afeta toda tela
## imediatamente.
func set_font_scale(scale: float) -> void:
	font_scale = scale
	if _theme == null:
		_theme = load(THEME_PATH)
	_theme.set_font_size("font_size", "Button", roundi(BASE_BUTTON_FONT_SIZE * scale))
	_theme.set_font_size("font_size", "Label", roundi(BASE_LABEL_FONT_SIZE * scale))
	if is_inside_tree():
		_apply_scale_to_tree(get_tree().root)
	font_scale_changed.emit(font_scale)


## Reaplica a escala atual a um texto (volta ao tamanho escalado "de fábrica",
## desfazendo ajustes feitos à mão, como encolher pra caber).
func reapply_font_scale(node: Node) -> void:
	_apply_scale_to_node(node)


func _on_node_added(node: Node) -> void:
	_apply_scale_to_node(node)


func _apply_scale_to_tree(node: Node) -> void:
	_apply_scale_to_node(node)
	for child in node.get_children():
		_apply_scale_to_tree(child)


## Escala o tamanho de fonte "fixo" (override na cena) de um Label/Button a
## partir do tamanho original, guardado no próprio nó na primeira vez.
func _apply_scale_to_node(node: Node) -> void:
	if not (node is Label or node is Button):
		return
	var control := node as Control
	if control.is_in_group(FIXED_FONT_GROUP):
		return
	# Cena inteira marcada como "sem escala" (ex.: Configurações, onde a pessoa
	# escolhe o tamanho e a tela precisa caber em qualquer escala).
	if control.owner != null and control.owner.is_in_group(FIXED_FONT_SCENE_GROUP):
		return
	var base: int
	if control.has_meta(BASE_SIZE_META):
		base = control.get_meta(BASE_SIZE_META)
	elif control.has_theme_font_size_override("font_size"):
		base = control.get_theme_font_size("font_size")
		control.set_meta(BASE_SIZE_META, base)
	else:
		return  # sem override: o tema já cuida
	if base >= TITLE_MIN_BASE_SIZE:
		return
	var scale := font_scale
	if control.is_in_group(CAPPED_FONT_GROUP):
		scale = min(scale, CAPPED_MAX_SCALE)
	control.add_theme_font_size_override("font_size", roundi(base * scale))


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
