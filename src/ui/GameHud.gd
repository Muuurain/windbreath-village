class_name GameHud
extends CanvasLayer
## Portrait-first mobile HUD for Windbreath Village:
## top resource/mood/goal bar, floating zoom/undo controls, live slot preview bar,
## switchable Hand Tray / Wonder Craft bottom dock, clean scenic mode, and modals.

signal hand_selected(idx: int)
signal hand_cycled(idx: int)
signal wonder_selected(wonder_id: String)
signal rotate_requested()
signal confirm_place_requested()
signal undo_requested()
signal recenter_requested()
signal zoom_requested(factor: float)
signal mood_cycle_requested()
signal next_chapter_requested(next_ch_id: String)
signal restart_chapter_requested()
signal exit_menu_requested()
signal guide_requested()
signal tutorial_replay_requested()

var _state: VillageState
var _selected_mode: String = "hand" # "hand" | "wonder"
var _selected_hand_idx: int = 0
var _selected_wonder_id: String = ""
var _active_rot: int = 0
var _dock_tab: int = 0 # 0=hand, 1=wonders
var _clean_view: bool = false
var _tutorial_coach: TutorialCoach

var _root: Control
var _chrome_box: Control
var _restore_btn: Button
var _title_lbl: Label
var _mood_btn: Button
var _grain_lbl: Label
var _tea_lbl: Label
var _bamboo_lbl: Label
var _harmony_lbl: Label
var _resident_lbl: Label
var _goals_panel: PanelContainer
var _goals_lbl: Label
var _undo_btn: Button
var _toast_panel: PanelContainer
var _toast_lbl: Label
var _toast_timer: float = 0.0

var _preview_bar: PanelContainer
var _preview_lbl: Label
var _tab_hand_btn: Button
var _tab_wonder_btn: Button
var _hand_box: HBoxContainer
var _wonder_scroll: TouchScrollContainer
var _wonder_box: HBoxContainer

var _pause_backdrop: ColorRect
var _pause_modal: PanelContainer
var _clear_backdrop: ColorRect
var _clear_modal: PanelContainer
var _clear_img: TextureRect
var _clear_title_lbl: Label
var _clear_caption_lbl: Label
var _clear_next_btn: Button
var _clear_next_id: String = ""


