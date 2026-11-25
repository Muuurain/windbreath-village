class_name UiStyles
extends RefCounted
## Warm Ghibli-pastoral style factory for parchment cards, timber buttons,
## Safe Area padding, and touch-friendly scrollbars.

const COL_BG := Color(0.92, 0.95, 0.90, 1.0)
const COL_PANEL := Color(0.98, 0.95, 0.89, 0.95)
const COL_CARD := Color(0.99, 0.97, 0.92, 0.98)
const COL_BORDER := Color(0.55, 0.68, 0.56, 0.85)
const COL_SAGE := Color(0.24, 0.55, 0.38, 1.0)
const COL_BROOK := Color(0.22, 0.60, 0.72, 1.0)
const COL_GOLD := Color(0.86, 0.60, 0.16, 1.0)
const COL_TERRA := Color(0.80, 0.39, 0.28, 1.0)
const COL_WOOD := Color(0.46, 0.32, 0.20, 1.0)
const COL_TEXT := Color(0.20, 0.17, 0.14, 1.0)
const COL_TEXT_DIM := Color(0.42, 0.38, 0.34, 1.0)


static func make_panel_style(bg: Color = COL_CARD, border: Color = COL_BORDER, radius: int = 16, border_w: int = 2) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	sb.shadow_color = Color(0.12, 0.16, 0.12, 0.12)
	sb.shadow_size = 4
	return sb


static func style_button(btn: Button, accent: Color = COL_SAGE, filled: bool = true, min_h: float = 50.0) -> void:
	btn.custom_minimum_size.y = min_h
	btn.add_theme_font_size_override("font_size", 19)
	btn.add_theme_color_override("font_color", Color.WHITE if filled else COL_TEXT)
	btn.add_theme_color_override("font_hover_color", Color.WHITE if filled else COL_TEXT)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)
	btn.add_theme_color_override("font_disabled_color", Color(0.58, 0.55, 0.50))

	var normal := make_panel_style(
		accent if filled else COL_CARD,
		accent.darkened(0.18) if filled else accent,
		14,
		2
	)
	var hover := make_panel_style(
		accent.lightened(0.10) if filled else Color(0.95, 0.92, 0.85, 1.0),
		accent,
		14,
		2
	)
	var pressed := make_panel_style(
		accent.darkened(0.16),
		accent.darkened(0.25),
		14,
		2
	)
	var disabled := make_panel_style(Color(0.84, 0.82, 0.77, 0.85), Color(0.70, 0.68, 0.63, 0.7), 14, 1)

	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("disabled", disabled)


static func style_scroll(scroll: ScrollContainer) -> void:
	scroll.scroll_deadzone = 12
	scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	var grabber := StyleBoxFlat.new()
	grabber.bg_color = Color(0.24, 0.55, 0.38, 0.65)
	grabber.set_corner_radius_all(5)
	var grabber_hi := StyleBoxFlat.new()
	grabber_hi.bg_color = Color(0.24, 0.55, 0.38, 0.92)
	grabber_hi.set_corner_radius_all(5)
	var track := StyleBoxFlat.new()
	track.bg_color = Color(0.75, 0.78, 0.72, 0.35)
	track.set_corner_radius_all(5)

	for bar in [scroll.get_v_scroll_bar(), scroll.get_h_scroll_bar()]:
		if bar == null:
			continue
		bar.custom_minimum_size = Vector2(9, 9)
		bar.add_theme_stylebox_override("grabber", grabber)
		bar.add_theme_stylebox_override("grabber_highlight", grabber_hi)
		bar.add_theme_stylebox_override("grabber_pressed", grabber_hi)
		bar.add_theme_stylebox_override("scroll", track)


static func apply_safe_area_padding(ctrl: Control, base_top: float = 14.0, base_bottom: float = 16.0) -> void:
	var safe := DisplayServer.get_display_safe_area()
	var win := DisplayServer.window_get_size()
	var top_pad := base_top
	var bot_pad := base_bottom
	if win.y > 0 and safe.size.y > 0:
		var scale_y := 1280.0 / float(win.y)
		top_pad = maxf(base_top, float(safe.position.y) * scale_y + 6.0)
		var bottom_cut := float(win.y - (safe.position.y + safe.size.y))
		bot_pad = maxf(base_bottom, bottom_cut * scale_y + 8.0)
	ctrl.offset_top = top_pad
	ctrl.offset_bottom = -bot_pad


static func animate_pop_in(ctrl: Control) -> void:
	ctrl.modulate.a = 0.0
	ctrl.pivot_offset = ctrl.size * 0.5
	ctrl.scale = Vector2(0.96, 0.96)
	var tw := ctrl.create_tween()
	tw.set_parallel(true)
	tw.tween_property(ctrl, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(ctrl, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


static func trigger_haptic(ms: int = 18) -> void:
	if bool(SaveManager.get_setting("haptics", true)):
		Input.vibrate_handheld(ms)
