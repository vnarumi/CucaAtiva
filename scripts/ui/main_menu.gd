extends Panel
## Menu principal (RF01 entrada). No primeiro acesso, redireciona para o
## tutorial (RF05) antes de qualquer outra coisa.

const PRESS_SCALE := 0.92
const PRESS_ANIM_SECONDS := 0.08

@onready var jogar_button: Button = $Layout/JogarWrapper/JogarButton
@onready var continuar_wrapper: Control = $Layout/ContinuarWrapper
@onready var historico_button: Button = $Layout/ShortcutsRow/HistoricoGroup/HistoricoWrapper/HistoricoButton
@onready var configuracoes_button: Button = $Layout/ShortcutsRow/ConfiguracoesGroup/ConfiguracoesWrapper/ConfiguracoesButton


func _ready() -> void:
	if not SaveManager.seen_tutorial:
		get_tree().change_scene_to_file("res://scenes/game/tutorial.tscn")
		return
	## RF08: só oferece "Continuar partida" quando há mesmo um autosave —
	## sem isso o botão ficaria sempre visível sem nada pra retomar.
	continuar_wrapper.visible = SaveManager.has_in_progress()
	for btn in [jogar_button, historico_button, configuracoes_button]:
		_update_pivot(btn)
		btn.resized.connect(_update_pivot.bind(btn))
		btn.button_down.connect(_on_image_button_down.bind(btn))
		btn.button_up.connect(_on_image_button_up.bind(btn))


## Botões de ícone completo (imagem única exportada do Figma, sombra/halo já
## embutidos) não têm feedback visual nativo de "pressionado" — o Button por
## trás é transparente em todos os estados. Compensa com uma leve animação de
## escala, importante pro usuário idoso confirmar que o toque registrou.
func _update_pivot(btn: Button) -> void:
	btn.pivot_offset = btn.size / 2.0


func _on_image_button_down(btn: Button) -> void:
	var tween := create_tween()
	tween.tween_property(btn, "scale", Vector2.ONE * PRESS_SCALE, PRESS_ANIM_SECONDS)


func _on_image_button_up(btn: Button) -> void:
	var tween := create_tween()
	tween.tween_property(btn, "scale", Vector2.ONE, PRESS_ANIM_SECONDS)


func _on_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/difficulty_select.tscn")


## RF08: retoma a partida salva (autosave feito ao fechar/perder foco) direto
## no tabuleiro, sem passar pela seleção de dificuldade — o nível já vem do
## estado restaurado.
func _on_continuar_pressed() -> void:
	SaveManager.resume_in_progress()
	get_tree().change_scene_to_file("res://scenes/game/board.tscn")


func _on_historico_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/history.tscn")


func _on_configuracoes_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/settings.tscn")