func _ready() -> void:
	layer = 20
	_build_ui()


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_chrome_box = Control.new()
	_chrome_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_chrome_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UiStyles.apply_safe_area_padding(_chrome_box, 12.0, 14.0)
	_root.add_child(_chrome_box)

	# Scenic Clean-View Restore Pill
	_restore_btn = Button.new()
	_restore_btn.text = "显示界面"
	_restore_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_restore_btn.offset_left = -124
	_restore_btn.offset_right = -14
	_restore_btn.offset_top = 24
	_restore_btn.offset_bottom = 66
	_restore_btn.visible = false
	UiStyles.style_button(_restore_btn, UiStyles.COL_WOOD, true, 42.0)
	_restore_btn.add_theme_font_size_override("font_size", 15)
	_restore_btn.pressed.connect(func(): _set_clean_view(false))
	_root.add_child(_restore_btn)

	# TOP HUD STACK
	var top_v := VBoxContainer.new()
	top_v.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_v.offset_left = 12
	top_v.offset_right = -12
	top_v.offset_top = 4
	top_v.add_theme_constant_override("separation", 6)
	top_v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chrome_box.add_child(top_v)

	# Row 1: Menu + Title + Mood + Scenic Mode
	var row1_p := PanelContainer.new()
	row1_p.add_theme_stylebox_override("panel", UiStyles.make_panel_style(UiStyles.COL_PANEL, UiStyles.COL_SAGE, 14, 2))
	top_v.add_child(row1_p)

	var row1_v := VBoxContainer.new()
	row1_v.add_theme_constant_override("separation", 6)
	row1_p.add_child(row1_v)

	var r1 := HBoxContainer.new()
	r1.add_theme_constant_override("separation", 6)
	row1_v.add_child(r1)

	var menu_btn := Button.new()
	menu_btn.text = "菜单"
	menu_btn.custom_minimum_size = Vector2(64, 40)
	UiStyles.style_button(menu_btn, UiStyles.COL_WOOD, false, 40.0)
	menu_btn.add_theme_font_size_override("font_size", 15)
	menu_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		_pause_backdrop.visible = true
		UiStyles.animate_pop_in(_pause_modal)
	)
	r1.add_child(menu_btn)

	_title_lbl = Label.new()
	_title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_lbl.text = "风息村落"
	_title_lbl.add_theme_font_size_override("font_size", 17)
	_title_lbl.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	r1.add_child(_title_lbl)

	var guide_btn := Button.new()
	guide_btn.name = "HudGuideButton"
	guide_btn.text = "玩法"
	guide_btn.custom_minimum_size = Vector2(64, 40)
	UiStyles.style_button(guide_btn, UiStyles.COL_GOLD, true, 40.0)
	guide_btn.add_theme_font_size_override("font_size", 14)
	guide_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		guide_requested.emit()
	)
	r1.add_child(guide_btn)

	_mood_btn = Button.new()
	_mood_btn.text = "午后暖阳"
	_mood_btn.custom_minimum_size = Vector2(92, 40)
	UiStyles.style_button(_mood_btn, UiStyles.COL_GOLD, false, 40.0)
	_mood_btn.add_theme_font_size_override("font_size", 14)
	_mood_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		mood_cycle_requested.emit()
	)
	r1.add_child(_mood_btn)

	var clean_btn := Button.new()
	clean_btn.text = "赏景"
	clean_btn.custom_minimum_size = Vector2(62, 40)
	UiStyles.style_button(clean_btn, UiStyles.COL_BROOK, false, 40.0)
	clean_btn.add_theme_font_size_override("font_size", 14)
	clean_btn.pressed.connect(func(): _set_clean_view(true))
	r1.add_child(clean_btn)

	# Row 2: Resources & Residents
	var res_h := HBoxContainer.new()
	res_h.add_theme_constant_override("separation", 10)
	row1_v.add_child(res_h)

	_grain_lbl = _make_res_pill(res_h, "res://assets/art/ui/icon_grain.png", UiStyles.COL_GOLD)
	_tea_lbl = _make_res_pill(res_h, "res://assets/art/ui/icon_tea.png", UiStyles.COL_SAGE)
	_bamboo_lbl = _make_res_pill(res_h, "res://assets/art/ui/icon_bamboo.png", Color(0.24, 0.54, 0.32))
	_harmony_lbl = _make_res_pill(res_h, "res://assets/art/ui/icon_harmony.png", UiStyles.COL_TERRA)

	_resident_lbl = Label.new()
	_resident_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_resident_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_resident_lbl.add_theme_font_size_override("font_size", 14)
	_resident_lbl.add_theme_color_override("font_color", UiStyles.COL_BROOK)
	res_h.add_child(_resident_lbl)

	# Chapter Goals Pill
	_goals_panel = PanelContainer.new()
	_goals_panel.add_theme_stylebox_override("panel", UiStyles.make_panel_style(Color(0.99, 0.97, 0.92, 0.90), UiStyles.COL_BORDER, 12, 1))
	top_v.add_child(_goals_panel)

	_goals_lbl = Label.new()
	_goals_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_goals_lbl.add_theme_font_size_override("font_size", 14)
	_goals_lbl.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	_goals_panel.add_child(_goals_lbl)

	# Toast Notification Pill
	_toast_panel = PanelContainer.new()
	_toast_panel.visible = false
	_toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_panel.add_theme_stylebox_override("panel", UiStyles.make_panel_style(Color(0.18, 0.34, 0.24, 0.95), UiStyles.COL_GOLD, 16, 2))
	top_v.add_child(_toast_panel)

	_toast_lbl = Label.new()
	_toast_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast_lbl.add_theme_font_size_override("font_size", 16)
	_toast_lbl.add_theme_color_override("font_color", Color.WHITE)
	_toast_panel.add_child(_toast_lbl)

	# RIGHT SIDE FLOATING ZOOM & UNDO CONTROLS
	var side_v := VBoxContainer.new()
	side_v.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	side_v.offset_left = -74
	side_v.offset_right = -12
	side_v.offset_top = -95
	side_v.offset_bottom = 95
	side_v.add_theme_constant_override("separation", 8)
	_chrome_box.add_child(side_v)

	_undo_btn = Button.new()
	_undo_btn.text = "撤回"
	UiStyles.style_button(_undo_btn, UiStyles.COL_TERRA, false, 44.0)
	_undo_btn.add_theme_font_size_override("font_size", 14)
	_undo_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		undo_requested.emit()
	)
	side_v.add_child(_undo_btn)

	var rec_btn := Button.new()
	rec_btn.text = "居中"
	UiStyles.style_button(rec_btn, UiStyles.COL_WOOD, false, 44.0)
	rec_btn.add_theme_font_size_override("font_size", 14)
	rec_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		recenter_requested.emit()
	)
	side_v.add_child(rec_btn)

	var zin_btn := Button.new()
	zin_btn.text = "+"
	UiStyles.style_button(zin_btn, UiStyles.COL_SAGE, false, 42.0)
	zin_btn.pressed.connect(func(): zoom_requested.emit(1.16))
	side_v.add_child(zin_btn)

	var zout_btn := Button.new()
	zout_btn.text = "-"
	UiStyles.style_button(zout_btn, UiStyles.COL_SAGE, false, 42.0)
	zout_btn.pressed.connect(func(): zoom_requested.emit(0.86))
	side_v.add_child(zout_btn)

	# BOTTOM DOCK (Preview Bar + Tab Switcher + Hand/Wonder Shelf)
	var bot_v := VBoxContainer.new()
	bot_v.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bot_v.offset_left = 12
	bot_v.offset_right = -12
	bot_v.offset_top = -310
	bot_v.offset_bottom = -4
	bot_v.alignment = BoxContainer.ALIGNMENT_END
	bot_v.add_theme_constant_override("separation", 8)
	bot_v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_chrome_box.add_child(bot_v)

	# Live Preview Confirm Bar
	_preview_bar = PanelContainer.new()
	_preview_bar.visible = false
	_preview_bar.add_theme_stylebox_override("panel", UiStyles.make_panel_style(Color(0.99, 0.97, 0.90, 0.96), UiStyles.COL_GOLD, 14, 2))
	bot_v.add_child(_preview_bar)

	var pv_h := HBoxContainer.new()
	pv_h.add_theme_constant_override("separation", 8)
	_preview_bar.add_child(pv_h)

	_preview_lbl = Label.new()
	_preview_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_preview_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preview_lbl.add_theme_font_size_override("font_size", 14)
	_preview_lbl.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	pv_h.add_child(_preview_lbl)

	var rot_btn := Button.new()
	rot_btn.text = "旋转"
	rot_btn.custom_minimum_size = Vector2(76, 46)
	UiStyles.style_button(rot_btn, UiStyles.COL_BROOK, true, 46.0)
	rot_btn.add_theme_font_size_override("font_size", 16)
	rot_btn.pressed.connect(func(): rotate_requested.emit())
	pv_h.add_child(rot_btn)

	var ok_btn := Button.new()
	ok_btn.text = "放置"
	ok_btn.custom_minimum_size = Vector2(88, 46)
	UiStyles.style_button(ok_btn, UiStyles.COL_SAGE, true, 46.0)
	ok_btn.add_theme_font_size_override("font_size", 16)
	ok_btn.pressed.connect(func(): confirm_place_requested.emit())
	pv_h.add_child(ok_btn)

	# Dock Container
	var dock_p := PanelContainer.new()
	dock_p.add_theme_stylebox_override("panel", UiStyles.make_panel_style(UiStyles.COL_PANEL, UiStyles.COL_SAGE, 16, 2))
	bot_v.add_child(dock_p)

	var dock_v := VBoxContainer.new()
	dock_v.add_theme_constant_override("separation", 8)
	dock_p.add_child(dock_v)

	var tab_h := HBoxContainer.new()
	tab_h.add_theme_constant_override("separation", 8)
	dock_v.add_child(tab_h)

	_tab_hand_btn = Button.new()
	_tab_hand_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_hand_btn.text = "地块行囊 (点选旋转)"
	UiStyles.style_button(_tab_hand_btn, UiStyles.COL_SAGE, true, 40.0)
	_tab_hand_btn.add_theme_font_size_override("font_size", 15)
	_tab_hand_btn.pressed.connect(func():
		_dock_tab = 0
		_selected_mode = "hand"
		_refresh_dock()
		hand_selected.emit(_selected_hand_idx)
	)
	tab_h.add_child(_tab_hand_btn)

	_tab_wonder_btn = Button.new()
	_tab_wonder_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_wonder_btn.text = "风物工坊"
	UiStyles.style_button(_tab_wonder_btn, UiStyles.COL_GOLD, false, 40.0)
	_tab_wonder_btn.add_theme_font_size_override("font_size", 15)
	_tab_wonder_btn.pressed.connect(func():
		_dock_tab = 1
		_refresh_dock()
	)
	tab_h.add_child(_tab_wonder_btn)

	_hand_box = HBoxContainer.new()
	_hand_box.add_theme_constant_override("separation", 8)
	_hand_box.custom_minimum_size.y = 148
	dock_v.add_child(_hand_box)

	_wonder_scroll = TouchScrollContainer.new()
	_wonder_scroll.custom_minimum_size.y = 148
	_wonder_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_wonder_scroll.scroll_horizontal_by_default = true
	_wonder_scroll.visible = false
	UiStyles.style_scroll(_wonder_scroll)
	dock_v.add_child(_wonder_scroll)

	_wonder_box = HBoxContainer.new()
	_wonder_box.add_theme_constant_override("separation", 8)
	_wonder_scroll.add_child(_wonder_box)

	_tutorial_coach = TutorialCoach.new()
	_tutorial_coach.tutorial_finished.connect(func(): SaveManager.set_tutorial_seen(true))
	_tutorial_coach.tutorial_skipped.connect(func(): SaveManager.set_tutorial_seen(true))
	_chrome_box.add_child(_tutorial_coach)

	_build_pause_modal()
	_build_clear_modal()


