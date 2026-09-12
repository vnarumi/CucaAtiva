@tool
extends McpTestSuite
## Testa a geração dos tons de AudioManager (RF03) sem depender da árvore de
## cena — AudioStreamPlayer.play() exige estar dentro da SceneTree, então
## verificamos os buffers PCM gerados em vez de tocar de verdade (isso é
## coberto por playtest manual/QA).

const AudioManagerScript := preload("res://scripts/autoload/audio_manager.gd")


func suite_name() -> String:
	return "audio_manager"


func _new_audio() -> Node:
	var am: Node = track(AudioManagerScript.new())
	# _ready() só roda ao entrar na árvore — McpTestSuite.track() não
	# adiciona à árvore, então chamamos manualmente para gerar os tons.
	am._ready()
	return am


func test_correct_tone_is_generated() -> void:
	var am := _new_audio()
	assert_true(am._correct_stream is AudioStreamWAV)
	assert_gt(am._correct_stream.data.size(), 0, "Deve gerar amostras PCM para o tom de acerto")


func test_incorrect_tone_is_generated() -> void:
	var am := _new_audio()
	assert_true(am._incorrect_stream is AudioStreamWAV)
	assert_gt(am._incorrect_stream.data.size(), 0, "Deve gerar amostras PCM para o tom de erro")


func test_master_volume_defaults_to_full() -> void:
	var am := _new_audio()
	assert_eq(am.get_master_volume(), 1.0)


func test_set_master_volume_clamps_and_reads_back() -> void:
	var am := _new_audio()
	am.set_master_volume(0.5)
	assert_eq(am.get_master_volume(), 0.5)
	am.set_master_volume(2.0)
	assert_eq(am.get_master_volume(), 1.0, "Deve limitar a 1.0")
	am.set_master_volume(-1.0)
	assert_eq(am.get_master_volume(), 0.0, "Deve limitar a 0.0")
