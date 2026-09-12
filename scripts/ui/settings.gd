extends Control
## Tela de Configurações (vista no protótipo, serve RNF01/RNF02 — não é um
## RF numerado). Volume do jogo (AudioManager) e tamanho da letra
## (SettingsManager), em badges discretos com checkmark verde (#4ABA34) na
## opção selecionada — fiel ao protótipo (sem slider, sem "✓" em texto).

const VOLUME_LEVELS := {
	"mudo": 0.0,
	"baixo": 0.5,
	"alto": 1.0,
}

@onready var volume_buttons: Dictionary = {
	"mudo": $Layout/VolumeSection/VolumeButtons/MudoButton,
	"baixo": $Layout/VolumeSection/VolumeButtons/BaixoButton,
	"alto": $Layout/VolumeSection/VolumeButtons/AltoButton,
}

@onready var normal_button: Button = $Layout/FontSizeSection/FontSizeButtons/NormalButton
@onready var grande_button: Button = $Layout/FontSizeSection/FontSizeButtons/GrandeButton


func _ready() -> void:
	for level in volume_buttons:
		volume_buttons[level].pressed.connect(_on_volume_pressed.bind(level))
	normal_button.pressed.connect(_on_normal_pressed)
	grande_button.pressed.connect(_on_grande_pressed)
	_refresh_volume_checks()
	_refresh_font_buttons()


func _on_volume_pressed(level: String) -> void:
	AudioManager.set_master_volume(VOLUME_LEVELS[level])
	_refresh_volume_checks()


func _refresh_volume_checks() -> void:
	var current_level := _closest_level(AudioManager.get_master_volume())
	for level in volume_buttons:
		volume_buttons[level].get_node("Check").visible = level == current_level


func _closest_level(value: float) -> String:
	var best_level := "alto"
	var best_diff := INF
	for level in VOLUME_LEVELS:
		var diff: float = abs(VOLUME_LEVELS[level] - value)
		if diff < best_diff:
			best_diff = diff
			best_level = level
	return best_level


func _on_normal_pressed() -> void:
	SettingsManager.set_font_scale(1.0)
	_refresh_font_buttons()


func _on_grande_pressed() -> void:
	SettingsManager.set_font_scale(1.25)
	_refresh_font_buttons()


func _refresh_font_buttons() -> void:
	var is_large := SettingsManager.font_scale > 1.0
	normal_button.get_node("Check").visible = not is_large
	grande_button.get_node("Check").visible = is_large


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
