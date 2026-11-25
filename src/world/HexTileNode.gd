class_name HexTileNode
extends Node2D
## Visual representation of a single flat-top hexagonal tile on the 2.5D map:
## base meadow hex texture + seamless edge-matched river/road splines +
## Nanobanana prop/landmark sprite with optional wind-sway & lantern glow.

var q: int = 0
var r: int = 0
var tile_id: String = ""
var rot: int = 0
var is_preview: bool = false

var _base_sprite: Sprite2D
var _channel_layer: Node2D
var _prop_sprite: Sprite2D
var _lantern_glow: Sprite2D
var _syn_badge: Sprite2D
var _edges: Array[String] = []
var _is_water: bool = false


func setup(p_q: int, p_r: int, p_tile_id: String, p_rot: int, p_preview: bool = false) -> void:
	q = p_q
	r = p_r
	tile_id = p_tile_id
	rot = ((p_rot % 6) + 6) % 6
	is_preview = p_preview
	position = HexMath.axial_to_pixel(q, r)
	z_index = q + r * 2

	_clear_children()
	_build_visuals()


func _clear_children() -> void:
	for c in get_children():
		c.queue_free()
	_base_sprite = null
	_channel_layer = null
	_prop_sprite = null
	_lantern_glow = null
	_syn_badge = null


func _build_visuals() -> void:
	var tdef := GameData.get_tile(tile_id)
	if tdef.is_empty():
		return

	_edges = HexMath.rotated_edges(tdef.get("edges", []), rot)
	_is_water = bool(tdef.get("is_water", false))

	# 1. Base Hex Texture
	var base_path := String(tdef.get("base_tex", "res://assets/art/tiles/hex_base_grass.png"))
	if ResourceLoader.exists(base_path):
		_base_sprite = Sprite2D.new()
		_base_sprite.texture = load(base_path)
		add_child(_base_sprite)

	# 2. Custom River / Road Channel Overlay (aligned to exact 60° edge midpoints)
	_channel_layer = _ChannelDrawer.new(_edges, _is_water, tile_id == "tile_pond")
	add_child(_channel_layer)

	# 3. Prop or Wonder Landmark Sprite
	var prop_path := String(tdef.get("prop_tex", ""))
	if not prop_path.is_empty() and ResourceLoader.exists(prop_path):
		_prop_sprite = Sprite2D.new()
		_prop_sprite.texture = load(prop_path)
		var is_wonder := String(tdef.get("category", "")) == "wonder" or tile_id == "tile_road_cottage"
		_prop_sprite.scale = Vector2.ONE * (0.74 if is_wonder else 0.72)
		_prop_sprite.position = Vector2(0, -24 if is_wonder else -12)

		if bool(tdef.get("sway", false)) and ResourceLoader.exists("res://assets/shaders/wind_sway.gdshader"):
			var smat := ShaderMaterial.new()
			smat.shader = load("res://assets/shaders/wind_sway.gdshader")
			smat.set_shader_parameter("phase_offset", float(q * 1.7 + r * 2.3))
			_prop_sprite.material = smat
		elif tile_id == "tile_pond" and ResourceLoader.exists("res://assets/shaders/water_shimmer.gdshader"):
			var wmat := ShaderMaterial.new()
			wmat.shader = load("res://assets/shaders/water_shimmer.gdshader")
			_prop_sprite.material = wmat

		add_child(_prop_sprite)

	# 4. Warm Lantern Halo (for cottages & wonders, shines softly at dusk/night)
	if bool(tdef.get("has_lantern", false)) and ResourceLoader.exists("res://assets/art/ui/glow_soft.png"):
		_lantern_glow = Sprite2D.new()
		_lantern_glow.texture = load("res://assets/art/ui/glow_soft.png")
		_lantern_glow.scale = Vector2.ONE * 1.9
		_lantern_glow.position = Vector2(0, -14)
		_lantern_glow.modulate = Color(1.0, 0.80, 0.36, 0.15)
		if ResourceLoader.exists("res://assets/shaders/lantern_glow.gdshader"):
			var lmat := ShaderMaterial.new()
			lmat.shader = load("res://assets/shaders/lantern_glow.gdshader")
			_lantern_glow.material = lmat
		add_child(_lantern_glow)

	# 5. Subtle Synergy Star Badge
	if not is_preview and ResourceLoader.exists("res://assets/art/ui/glow_soft.png"):
		_syn_badge = Sprite2D.new()
		_syn_badge.texture = load("res://assets/art/ui/glow_soft.png")
		_syn_badge.scale = Vector2.ONE * 0.36
		_syn_badge.position = Vector2(68, -48)
		_syn_badge.modulate = Color(1.0, 0.90, 0.35, 0.85)
		_syn_badge.visible = false
		add_child(_syn_badge)

	if is_preview:
		modulate = Color(1.0, 1.0, 1.0, 0.84)