func _make_res_pill(parent: HBoxContainer, icon_path: String, col: Color) -> Label:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 4)
	parent.add_child(h)
	var ic := TextureRect.new()
	if ResourceLoader.exists(icon_path):
		ic.texture = load(icon_path)
	ic.custom_minimum_size = Vector2(24, 24)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	h.add_child(ic)
	var l := Label.new()
	l.text = "0"
	l.add_theme_font_size_override("font_size", 16)
	l.add_theme_color_override("font_color", col)
	h.add_child(l)
	return l


func _build_pause_modal() -> void:
	_pause_backdrop = ColorRect.new()
	_pause_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pause_backdrop.color = Color(0.08, 0.11, 0.09, 0.56)
	_pause_backdrop.visible = false
	_root.add_child(_pause_backdrop)

	_pause_modal = PanelContainer.new()
	_pause_modal.set_anchors_preset(Control.PRESET_CENTER)
	_pause_modal.offset_left = -275
	_pause_modal.offset_right = 275
	_pause_modal.offset_top = -310
	_pause_modal.offset_bottom = 310
	_pause_modal.add_theme_stylebox_override("panel", UiStyles.make_panel_style(UiStyles.COL_PANEL, UiStyles.COL_SAGE, 20, 3))
	_pause_backdrop.add_child(_pause_modal)

	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 10)
	_pause_modal.add_child(pv)

	var t := Label.new()
	t.text = "休憩、玩法与音画设置"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 23)
	t.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	pv.add_child(t)

	_add_pause_slider(pv, "田园配乐", "bgm_volume", 0.65)
	_add_pause_slider(pv, "溪流风声", "amb_volume", 0.60)
	_add_pause_slider(pv, "落子音效", "sfx_volume", 0.80)

	var rain_chk := CheckButton.new()
	rain_chk.text = "林间细雨白噪音"
	rain_chk.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	rain_chk.button_pressed = bool(SaveManager.get_setting("rain_enabled", false))
	rain_chk.toggled.connect(func(on: bool): SaveManager.set_setting("rain_enabled", on))
	pv.add_child(rain_chk)

	var help_h := HBoxContainer.new()
	help_h.add_theme_constant_override("separation", 8)
	pv.add_child(help_h)

	var p_guide_btn := Button.new()
	p_guide_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p_guide_btn.text = "玩法说明图解"
	UiStyles.style_button(p_guide_btn, UiStyles.COL_GOLD, true, 46.0)
	p_guide_btn.add_theme_font_size_override("font_size", 15)
	p_guide_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		_pause_backdrop.visible = false
		guide_requested.emit()
	)
	help_h.add_child(p_guide_btn)

	var p_tut_btn := Button.new()
	p_tut_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p_tut_btn.text = "重温互动引导"
	UiStyles.style_button(p_tut_btn, UiStyles.COL_BROOK, true, 46.0)
	p_tut_btn.add_theme_font_size_override("font_size", 15)
	p_tut_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		_pause_backdrop.visible = false
		tutorial_replay_requested.emit()
	)
	help_h.add_child(p_tut_btn)

	var res_btn := Button.new()
	res_btn.text = "继续游玩"
	UiStyles.style_button(res_btn, UiStyles.COL_SAGE, true, 48.0)
	res_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		_pause_backdrop.visible = false
	)
	pv.add_child(res_btn)

	var rst_btn := Button.new()
	rst_btn.text = "重置当前箱庭"
	UiStyles.style_button(rst_btn, UiStyles.COL_TERRA, false, 46.0)
	rst_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		_pause_backdrop.visible = false
		restart_chapter_requested.emit()
	)
	pv.add_child(rst_btn)

	var exit_btn := Button.new()
	exit_btn.text = "保存并返回主菜单"
	UiStyles.style_button(exit_btn, UiStyles.COL_WOOD, false, 46.0)
	exit_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		_pause_backdrop.visible = false
		exit_menu_requested.emit()
	)
	pv.add_child(exit_btn)


