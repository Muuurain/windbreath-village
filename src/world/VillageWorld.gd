class_name VillageWorld
extends Node2D
## Interactive 2.5D hex village world:
## touch/mouse camera panning & pinch/button zoom, open slot highlights,
## tap-to-preview & tap-to-confirm placement, synergy link visualization,
## floating resource/harmony popups, and ambient mood transitions.

signal slot_previewed(q: int, r: int, preview: Dictionary)
signal slot_confirmed(q: int, r: int)
signal mood_applied(mood_id: String)

const PAN_DRAG_THRESHOLD := 12.0
const MIN_ZOOM := 0.52
const MAX_ZOOM := 1.45

var _state: VillageState
var _tile_nodes: Dictionary = {} # "q,r" -> HexTileNode
var _active_tile_id: String = ""
var _active_rot: int = 0
var _preview_coord: Vector2i = Vector2i(9999, 9999)
var _preview_info: Dictionary = {}
var _preview_node: HexTileNode
var _open_slots: Array[Vector2i] = []

var _cam: Camera2D
var _canvas_mod: CanvasModulate
var _tiles_root: Node2D
var _overlay_layer: Node2D
var _villagers: VillagerManager
var _vfx_layer: Node2D

var _touches: Dictionary = {}
var _pan_tracking: bool = false
var _pan_dragging: bool = false
var _pan_start_screen: Vector2 = Vector2.ZERO
var _pan_last_screen: Vector2 = Vector2.ZERO
var _pinch_last_dist: float = 0.0
var _tick_timer: float = 0.0
var _floating_texts: Array[Dictionary] = []


func _ready() -> void:
	_canvas_mod = CanvasModulate.new()
	add_child(_canvas_mod)

	_tiles_root = Node2D.new()
	add_child(_tiles_root)

	_overlay_layer = _WorldOverlayDrawer.new(self)
	_overlay_layer.z_index = 25
	add_child(_overlay_layer)

	_preview_node = HexTileNode.new()
	_preview_node.z_index = 30
	_preview_node.visible = false
	add_child(_preview_node)

	_villagers = VillagerManager.new()
	add_child(_villagers)

	_vfx_layer = _FloatingVfxLayer.new(self)
	_vfx_layer.z_index = 60
	add_child(_vfx_layer)

	_cam = Camera2D.new()
	_cam.zoom = Vector2(0.78, 0.78)
	_cam.position = Vector2(0, 35)
	_cam.position_smoothing_enabled = true
	_cam.position_smoothing_speed = 9.0
	add_child(_cam)
	_cam.make_current()

	EventBus.synergy_triggered.connect(_on_synergy_triggered)


func bind_state(state: VillageState) -> void:
	_state = state
	_tick_timer = 0.0
	clear_preview()
	rebuild_board()
	apply_mood(_state.mood_id)
	recenter_camera()


func rebuild_board() -> void:
	for k in _tile_nodes.keys():
		var n: Node2D = _tile_nodes[k]
		if is_instance_valid(n):
			n.queue_free()
	_tile_nodes.clear()

	if _state == null:
		return
	for k in _state.board.keys():
		var entry: Dictionary = _state.board[k]
		var node := HexTileNode.new()
		node.setup(int(entry["q"]), int(entry["r"]), String(entry["id"]), int(entry["rot"]), false)
		node.set_synergy_active(not (entry.get("synergies", []) as Array).is_empty())
		_tiles_root.add_child(node)
		_tile_nodes[k] = node

	_open_slots = EcosystemEngine.get_open_slots(_state.board)
	_villagers.sync_with_state(_state, _state.mood_id)
	_update_lanterns()
	_overlay_layer.queue_redraw()


func sync_after_placement(q: int, r: int) -> void:
	var k := HexMath.key(q, r)
	if _state != null and _state.board.has(k) and not _tile_nodes.has(k):
		var entry: Dictionary = _state.board[k]
		var node := HexTileNode.new()
		node.setup(q, r, String(entry["id"]), int(entry["rot"]), false)
		_tiles_root.add_child(node)
		node.play_place_anim()
		_tile_nodes[k] = node

	# Refresh synergy stars across all placed tiles
	if _state != null:
		for tk in _tile_nodes.keys():
			if _state.board.has(tk):
				var tn := _tile_nodes[tk] as HexTileNode
				tn.set_synergy_active(not (_state.board[tk].get("synergies", []) as Array).is_empty())
		_open_slots = EcosystemEngine.get_open_slots(_state.board)
		_villagers.sync_with_state(_state, _state.mood_id)
	clear_preview()
	_update_lanterns()
	_overlay_layer.queue_redraw()


func set_active_placement(tile_id: String, rot: int) -> void:
	_active_tile_id = tile_id
	_active_rot = ((rot % 6) + 6) % 6
	if _preview_coord.x != 9999:
		_refresh_preview_at(_preview_coord)
	_overlay_layer.queue_redraw()


