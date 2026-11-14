extends Node

# Procedural SFX Audio Manager for Voichemist
# Generates lightweight retro / arcade sound effects directly in memory

var players: Array[AudioStreamPlayer] = []
var max_players: int = 8
var current_player_index: int = 0

var sfx_cache: Dictionary = {}
var sfx_volume: float = 1.0
var is_muted: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Create pool of AudioStreamPlayers for polyphony
	for i in range(max_players):
		var p = AudioStreamPlayer.new()
		add_child(p)
		players.append(p)
		
	# Pre-generate common SFX waveforms
	sfx_cache["click"] = _generate_tone(800.0, 1000.0, 0.05, "sine", 0.3)
	sfx_cache["coin"] = _generate_tone(987.77, 1318.51, 0.15, "sine", 0.4)
	sfx_cache["throw"] = _generate_tone(400.0, 150.0, 0.18, "noise", 0.3)
	sfx_cache["hit"] = _generate_tone(220.0, 60.0, 0.25, "square", 0.4)
	sfx_cache["dodge"] = _generate_tone(600.0, 200.0, 0.12, "sine", 0.3)
	sfx_cache["leaf"] = _generate_tone(659.25, 880.0, 0.12, "sine", 0.35)

func _get_available_player() -> AudioStreamPlayer:
	var player = players[current_player_index]
	current_player_index = (current_player_index + 1) % max_players
	return player

func set_sfx_volume(val: float) -> void:
	sfx_volume = clampf(val, 0.0, 1.0)
	for p in players:
		p.volume_db = linear_to_db(sfx_volume) if (not is_muted and sfx_volume > 0.001) else -80.0

func toggle_mute() -> bool:
	is_muted = not is_muted
	set_sfx_volume(sfx_volume)
	return is_muted

func play_sfx(sfx_name: String) -> void:
	if is_muted or not sfx_cache.has(sfx_name):
		return
	var player = _get_available_player()
	player.volume_db = linear_to_db(sfx_volume) if sfx_volume > 0.001 else -80.0
	player.stream = sfx_cache[sfx_name]
	player.play()

func play_click() -> void:
	play_sfx("click")

func play_coin() -> void:
	play_sfx("coin")

func play_throw() -> void:
	play_sfx("throw")

func play_hit() -> void:
	play_sfx("hit")

func play_dodge() -> void:
	play_sfx("dodge")

func play_leaf() -> void:
	play_sfx("leaf")

# --- Procedural Audio Generator ---
func _generate_tone(freq_start: float, freq_end: float, duration: float, type: String = "sine", volume: float = 0.5) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var num_samples: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(num_samples)
	
	var phase: float = 0.0
	for i in range(num_samples):
		var progress = float(i) / float(num_samples)
		var freq = lerp(freq_start, freq_end, progress)
		phase += freq * (TAU / float(sample_rate))
		
		var sample: float = 0.0
		if type == "sine":
			sample = sin(phase)
		elif type == "square":
			sample = 1.0 if sin(phase) > 0.0 else -1.0
		elif type == "noise":
			sample = randf_range(-1.0, 1.0)
			
		# Decay envelope to prevent clicks
		var envelope = (1.0 - progress) * volume
		sample *= envelope
		
		# Convert [-1.0, 1.0] to unsigned 8-bit [0, 255] (128 is center)
		var byte_val = int(clamp((sample * 127.0) + 128.0, 0, 255))
		data[i] = byte_val
		
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	return stream