func _add_pause_slider(parent: VBoxContainer, label_txt: String, key: String, def_v: float) -> void:
	var l := Label.new()
	l.text = label_txt
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	parent.add_child(l)
	var sl := HSlider.new()
	sl.min_value = 0.0
	sl.max_value = 1.0
	sl.step = 0.05
	sl.value = float(SaveManager.get_setting(key, def_v))
	sl.value_changed.connect(func(v: float): SaveManager.set_setting(key, v))
	parent.add_child(sl)


func _build_clear_modal() -> void:
	_clear_backdrop = ColorRect.new()
	_clear_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_clear_backdrop.color = Color(0.08, 0.11, 0.09, 0.62)
	_clear_backdrop.visible = false
	_root.add_child(_clear_backdrop)

	_clear_modal = PanelContainer.new()
	_clear_modal.set_anchors_preset(Control.PRESET_CENTER)
	_clear_modal.offset_left = -295
	_clear_modal.offset_right = 295
	_clear_modal.offset_top = -310
	_clear_modal.offset_bottom = 310
	_clear_modal.add_theme_stylebox_override("panel", UiStyles.make_panel_style(UiStyles.COL_PANEL, UiStyles.COL_GOLD, 22, 3))
	_clear_backdrop.add_child(_clear_modal)

	var cv := VBoxContainer.new()
	cv.add_theme_constant_override("separation", 12)
	_clear_modal.add_child(cv)

	_clear_title_lbl = Label.new()
	_clear_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_clear_title_lbl.add_theme_font_size_override("font_size", 26)
	_clear_title_lbl.add_theme_color_override("font_color", UiStyles.COL_SAGE)
	cv.add_child(_clear_title_lbl)

	_clear_img = TextureRect.new()
	_clear_img.custom_minimum_size = Vector2(0, 220)
	_clear_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_clear_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cv.add_child(_clear_img)

	_clear_caption_lbl = Label.new()
	_clear_caption_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_clear_caption_lbl.add_theme_font_size_override("font_size", 16)
	_clear_caption_lbl.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	cv.add_child(_clear_caption_lbl)

	_clear_next_btn = Button.new()
	_clear_next_btn.text = "前往下一章"
	UiStyles.style_button(_clear_next_btn, UiStyles.COL_SAGE, true, 52.0)
	_clear_next_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		_clear_backdrop.visible = false
		next_chapter_requested.emit(_clear_next_id)
	)
	cv.add_child(_clear_next_btn)

	var stay_btn := Button.new()
	stay_btn.text = "继续留在此村造景"
	UiStyles.style_button(stay_btn, UiStyles.COL_BROOK, false, 48.0)
	stay_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		_clear_backdrop.visible = false
	)
	cv.add_child(stay_btn)

	var home_btn := Button.new()
	home_btn.text = "返回主菜单"
	UiStyles.style_button(home_btn, UiStyles.COL_WOOD, false, 48.0)
	home_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		_clear_backdrop.visible = false
		exit_menu_requested.emit()
	)
	cv.add_child(home_btn)


