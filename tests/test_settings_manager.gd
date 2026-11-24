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


## Textos com tamanho fixo na cena (override) também crescem com a escala; títulos
## (>= 36) e textos marcados como fixos não.
func test_scene_text_with_font_override_scales() -> void:
	var settings := _new_settings()
	var label := track(Label.new())
	label.add_theme_font_size_override("font_size", 24)
	settings.set_font_scale(1.5)
	settings._apply_scale_to_node(label)
	assert_eq(label.get_theme_font_size("font_size"), 36, "24 * 1.5")
	settings.set_font_scale(1.0)
	settings._apply_scale_to_node(label)
	assert_eq(label.get_theme_font_size("font_size"), 24, "volta ao tamanho original")


func test_titles_do_not_scale() -> void:
	var settings := _new_settings()
	var title := track(Label.new())
	title.add_theme_font_size_override("font_size", 52)
	settings.set_font_scale(1.5)
	settings._apply_scale_to_node(title)
	assert_eq(title.get_theme_font_size("font_size"), 52, "título decorativo não cresce")


func test_capped_text_stops_at_125_percent() -> void:
	var settings := _new_settings()
	var label := track(Label.new())
	label.add_theme_font_size_override("font_size", 32)
	label.add_to_group("capped_font")
	settings.set_font_scale(1.5)
	settings._apply_scale_to_node(label)
	assert_eq(label.get_theme_font_size("font_size"), 40, "32 * 1.25 (limite)")
