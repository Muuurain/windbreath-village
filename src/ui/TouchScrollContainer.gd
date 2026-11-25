class_name TouchScrollContainer
extends ScrollContainer
## Mobile-first ScrollContainer allowing touch and mouse drag scrolling even when
## gestures start on child icons, PanelContainers, or Buttons.

const DRAG_THRESHOLD := 12.0
const FLING_DECAY := 8.5
const MIN_FLING_SPEED := 35.0

const _SOURCE_NONE := 0
const _SOURCE_TOUCH := 1
const _SOURCE_MOUSE := 2

var _tracking: bool = false
var _dragging: bool = false
var _source: int = _SOURCE_NONE
var _touch_index: int = -1
var _press_pos: Vector2 = Vector2.ZERO
var _last_pos: Vector2 = Vector2.ZERO
var _remainder: Vector2 = Vector2.ZERO
var _velocity: Vector2 = Vector2.ZERO
var _last_move_msec: int = 0
var _suppress_mouse_up_until_msec: int = 0


func _ready() -> void:
	scroll_deadzone = int(DRAG_THRESHOLD)
	mouse_filter = Control.MOUSE_FILTER_PASS
	set_process_input(true)
	set_process(false)


func _process(delta: float) -> void:
	if not is_visible_in_tree() or _tracking:
		if not is_visible_in_tree():
			_reset_state()
		return

	if _velocity.length() < MIN_FLING_SPEED:
		_velocity = Vector2.ZERO
		set_process(false)
		return

	_apply_scroll_delta(_velocity * delta)
	_velocity *= exp(-FLING_DECAY * delta)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		if _tracking:
			_reset_state()
		return

	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		var pos := _to_canvas_pos(st.position)
		if st.pressed:
			if not _tracking and _can_accept_press(pos):
				_begin_track(_SOURCE_TOUCH, st.index, pos)
		elif _tracking and _source == _SOURCE_TOUCH and st.index == _touch_index:
			var was_dragging := _dragging
			_end_track()
			if was_dragging:
				_suppress_mouse_up_until_msec = Time.get_ticks_msec() + 140
				var vp := get_viewport()
				if vp != null:
					vp.set_input_as_handled()

	elif event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		if _tracking and _source == _SOURCE_TOUCH and sd.index == _touch_index:
			_handle_drag(_to_canvas_pos(sd.position))

	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return
		if not mb.pressed and Time.get_ticks_msec() <= _suppress_mouse_up_until_msec:
			var vp := get_viewport()
			if vp != null:
				vp.set_input_as_handled()
			if mb.device == InputEvent.DEVICE_ID_EMULATION:
				return
		if mb.device == InputEvent.DEVICE_ID_EMULATION:
			return
		var pos := _to_canvas_pos(mb.position)
		if mb.pressed:
			if not _tracking and _can_accept_press(pos):
				_begin_track(_SOURCE_MOUSE, -1, pos)
		elif _tracking and _source == _SOURCE_MOUSE:
			var was_dragging := _dragging
			_end_track()
			if was_dragging:
				var vp := get_viewport()
				if vp != null:
					vp.set_input_as_handled()

	elif event is InputEventMouseMotion:
		var mm := event as InputEventMouseMotion
		if mm.device == InputEvent.DEVICE_ID_EMULATION:
			return
		if _tracking and _source == _SOURCE_MOUSE:
			_handle_drag(_to_canvas_pos(mm.position))


