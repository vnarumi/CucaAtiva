extends Node
## Fase 2: feedback sonoro (RF03) gerado proceduralmente — não há nenhum
## asset de áudio no projeto ainda, então os efeitos são tons curtos e
## suaves (sem sirene/alarme, per RNF04) sintetizados em memória.

const MIX_RATE := 22050
const AMPLITUDE := 0.35
const FADE_SECONDS := 0.01

## Pasta dos sons de animais: um arquivo por animal, com o mesmo nome do ícone
## (ex.: cards/cachorro.jpg -> animals/cachorro.ogg).
const ANIMAL_SOUND_DIR := "res://assets/audio/animals/"
const ANIMAL_SOUND_EXTENSIONS := ["ogg", "wav", "mp3"]
## Espera o tom de acerto terminar (~0.2s) antes de soltar o som do animal.
const ANIMAL_SOUND_DELAY := 0.25
## Sons mais longos que isso são cortados (com fade-out) — o acerto não deve
## virar um barulho longo (RNF04).
const ANIMAL_SOUND_MAX_SECONDS := 3.0
const ANIMAL_SOUND_FADE_SECONDS := 0.3

var _sfx_player: AudioStreamPlayer
var _animal_player: AudioStreamPlayer
var _animal_streams: Dictionary = {}
var _correct_stream: AudioStreamWAV
var _incorrect_stream: AudioStreamWAV
var _master_volume: float = 1.0


func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	add_child(_sfx_player)
	_animal_player = AudioStreamPlayer.new()
	add_child(_animal_player)
	_correct_stream = _build_stream(_tone(660.0, 0.09) + _tone(880.0, 0.11))
	_incorrect_stream = _build_stream(_tone(240.0, 0.22))


## RF03: toca o feedback sonoro de acerto (par correto).
func play_correct() -> void:
	_sfx_player.stream = _correct_stream
	_sfx_player.play()


## Toca o som do animal do ícone (caminho da imagem da carta) depois do tom de
## acerto. Se não houver arquivo de som para esse animal, não faz nada.
func play_animal(icon_path: String) -> void:
	var stream := _get_animal_stream(icon_path)
	if stream == null:
		return
	await get_tree().create_timer(ANIMAL_SOUND_DELAY).timeout
	_animal_player.stream = stream
	_animal_player.volume_db = 0.0
	_animal_player.play()
	if stream.get_length() > ANIMAL_SOUND_MAX_SECONDS:
		_cut_animal_sound()


## Corta o som atual depois de ANIMAL_SOUND_MAX_SECONDS com um fade-out curto.
## Ignora se outro som de animal já começou nesse meio-tempo.
func _cut_animal_sound() -> void:
	var current := _animal_player.stream
	await get_tree().create_timer(ANIMAL_SOUND_MAX_SECONDS - ANIMAL_SOUND_FADE_SECONDS).timeout
	if _animal_player.stream != current or not _animal_player.playing:
		return
	var tween := create_tween()
	tween.tween_property(_animal_player, "volume_db", -40.0, ANIMAL_SOUND_FADE_SECONDS)
	await tween.finished
	if _animal_player.stream == current:
		_animal_player.stop()


func _get_animal_stream(icon_path: String) -> AudioStream:
	var animal := icon_path.get_file().get_basename()
	if _animal_streams.has(animal):
		return _animal_streams[animal]
	var stream: AudioStream = null
	for ext in ANIMAL_SOUND_EXTENSIONS:
		var path: String = ANIMAL_SOUND_DIR + animal + "." + ext
		if ResourceLoader.exists(path):
			stream = load(path)
			break
	_animal_streams[animal] = stream
	return stream


## RF03: toca o feedback sonoro de erro (par incorreto) — som suave, não é
## um alarme (RNF04).
func play_incorrect() -> void:
	_sfx_player.stream = _incorrect_stream
	_sfx_player.play()


## Volume mestre (0.0-1.0), usado pela tela de Configurações.
func set_master_volume(value: float) -> void:
	_master_volume = clamp(value, 0.0, 1.0)
	var bus_idx := AudioServer.get_bus_index("Master")
	if bus_idx < 0:
		return
	if _master_volume <= 0.0:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(_master_volume))


func get_master_volume() -> float:
	return _master_volume


## Gera amostras PCM16 mono de um tom senoidal com fade-in/out curto para
## evitar cliques, retornando bytes prontos para AudioStreamWAV.data.
func _tone(frequency: float, duration: float) -> PackedByteArray:
	var sample_count := int(duration * MIX_RATE)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	var fade_samples: int = max(1, int(MIX_RATE * FADE_SECONDS))
	for i in sample_count:
		var t := float(i) / MIX_RATE
		var envelope := 1.0
		if i < fade_samples:
			envelope = float(i) / fade_samples
		elif i > sample_count - fade_samples:
			envelope = float(sample_count - i) / fade_samples
		var sample := sin(TAU * frequency * t) * AMPLITUDE * envelope
		var sample_i16 := int(clamp(sample, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, sample_i16)
	return bytes


func _build_stream(pcm_data: PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = pcm_data
	return stream
