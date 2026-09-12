@tool
extends McpTestSuite
## Testa SettingsManager (RNF02 — escala de fonte) — res://scripts/autoload/settings_manager.gd.

const SettingsManagerScript := preload("res://scripts/autoload/settings_manager.gd")


func suite_name() -> String:
	return "settings_manager"


func _new_settings() -> Node:
	return track(SettingsManagerScript.new())


func teardown() -> void:
	# Restaura o tema compartilhado para o padrão para não deixar o editor
	# com a fonte escalada depois que os testes rodam.
	var settings := _new_settings()
	settings.set_font_scale(1.0)


func test_default_scale_is_one() -> void:
	var settings := _new_settings()
	assert_eq(settings.font_scale, 1.0)


func test_set_font_scale_updates_state_and_emits_signal() -> void:
	var settings := _new_settings()
	var emitted := [-1.0]
	settings.font_scale_changed.connect(func(s): emitted[0] = s)
	settings.set_font_scale(1.25)
	assert_eq(settings.font_scale, 1.25)
	assert_eq(emitted[0], 1.25, "font_scale_changed deveria emitir o novo valor")


func test_set_font_scale_applies_to_shared_theme() -> void:
	var settings := _new_settings()
	settings.set_font_scale(1.25)
	assert_eq(settings.get_font_size("Button"), 35, "28 * 1.25 arredondado = 35")
	assert_eq(settings.get_font_size("Label"), 40, "32 * 1.25 = 40")


func test_set_font_scale_back_to_normal_restores_base_sizes() -> void:
	var settings := _new_settings()
	settings.set_font_scale(1.25)
	settings.set_font_scale(1.0)
	assert_eq(settings.get_font_size("Button"), 28)
	assert_eq(settings.get_font_size("Label"), 32)