func _to_canvas_pos(viewport_pos: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * viewport_pos


func _can_scroll_h() -> bool:
	if horizontal_scroll_mode == SCROLL_MODE_DISABLED:
		return false
	var hbar := get_h_scroll_bar()
	return hbar != null and hbar.max_value > size.x + 1.0


func _can_scroll_v() -> bool:
	if vertical_scroll_mode == SCROLL_MODE_DISABLED:
		return false
	var vbar := get_v_scroll_bar()
	return vbar != null and vbar.max_value > size.y + 1.0


func _can_accept_press(pos: Vector2) -> bool:
	if not _can_scroll_h() and not _can_scroll_v():
		return false
	if not get_global_rect().has_point(pos):
		return false
	if _is_on_visible_scrollbar(pos):
		return false
	if _is_blocked_by_overlay(pos):
		return false
	return true


func _is_on_visible_scrollbar(pos: Vector2) -> bool:
	var vbar := get_v_scroll_bar()
	if vbar != null and vbar.visible and vbar.get_global_rect().has_point(pos):
		return true
	var hbar := get_h_scroll_bar()
	if hbar != null and hbar.visible and hbar.get_global_rect().has_point(pos):
		return true
	return false


func _is_blocked_by_overlay(pos: Vector2) -> bool:
	var cur: Node = self
	while cur != null:
		var parent := cur.get_parent()
		if parent == null or parent is Viewport:
			break
		var my_idx := cur.get_index()
		for i in range(parent.get_child_count() - 1, my_idx, -1):
			var sib := parent.get_child(i)
			if sib is Control and _control_blocks_at(sib as Control, pos):
				return true
		cur = parent
	return false


func _control_blocks_at(ctrl: Control, pos: Vector2) -> bool:
	if not ctrl.visible:
		return false
	if ctrl.clip_contents and not ctrl.get_global_rect().has_point(pos):
		return false
	for i in range(ctrl.get_child_count() - 1, -1, -1):
		var ch := ctrl.get_child(i)
		if ch is Control and _control_blocks_at(ch as Control, pos):
			return true
	if ctrl.mouse_filter != Control.MOUSE_FILTER_IGNORE and ctrl.get_global_rect().has_point(pos):
		return true
	return false


func _begin_track(src: int, touch_idx: int, pos: Vector2) -> void:
	_tracking = true
	_dragging = false
	_source = src
	_touch_index = touch_idx
	_press_pos = pos
	_last_pos = pos
	_remainder = Vector2.ZERO
	_velocity = Vector2.ZERO
	_last_move_msec = Time.get_ticks_msec()
	set_process(false)


func _handle_drag(pos: Vector2) -> void:
	var can_h := _can_scroll_h()
	var can_v := _can_scroll_v()
	if not can_h and not can_v:
		_reset_state()
		return

	var delta := pos - _last_pos
	_last_pos = pos

	if not _dragging:
		var total := pos - _press_pos
		if can_h and not can_v:
			if absf(total.y) > DRAG_THRESHOLD and absf(total.y) > absf(total.x) * 1.35:
				_reset_state()
				return
			if absf(total.x) < DRAG_THRESHOLD:
				return
		elif can_v and not can_h:
			if absf(total.x) > DRAG_THRESHOLD and absf(total.x) > absf(total.y) * 1.35:
				_reset_state()
				return
			if absf(total.y) < DRAG_THRESHOLD:
				return
		elif total.length() < DRAG_THRESHOLD:
			return

		_dragging = true
		_cancel_pressed_buttons(self)
		delta = pos - _press_pos

	var now := Time.get_ticks_msec()
	var dt := maxf(0.008, float(now - _last_move_msec) / 1000.0)
	_last_move_msec = now

	var move := Vector2(
		-delta.x if can_h else 0.0,
		-delta.y if can_v else 0.0
	)
	_apply_scroll_delta(move)
	_velocity = _velocity.lerp(move / dt, 0.45)

	var vp := get_viewport()
	if vp != null:
		vp.set_input_as_handled()


func _apply_scroll_delta(move: Vector2) -> void:
	_remainder += move
	var dx := int(_remainder.x)
	var dy := int(_remainder.y)
	if dx != 0 and _can_scroll_h():
		scroll_horizontal += dx
		_remainder.x -= float(dx)
	elif not _can_scroll_h():
		_remainder.x = 0.0
	if dy != 0 and _can_scroll_v():
		scroll_vertical += dy
		_remainder.y -= float(dy)
	elif not _can_scroll_v():
		_remainder.y = 0.0


func _end_track() -> void:
	var was_dragging := _dragging
	_tracking = false
	_dragging = false
	_source = _SOURCE_NONE
	_touch_index = -1
	if was_dragging and _velocity.length() >= MIN_FLING_SPEED:
		set_process(true)
	else:
		_velocity = Vector2.ZERO


func _reset_state() -> void:
	_tracking = false
	_dragging = false
	_source = _SOURCE_NONE
	_touch_index = -1
	_velocity = Vector2.ZERO
	_remainder = Vector2.ZERO
	set_process(false)


func _cancel_pressed_buttons(node: Node) -> void:
	for ch in node.get_children():
		if ch is BaseButton:
			var btn := ch as BaseButton
			var mode := btn.get_draw_mode()
			if not btn.disabled and (mode == BaseButton.DRAW_PRESSED or mode == BaseButton.DRAW_HOVER_PRESSED):
				btn.disabled = true
				btn.disabled = false
				btn.notification(Control.NOTIFICATION_MOUSE_EXIT)
		_cancel_pressed_buttons(ch)
