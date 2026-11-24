extends Control
## Tela de Configurações (vista no protótipo, serve RNF01/RNF02 — não é um
## RF numerado). Volume do jogo (AudioManager) e tamanho da letra
## (SettingsManager), como lista de opções em texto com checkmark verde
## (#4ABA34) na opção selecionada — fiel ao protótipo (sem botões coloridos,
## sem slider).

## Volume linear (0-1) de cada opção. "baixo" é a opção "Médio" da tela: 0,25
## equivale a -12 dB, ou seja, soa bem mais baixo que o "alto" (0 dB). Com 0,5
## (-6 dB) a diferença quase não dava pra perceber.
const VOLUME_LEVELS := {
	"mudo": 0.0,
	"baixo": 0.25,
	"alto": 1.0,
}

const FONT_SCALES := {
	"padrao": 1.0,
	"grande": 1.25,
	"muito_grande": 1.5,
}

@onready var volume_buttons: Dictionary = {
	"mudo": $Layout/VolumeSection/OptionsRow/OptionsList/MudoButton,
	"baixo": $Layout/VolumeSection/OptionsRow/OptionsList/BaixoButton,
	"alto": $Layout/VolumeSection/OptionsRow/OptionsList/AltoButton,
}

@onready var font_buttons: Dictionary = {
	"padrao": $Layout/FontSizeSection/OptionsRow/OptionsList/PadraoButton,
	"grande": $Layout/FontSizeSection/OptionsRow/OptionsList/GrandeButton,
	"muito_grande": $Layout/FontSizeSection/OptionsRow/OptionsList/MuitoGrandeButton,
}


@onready var vibration_buttons: Dictionary = {
	"ligada": $Layout/VibrationSection/OptionsRow/OptionsList/LigadaButton,
	"desligada": $Layout/VibrationSection/OptionsRow/OptionsList/DesligadaButton,
}


func _ready() -> void:
	for option in vibration_buttons:
		vibration_buttons[option].pressed.connect(_on_vibration_pressed.bind(option))
	_refresh_vibration_checks()
	for level in volume_buttons:
		volume_buttons[level].pressed.connect(_on_volume_pressed.bind(level))
	for level in font_buttons:
		font_buttons[level].pressed.connect(_on_font_pressed.bind(level))
	_refresh_volume_checks()
	_refresh_font_checks()


## Vibração: interruptor próprio, independente do volume. Ao ligar, dá um
## pulso de amostra pra a pessoa sentir como é.
func _on_vibration_pressed(option: String) -> void:
	SettingsManager.set_vibration_enabled(option == "ligada")
	if option == "ligada":
		SettingsManager.vibrate_match()
	_refresh_vibration_checks()


func _refresh_vibration_checks() -> void:
	var current := "ligada" if SettingsManager.vibration_enabled else "desligada"
	for option in vibration_buttons:
		vibration_buttons[option].get_node("Row/Check").visible = option == current


func _on_volume_pressed(level: String) -> void:
	AudioManager.set_master_volume(VOLUME_LEVELS[level])
	_refresh_volume_checks()


func _refresh_volume_checks() -> void:
	var current_level := _closest_level(AudioManager.get_master_volume())
	for level in volume_buttons:
		volume_buttons[level].get_node("Row/Check").visible = level == current_level


func _closest_level(value: float) -> String:
	var best_level := "alto"
	var best_diff := INF
	for level in VOLUME_LEVELS:
		var diff: float = abs(VOLUME_LEVELS[level] - value)
		if diff < best_diff:
			best_diff = diff
			best_level = level
	return best_level


func _on_font_pressed(level: String) -> void:
	SettingsManager.set_font_scale(FONT_SCALES[level])
	_refresh_font_checks()


func _refresh_font_checks() -> void:
	var current_level := _closest_font_level(SettingsManager.font_scale)
	for level in font_buttons:
		font_buttons[level].get_node("Row/Check").visible = level == current_level


func _closest_font_level(value: float) -> String:
	var best_level := "padrao"
	var best_diff := INF
	for level in FONT_SCALES:
		var diff: float = abs(FONT_SCALES[level] - value)
		if diff < best_diff:
			best_diff = diff
			best_level = level
	return best_level


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