func _set_clean_view(on: bool) -> void:
	_clean_view = on
	_chrome_box.visible = not on
	_restore_btn.visible = on
	EventBus.sfx_requested.emit("sfx_ui_click", 0.0)


func bind_state(state: VillageState) -> void:
	_state = state
	_selected_mode = "hand"
	_selected_hand_idx = 0
	_selected_wonder_id = ""
	_dock_tab = 0
	_active_rot = 0
	_preview_bar.visible = false
	_clear_backdrop.visible = false
	_pause_backdrop.visible = false
	if _tutorial_coach != null:
		_tutorial_coach.stop_tutorial()
	_set_clean_view(false)
	refresh_all()


func refresh_all() -> void:
	if _state == null:
		return
	if _state.mode == "zen":
		_title_lbl.text = "禅意造景"
		_goals_panel.visible = false
	else:
		var cname := String(GameData.get_chapter(_state.chapter_id).get("name", "村落"))
		_title_lbl.text = cname
		_goals_panel.visible = true
		var lines: Array[String] = []
		for g in _state.goal_progress:
			var mark := "✓" if bool(g["done"]) else "•"
			lines.append("%s %s (%d/%d)" % [mark, String(g["desc"]), int(g["current"]), int(g["target"])])
		_goals_lbl.text = "\n".join(lines)

	_mood_btn.text = String(GameData.get_mood(_state.mood_id).get("name", "午后暖阳"))
	_grain_lbl.text = str(int(_state.resources.get("grain", 0)))
	_tea_lbl.text = str(int(_state.resources.get("tea", 0)))
	_bamboo_lbl.text = str(int(_state.resources.get("bamboo", 0)))
	_harmony_lbl.text = str(_state.harmony)
	_resident_lbl.text = "居民 %d/6" % _state.unlocked_residents.size()
	_undo_btn.disabled = _state.undo_snapshot.is_empty()

	_refresh_dock()