func set_synergy_active(active: bool) -> void:
	if _syn_badge != null:
		_syn_badge.visible = active


func set_lantern_power(power: float) -> void:
	if _lantern_glow != null:
		_lantern_glow.modulate.a = clampf(power * 0.55, 0.08, 0.90)
		if _lantern_glow.material is ShaderMaterial:
			(_lantern_glow.material as ShaderMaterial).set_shader_parameter("intensity", power)


func play_place_anim() -> void:
	scale = Vector2(0.55, 0.55)
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2(1.07, 1.07), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.12)


class _ChannelDrawer extends Node2D:
	var _edges: Array[String]
	var _is_water: bool
	var _is_pond: bool

	func _init(edges: Array[String], is_water: bool, is_pond: bool) -> void:
		_edges = edges
		_is_water = is_water
		_is_pond = is_pond

	func _draw() -> void:
		var river_pts: Array[Vector2] = []
		var road_pts: Array[Vector2] = []
		for i in range(6):
			var mp := HexMath.edge_midpoint(i, HexMath.HEX_RADIUS)
			if _edges[i] == "river":
				river_pts.append(mp)
			elif _edges[i] == "road":
				road_pts.append(mp)

		if not river_pts.is_empty():
			_draw_channel_set(river_pts, Color(0.32, 0.64, 0.68, 0.92), Color(0.45, 0.82, 0.90, 0.96), Color(0.84, 0.97, 1.0, 0.65), 34.0)
			if _is_water and not _is_pond and river_pts.size() != 2:
				draw_circle(Vector2.ZERO, 17.0, Color(0.45, 0.82, 0.90, 0.96))

		if not road_pts.is_empty():
			_draw_channel_set(road_pts, Color(0.64, 0.54, 0.40, 0.88), Color(0.91, 0.84, 0.70, 0.95), Color(0.98, 0.94, 0.86, 0.55), 22.0)

	func _draw_channel_set(pts: Array[Vector2], bank_col: Color, fill_col: Color, hi_col: Color, width: float) -> void:
		if pts.size() == 2:
			_draw_curved_band(pts[0], Vector2.ZERO, pts[1], bank_col, width + 6.0)
			_draw_curved_band(pts[0], Vector2.ZERO, pts[1], fill_col, width)
			_draw_curved_band(pts[0], Vector2.ZERO, pts[1], hi_col, width * 0.28)
		else:
			for p in pts:
				draw_line(Vector2.ZERO, p, bank_col, width + 6.0, true)
			for p in pts:
				draw_line(Vector2.ZERO, p, fill_col, width, true)
			for p in pts:
				draw_line(Vector2.ZERO, p, hi_col, width * 0.28, true)
			draw_circle(Vector2.ZERO, width * 0.52, fill_col)

	func _draw_curved_band(a: Vector2, ctrl: Vector2, b: Vector2, col: Color, w: float) -> void:
		var segs := 10
		var poly := PackedVector2Array()
		for i in range(segs + 1):
			var t := float(i) / float(segs)
			var u := 1.0 - t
			poly.append(u * u * a + 2.0 * u * t * ctrl + t * t * b)
		draw_polyline(poly, col, w, true)