func clear_preview() -> void:
	_preview_coord = Vector2i(9999, 9999)
	_preview_info.clear()
	_preview_node.visible = false
	_overlay_layer.queue_redraw()


func has_active_preview() -> bool:
	return _preview_coord.x != 9999 and bool(_preview_info.get("valid", false))


func get_preview_coord() -> Vector2i:
	return _preview_coord


func _refresh_preview_at(coord: Vector2i) -> void:
	if _state == null or _active_tile_id.is_empty():
		clear_preview()
		return
	var info := EcosystemEngine.evaluate_placement_preview(_state.board, _active_tile_id, coord.x, coord.y, _active_rot)
	if not bool(info["valid"]):
		clear_preview()
		return
	_preview_coord = coord
	_preview_info = info
	_preview_node.setup(coord.x, coord.y, _active_tile_id, _active_rot, true)
	_preview_node.visible = true
	_overlay_layer.queue_redraw()
	slot_previewed.emit(coord.x, coord.y, info)


func apply_mood(mood_id: String) -> void:
	var mdef := GameData.get_mood(mood_id)
	if mdef.is_empty():
		return
	if _state != null:
		_state.mood_id = mood_id
	var tw := create_tween()
	tw.tween_property(_canvas_mod, "color", Color(mdef["tint"]), 0.45)
	_update_lanterns()
	if _state != null:
		_villagers.sync_with_state(_state, mood_id)
	mood_applied.emit(mood_id)


func _update_lanterns() -> void:
	if _state == null:
		return
	var power := float(GameData.get_mood(_state.mood_id).get("lantern_power", 0.25))
	for tk in _tile_nodes.keys():
		(_tile_nodes[tk] as HexTileNode).set_lantern_power(power)


func zoom_by(factor: float) -> void:
	var z := clampf(_cam.zoom.x * factor, MIN_ZOOM, MAX_ZOOM)
	_cam.zoom = Vector2(z, z)


func recenter_camera() -> void:
	if _state == null or _state.board.is_empty():
		_cam.position = Vector2(0, 35)
		return
	var avg := Vector2.ZERO
	for k in _state.board.keys():
		var p := HexMath.parse_key(String(k))
		avg += HexMath.axial_to_pixel(p.x, p.y)
	_cam.position = avg / float(_state.board.size()) + Vector2(0, 35)


func spawn_floating_label(world_pos: Vector2, text: String, col: Color) -> void:
	_floating_texts.append({
		"pos": world_pos + Vector2(0, -36),
		"text": text,
		"color": col,
		"life": 1.35,
		"max_life": 1.35,
	})


func _on_synergy_triggered(q: int, r: int, label: String, color: Color) -> void:
	spawn_floating_label(HexMath.axial_to_pixel(q, r), label, color)


func _process(delta: float) -> void:
	if visible and _state != null:
		_state.elapsed_seconds += delta
		_tick_timer += delta
		if _tick_timer >= 6.5:
			_tick_timer = 0.0
			var gained := _state.produce_tick_yield()
			if not gained.is_empty() and not _state.board.is_empty():
				var keys := _state.board.keys()
				var rk := String(keys[randi() % keys.size()])
				var pos := HexMath.parse_key(rk)
				var first_k := String(gained.keys()[0])
				var label_map := {"grain": "稻穗", "tea": "茶香", "bamboo": "竹木"}
				spawn_floating_label(
					HexMath.axial_to_pixel(pos.x, pos.y),
					"+%d %s" % [int(gained[first_k]), String(label_map.get(first_k, ""))],
					Color(1.0, 0.96, 0.72)
				)
				EventBus.sfx_requested.emit("sfx_resource_pop", 0.08)

	for i in range(_floating_texts.size() - 1, -1, -1):
		var ft: Dictionary = _floating_texts[i]
		ft["life"] = float(ft["life"]) - delta
		ft["pos"] = Vector2(ft["pos"]) + Vector2(0, -28.0 * delta)
		if float(ft["life"]) <= 0.0:
			_floating_texts.remove_at(i)
	if not _floating_texts.is_empty() or _vfx_layer != null:
		_vfx_layer.queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return

	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			_touches[st.index] = st.position
			if _touches.size() == 1:
				_pan_tracking = true
				_pan_dragging = false
				_pan_start_screen = st.position
				_pan_last_screen = st.position
			elif _touches.size() == 2:
				_pan_dragging = true
				_pinch_last_dist = _calc_pinch_dist()
		else:
			var was_drag := _pan_dragging
			var tap_pos := st.position
			_touches.erase(st.index)
			if _touches.is_empty():
				_pan_tracking = false
				_pan_dragging = false
				if not was_drag:
					_handle_world_tap(tap_pos)

	elif event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		_touches[sd.index] = sd.position
		if _touches.size() >= 2:
			var new_dist := _calc_pinch_dist()
			if _pinch_last_dist > 10.0 and new_dist > 10.0:
				zoom_by(new_dist / _pinch_last_dist)
			_pinch_last_dist = new_dist
		elif _pan_tracking:
			_handle_pan_move(sd.position)

	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.device == InputEvent.DEVICE_ID_EMULATION:
			return
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			zoom_by(1.1)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			zoom_by(0.9)
		elif mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_pan_tracking = true
				_pan_dragging = false
				_pan_start_screen = mb.position
				_pan_last_screen = mb.position
			else:
				var was_drag := _pan_dragging
				_pan_tracking = false
				_pan_dragging = false
				if not was_drag:
					_handle_world_tap(mb.position)

	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if mm.device == InputEvent.DEVICE_ID_EMULATION:
			return
		if _pan_tracking:
			_handle_pan_move(mm.position)