func _refresh_dock() -> void:
	if _state == null:
		return
	var craftable_cnt := 0
	for w in GameData.wonders:
		if _state.can_afford_wonder(String(w["id"])):
			craftable_cnt += 1
	_tab_wonder_btn.text = ("风物工坊 (可建%d)" % craftable_cnt) if craftable_cnt > 0 else "风物工坊"

	_hand_box.visible = (_dock_tab == 0)
	_wonder_scroll.visible = (_dock_tab == 1)
	UiStyles.style_button(_tab_hand_btn, UiStyles.COL_SAGE, _dock_tab == 0, 40.0)
	UiStyles.style_button(_tab_wonder_btn, UiStyles.COL_GOLD, _dock_tab == 1, 40.0)

	# Rebuild hand cards
	for c in _hand_box.get_children():
		c.queue_free()
	for i in range(_state.hand.size()):
		var tid := _state.hand[i]
		var tdef := GameData.get_tile(tid)
		var is_sel := (_selected_mode == "hand" and _selected_hand_idx == i)

		var card := PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_stylebox_override("panel", UiStyles.make_panel_style(UiStyles.COL_CARD, UiStyles.COL_GOLD if is_sel else UiStyles.COL_BORDER, 14, 3 if is_sel else 1))
		_hand_box.add_child(card)

		var vb := VBoxContainer.new()
		vb.alignment = BoxContainer.ALIGNMENT_CENTER
		vb.add_theme_constant_override("separation", 3)
		card.add_child(vb)

		var top_btn := Button.new()
		top_btn.flat = true
		top_btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vb.add_child(top_btn)

		var inner_v := VBoxContainer.new()
		inner_v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		inner_v.alignment = BoxContainer.ALIGNMENT_CENTER
		inner_v.add_theme_constant_override("separation", 1)
		inner_v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		top_btn.add_child(inner_v)

		var ptex := String(tdef.get("prop_tex", ""))
		var mini := HexEdgePreview.new(tdef.get("edges", []), _active_rot if is_sel else 0, bool(tdef.get("is_water", false)), ptex, is_sel)
		mini.custom_minimum_size = Vector2(64, 52)
		mini.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		inner_v.add_child(mini)

		var nl := Label.new()
		nl.text = String(tdef.get("name", ""))
		nl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nl.add_theme_font_size_override("font_size", 14)
		nl.add_theme_color_override("font_color", UiStyles.COL_SAGE if is_sel else UiStyles.COL_TEXT)
		inner_v.add_child(nl)

		var edge_lbl := Label.new()
		edge_lbl.text = _format_edge_badge(tdef.get("edges", []))
		edge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		edge_lbl.add_theme_font_size_override("font_size", 11)
		edge_lbl.add_theme_color_override("font_color", UiStyles.COL_BROOK)
		inner_v.add_child(edge_lbl)

		var idx := i
		top_btn.pressed.connect(func():
			if _selected_mode == "hand" and _selected_hand_idx == idx:
				rotate_requested.emit()
			else:
				_selected_mode = "hand"
				_selected_hand_idx = idx
				_refresh_dock()
				hand_selected.emit(idx)
		)

		var swap_btn := Button.new()
		swap_btn.text = "换一块"
		UiStyles.style_button(swap_btn, UiStyles.COL_WOOD, false, 26.0)
		swap_btn.add_theme_font_size_override("font_size", 12)
		swap_btn.pressed.connect(func():
			EventBus.sfx_requested.emit("sfx_tile_rotate", 0.05)
			hand_cycled.emit(idx)
		)
		vb.add_child(swap_btn)

	# Rebuild Wonder Craft Cards inside horizontal TouchScrollContainer
	for c in _wonder_box.get_children():
		c.queue_free()
	for w in GameData.wonders:
		var wid := String(w["id"])
		var afford := _state.can_afford_wonder(wid)
		var is_sel := (_selected_mode == "wonder" and _selected_wonder_id == wid)

		var card := PanelContainer.new()
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		card.custom_minimum_size = Vector2(182, 120)
		card.add_theme_stylebox_override("panel", UiStyles.make_panel_style(UiStyles.COL_CARD, UiStyles.COL_GOLD if is_sel else (UiStyles.COL_SAGE if afford else UiStyles.COL_BORDER), 14, 3 if is_sel else 1))
		_wonder_box.add_child(card)

		var wb := Button.new()
		wb.flat = true
		wb.disabled = not afford
		wb.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		card.add_child(wb)

		var wv := VBoxContainer.new()
		wv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wv.alignment = BoxContainer.ALIGNMENT_CENTER
		wv.add_theme_constant_override("separation", 4)
		card.add_child(wv)

		var wh := HBoxContainer.new()
		wh.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wh.alignment = BoxContainer.ALIGNMENT_CENTER
		wh.add_theme_constant_override("separation", 6)
		wv.add_child(wh)

		var wic := TextureRect.new()
		if ResourceLoader.exists(String(w["prop_tex"])):
			wic.texture = load(String(w["prop_tex"]))
		wic.custom_minimum_size = Vector2(54, 54)
		wic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		wic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		wic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if not afford:
			wic.modulate = Color(0.65, 0.65, 0.65, 0.75)
		wh.add_child(wic)

		var wtv := VBoxContainer.new()
		wtv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wtv.alignment = BoxContainer.ALIGNMENT_CENTER
		wh.add_child(wtv)

		var wnl := Label.new()
		wnl.text = String(w["name"])
		wnl.add_theme_font_size_override("font_size", 15)
		wnl.add_theme_color_override("font_color", UiStyles.COL_GOLD if afford else UiStyles.COL_TEXT_DIM)
		wtv.add_child(wnl)

		var cost_parts: Array[String] = []
		var cost: Dictionary = w["cost"]
		if cost.has("grain"):
			cost_parts.append("麦%d" % int(cost["grain"]))
		if cost.has("tea"):
			cost_parts.append("茶%d" % int(cost["tea"]))
		if cost.has("bamboo"):
			cost_parts.append("竹%d" % int(cost["bamboo"]))
		var wcl := Label.new()
		wcl.text = "消耗：" + " ".join(cost_parts)
		wcl.add_theme_font_size_override("font_size", 13)
		wcl.add_theme_color_override("font_color", UiStyles.COL_SAGE if afford else UiStyles.COL_TERRA)
		wtv.add_child(wcl)

		var wsl := Label.new()
		wsl.text = String(w.get("short_desc", ""))
		wsl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		wsl.add_theme_font_size_override("font_size", 12)
		wsl.add_theme_color_override("font_color", UiStyles.COL_TEXT_DIM)
		wv.add_child(wsl)

		wb.pressed.connect(func():
			_selected_mode = "wonder"
			_selected_wonder_id = wid
			_refresh_dock()
			wonder_selected.emit(wid)
		)


