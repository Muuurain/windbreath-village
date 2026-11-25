class_name VillagerManager
extends Node2D
## Manages living villagers, cozy animals (orange cat, snowy egret, snowfox, traveler),
## and seasonal ambient particles (drifting blossom petals & fireflies).

var _state: VillageState
var _actors: Dictionary = {} # resident_id -> Dict{node, sprite, pos, target, speed, wait, kind}
var _particles: Array[Dictionary] = []
var _is_night: bool = false
var _tex_glow: Texture2D


func _ready() -> void:
	if ResourceLoader.exists("res://assets/art/ui/glow_soft.png"):
		_tex_glow = load("res://assets/art/ui/glow_soft.png")
	_init_ambient_particles()


func _init_ambient_particles() -> void:
	_particles.clear()
	for i in range(24):
		_particles.append({
			"pos": Vector2(randf_range(-520, 520), randf_range(-620, 620)),
			"vel": Vector2(randf_range(14, 28), randf_range(16, 30)),
			"phase": randf() * TAU,
			"size": randf_range(2.4, 4.4),
		})


func sync_with_state(state: VillageState, mood_id: String) -> void:
	_state = state
	_is_night = (mood_id == "night")

	for rid in _state.unlocked_residents:
		if not _actors.has(rid):
			_spawn_actor(rid)


func clear_all() -> void:
	for k in _actors.keys():
		var n: Node2D = _actors[k]["node"]
		if is_instance_valid(n):
			n.queue_free()
	_actors.clear()


func _spawn_actor(rid: String) -> void:
	var rdef := GameData.get_resident(rid)
	if rdef.is_empty():
		return
	var holder := Node2D.new()
	holder.z_index = 40

	var sp := Sprite2D.new()
	var sp_path := String(rdef.get("sprite", ""))
	if ResourceLoader.exists(sp_path):
		sp.texture = load(sp_path)
	sp.scale = Vector2.ONE * (0.34 if rid in ["res_cat_orange", "res_snowfox", "res_egret"] else 0.38)
	sp.position = Vector2(0, -18)
	holder.add_child(sp)

	var spawn_pos := _pick_home_pixel(rdef.get("home_types", []))
	holder.position = spawn_pos
	add_child(holder)

	# Pop-in welcome animation
	holder.scale = Vector2(0.2, 0.2)
	var tw := holder.create_tween()
	tw.tween_property(holder, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var kind := "walker"
	if rid == "res_cat_orange":
		kind = "napper"
	elif rid == "res_egret":
		kind = "glider"
	elif rid == "res_snowfox":
		kind = "roamer"

	_actors[rid] = {
		"node": holder,
		"sprite": sp,
		"pos": spawn_pos,
		"target": spawn_pos,
		"speed": 46.0 if kind == "walker" else (58.0 if kind == "glider" else 34.0),
		"wait": randf_range(0.5, 2.0),
		"kind": kind,
		"bob_t": randf() * TAU,
		"home_types": rdef.get("home_types", []),
	}


func _pick_home_pixel(home_types: Array) -> Vector2:
	if _state == null or _state.board.is_empty():
		return Vector2.ZERO
	var preferred: Array[Vector2] = []
	var fallback: Array[Vector2] = []
	for k in _state.board.keys():
		var e: Dictionary = _state.board[k]
		var px := HexMath.axial_to_pixel(int(e["q"]), int(e["r"]))
		fallback.append(px)
		if home_types.has(String(e["id"])):
			preferred.append(px)
	var pool := preferred if not preferred.is_empty() else fallback
	return pool[randi() % pool.size()] + Vector2(randf_range(-24, 24), randf_range(-16, 16))


func _pick_next_target(act: Dictionary) -> Vector2:
	if _state == null or _state.board.is_empty():
		return Vector2.ZERO
	var kind := String(act["kind"])
	if kind == "walker" and not _state.road_edges.is_empty():
		var edge: Array = _state.road_edges[randi() % _state.road_edges.size()]
		var pick: Vector2i = edge[randi() % 2]
		return HexMath.axial_to_pixel(pick.x, pick.y) + Vector2(randf_range(-14, 14), randf_range(-10, 10))
	if kind == "glider" and not _state.water_edges.is_empty():
		var edge: Array = _state.water_edges[randi() % _state.water_edges.size()]
		var pick: Vector2i = edge[randi() % 2]
		return HexMath.axial_to_pixel(pick.x, pick.y) + Vector2(randf_range(-18, 18), randf_range(-14, 14))
	return _pick_home_pixel(act["home_types"])


func _process(delta: float) -> void:
	for rid in _actors.keys():
		var act: Dictionary = _actors[rid]
		var holder: Node2D = act["node"]
		var sp: Sprite2D = act["sprite"]
		act["bob_t"] = float(act["bob_t"]) + delta * 5.2

		if String(act["kind"]) == "napper":
			var breath := sin(float(act["bob_t"]) * 0.45) * 0.04
			sp.scale = Vector2(0.34 * (1.0 + breath), 0.34 * (1.0 - breath))
			continue

		var wait := float(act["wait"])
		if wait > 0.0:
			act["wait"] = wait - delta
			sp.position.y = -18.0 + sin(float(act["bob_t"]) * 0.5) * 1.5
			if float(act["wait"]) <= 0.0:
				act["target"] = _pick_next_target(act)
			continue

		var pos := Vector2(act["pos"])
		var target := Vector2(act["target"])
		var diff := target - pos
		var dist := diff.length()
		if dist < 6.0:
			act["wait"] = randf_range(1.6, 3.8)
			sp.position.y = -18.0
			continue

		var step := minf(dist, float(act["speed"]) * delta)
		pos += diff.normalized() * step
		act["pos"] = pos
		holder.position = pos
		sp.flip_h = diff.x < -1.0
		sp.position.y = -18.0 - absf(sin(float(act["bob_t"]))) * 4.5

	# Ambient petals / fireflies drift
	for p in _particles:
		var vel := Vector2(p["vel"])
		p["phase"] = float(p["phase"]) + delta * 1.8
		var pos := Vector2(p["pos"])
		if _is_night:
			pos += Vector2(sin(float(p["phase"])) * 16.0, cos(float(p["phase"]) * 0.7) * 12.0) * delta
		else:
			pos += vel * delta
			if pos.x > 640.0:
				pos.x = -640.0
			if pos.y > 700.0:
				pos.y = -700.0
		p["pos"] = pos
	queue_redraw()


func _draw() -> void:
	for p in _particles:
		var pos := Vector2(p["pos"])
		var sz := float(p["size"])
		if _is_night:
			var pulse := 0.45 + 0.55 * absf(sin(float(p["phase"])))
			if _tex_glow != null:
				draw_texture_rect(_tex_glow, Rect2(pos - Vector2(sz * 4.0, sz * 4.0), Vector2(sz * 8.0, sz * 8.0)), false, Color(0.95, 0.92, 0.45, 0.55 * pulse))
			draw_circle(pos, sz * 0.65, Color(1.0, 0.96, 0.65, 0.9 * pulse))
		else:
			draw_circle(pos, sz, Color(1.0, 0.88, 0.92, 0.65))