func _calc_pinch_dist() -> float:
	var pts := _touches.values()
	if pts.size() < 2:
		return 0.0
	return Vector2(pts[0]).distance_to(Vector2(pts[1]))


func _handle_pan_move(screen_pos: Vector2) -> void:
	if not _pan_dragging and screen_pos.distance_to(_pan_start_screen) >= PAN_DRAG_THRESHOLD:
		_pan_dragging = true
	if _pan_dragging:
		var delta := screen_pos - _pan_last_screen
		_cam.position -= delta / _cam.zoom.x
	_pan_last_screen = screen_pos


func _handle_world_tap(screen_pos: Vector2) -> void:
	if _state == null or _active_tile_id.is_empty():
		return
	var world_pos := get_viewport().get_canvas_transform().affine_inverse() * screen_pos
	var coord := HexMath.pixel_to_axial(world_pos)
	if not EcosystemEngine.can_place_at(_state.board, coord.x, coord.y):
		return

	if _preview_coord == coord:
		slot_confirmed.emit(coord.x, coord.y)
	else:
		EventBus.sfx_requested.emit("sfx_tile_select", 0.05)
		_refresh_preview_at(coord)


class _WorldOverlayDrawer extends Node2D:
	var _owner: VillageWorld

	func _init(owner_world: VillageWorld) -> void:
		_owner = owner_world

	func _draw() -> void:
		if _owner._state == null or _owner._active_tile_id.is_empty():
			return
		var poly := HexMath.hex_polygon(HexMath.HEX_RADIUS - 5.0)
		for coord in _owner._open_slots:
			var center := HexMath.axial_to_pixel(coord.x, coord.y)
			var is_sel := (coord == _owner._preview_coord)
			var line_col := Color(1.0, 0.85, 0.25, 0.95) if is_sel else Color(1.0, 1.0, 1.0, 0.42)
			var fill_col := Color(1.0, 0.88, 0.35, 0.16) if is_sel else Color(1.0, 1.0, 1.0, 0.06)
			var pts := PackedVector2Array()
			for p in poly:
				pts.append(center + p)
			draw_colored_polygon(pts, fill_col)
			pts.append(pts[0])
			draw_polyline(pts, line_col, 4.0 if is_sel else 2.2, true)

		# Highlight synergy links when previewing a slot
		if _owner.has_active_preview():
			var origin := HexMath.axial_to_pixel(_owner._preview_coord.x, _owner._preview_coord.y)
			var hcoords: Array = _owner._preview_info.get("highlight_coords", [])
			for nb in hcoords:
				var target := HexMath.axial_to_pixel((nb as Vector2i).x, (nb as Vector2i).y)
				draw_line(origin, target, Color(0.98, 0.84, 0.22, 0.9), 5.0, true)
				draw_circle(target, 12.0, Color(0.98, 0.84, 0.22, 0.75))


class _FloatingVfxLayer extends Node2D:
	var _owner: VillageWorld

	func _init(owner_world: VillageWorld) -> void:
		_owner = owner_world

	func _draw() -> void:
		var font := ThemeDB.fallback_font
		if font == null:
			return
		for ft in _owner._floating_texts:
			var alpha := clampf(float(ft["life"]) / maxf(0.1, float(ft["max_life"])), 0.0, 1.0)
			var col := Color(ft["color"])
			col.a = alpha
			var pos := Vector2(ft["pos"])
			var txt := String(ft["text"])
			draw_string(font, pos + Vector2(-42, 2), txt, HORIZONTAL_ALIGNMENT_CENTER, 84, 20, Color(0.10, 0.08, 0.05, alpha * 0.85))
			draw_string(font, pos + Vector2(-42, 0), txt, HORIZONTAL_ALIGNMENT_CENTER, 84, 20, col)