func _format_edge_badge(edges: Array) -> String:
	var r_cnt := 0
	var p_cnt := 0
	for e in edges:
		if String(e) == "river":
			r_cnt += 1
		elif String(e) == "road":
			p_cnt += 1
	var parts: Array[String] = []
	if r_cnt > 0:
		parts.append("溪%d" % r_cnt)
	if p_cnt > 0:
		parts.append("路%d" % p_cnt)
	return " ".join(parts) if not parts.is_empty() else "草甸"


func show_preview_info(tile_name: String, preview: Dictionary) -> void:
	if not bool(preview.get("valid", false)):
		_preview_bar.visible = false
		return
	_preview_bar.visible = true
	var tags: Array = preview.get("synergy_tags", [])
	var hgain := int(preview.get("harmony_gain", 0))
	var tag_str := " · ".join(tags) if not tags.is_empty() else "可旋转对齐水路/石路"
	_preview_lbl.text = "【%s】%s  (+%d 和煦)" % [tile_name, tag_str, hgain]


func hide_preview() -> void:
	_preview_bar.visible = false


func set_active_rot(rot: int) -> void:
	_active_rot = ((rot % 6) + 6) % 6
	_refresh_dock()


func show_toast(msg: String) -> void:
	_toast_lbl.text = msg
	_toast_panel.visible = true
	_toast_timer = 2.8


