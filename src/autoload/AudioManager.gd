extends Node
## Gentle pastoral multi-layer audio manager:
## pastoral kalimba BGM + brook ambient + optional rain-chime layer + pooled UI/tile SFX.

const SFX_POOL_SIZE := 8

var _bgm_player: AudioStreamPlayer
var _brook_player: AudioStreamPlayer
var _rain_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_cursor: int = 0
var _sfx_cache: Dictionary = {}


func _ready() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_brook_player = AudioStreamPlayer.new()
	_rain_player = AudioStreamPlayer.new()
	add_child(_bgm_player)
	add_child(_brook_player)
	add_child(_rain_player)

	for _i in range(SFX_POOL_SIZE):
		var p := AudioStreamPlayer.new()
		add_child(p)
		_sfx_pool.append(p)

	EventBus.sfx_requested.connect(_on_sfx_requested)
	EventBus.audio_volumes_changed.connect(apply_volumes)

	_start_ambient_loops()
	apply_volumes()


func _exit_tree() -> void:
	for p in [_bgm_player, _brook_player, _rain_player]:
		if p != null:
			p.stop()
			p.stream = null
	for sp in _sfx_pool:
		sp.stop()
		sp.stream = null
	_sfx_cache.clear()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_set_paused(true)
	elif what == NOTIFICATION_APPLICATION_RESUMED or what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_set_paused(false)


func _set_paused(p: bool) -> void:
	for pl in [_bgm_player, _brook_player, _rain_player]:
		if pl != null:
			pl.stream_paused = p


func _start_ambient_loops() -> void:
	if ResourceLoader.exists("res://assets/audio/bgm/bgm_pastoral_loop.ogg"):
		var s1 := load("res://assets/audio/bgm/bgm_pastoral_loop.ogg")
		if s1 is AudioStreamOggVorbis:
			(s1 as AudioStreamOggVorbis).loop = true
		_bgm_player.stream = s1
		_bgm_player.play()

	if ResourceLoader.exists("res://assets/audio/bgm/amb_brook_loop.ogg"):
		var s2 := load("res://assets/audio/bgm/amb_brook_loop.ogg")
		if s2 is AudioStreamOggVorbis:
			(s2 as AudioStreamOggVorbis).loop = true
		_brook_player.stream = s2
		_brook_player.play()

	if ResourceLoader.exists("res://assets/audio/bgm/amb_rain_chime_loop.ogg"):
		var s3 := load("res://assets/audio/bgm/amb_rain_chime_loop.ogg")
		if s3 is AudioStreamOggVorbis:
			(s3 as AudioStreamOggVorbis).loop = true
		_rain_player.stream = s3
		_rain_player.play()


func apply_volumes() -> void:
	var bgm_v := float(SaveManager.get_setting("bgm_volume", 0.65))
	var amb_v := float(SaveManager.get_setting("amb_volume", 0.60))
	var rain_on := bool(SaveManager.get_setting("rain_enabled", false))

	_bgm_player.volume_db = -80.0 if bgm_v <= 0.01 else linear_to_db(bgm_v * 0.55)
	_brook_player.volume_db = -80.0 if amb_v <= 0.01 else linear_to_db(amb_v * 0.45)
	_rain_player.volume_db = -80.0 if (not rain_on or amb_v <= 0.01) else linear_to_db(amb_v * 0.48)


func _on_sfx_requested(sfx_id: String, pitch_jitter: float) -> void:
	var sfx_v := float(SaveManager.get_setting("sfx_volume", 0.80))
	if sfx_v <= 0.01:
		return
	var path := "res://assets/audio/sfx/%s.ogg" % sfx_id
	if not _sfx_cache.has(path):
		if not ResourceLoader.exists(path):
			return
		_sfx_cache[path] = load(path)
	var stream: AudioStream = _sfx_cache[path]
	if stream == null:
		return
	var p := _sfx_pool[_sfx_cursor]
	_sfx_cursor = (_sfx_cursor + 1) % _sfx_pool.size()
	p.stream = stream
	p.volume_db = linear_to_db(sfx_v * 0.72)
	p.pitch_scale = randf_range(1.0 - pitch_jitter, 1.0 + pitch_jitter) if pitch_jitter > 0.0 else 1.0
	p.play()