func show_chapter_clear(ch_id: String, postcard_id: String) -> void:
	var ch := GameData.get_chapter(ch_id)
	var pc := GameData.get_postcard(postcard_id)
	var idx := int(ch.get("index", 1))
	var next_id := "ch_%02d" % (idx + 1)
	var has_next := not GameData.get_chapter(next_id).is_empty()

	_clear_next_id = next_id
	_clear_next_btn.visible = has_next
	_clear_title_lbl.text = "%s 完成！" % String(ch.get("name", ""))
	if not pc.is_empty() and ResourceLoader.exists(String(pc["image"])):
		_clear_img.texture = load(String(pc["image"]))
	_clear_caption_lbl.text = "解锁纪念明信片【%s】\n%s" % [String(pc.get("title", "")), String(pc.get("caption", ""))]
	_clear_backdrop.visible = true
	UiStyles.animate_pop_in(_clear_modal)


func is_modal_open() -> bool:
	return (_pause_backdrop != null and _pause_backdrop.visible) or (_clear_backdrop != null and _clear_backdrop.visible)


func start_tutorial() -> void:
	if _tutorial_coach != null:
		_set_clean_view(false)
		_tutorial_coach.start_tutorial()


func is_tutorial_active() -> bool:
	return _tutorial_coach != null and _tutorial_coach.is_active()


func get_tutorial_step() -> int:
	return _tutorial_coach.get_step() if _tutorial_coach != null else -1


func notify_tutorial_hand() -> void:
	if _tutorial_coach != null:
		_tutorial_coach.notify_hand_action()


func notify_tutorial_preview() -> void:
	if _tutorial_coach != null:
		_tutorial_coach.notify_slot_previewed()


func notify_tutorial_placed() -> void:
	if _tutorial_coach != null:
		_tutorial_coach.notify_tile_placed()


func _process(delta: float) -> void:
	if _toast_timer > 0.0:
		_toast_timer -= delta
		if _toast_timer <= 0.0:
			_toast_panel.visible = false
