class_name MainMenu
extends Control
## Cozy Ghibli-inspired portrait lobby with key art backdrop, drifting petals,
## chapter adventure entry, persistent Zen sandbox entry, and almanac/settings.

signal resume_chapter_requested()
signal open_chapters_requested()
signal open_zen_requested()
signal open_almanac_requested()
signal open_guide_requested()

var _progress_lbl: Label
var _resume_btn: Button
var _zen_btn: Button
var _settings_panel: PanelContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	refresh_ui()


func _build_ui() -> void:
	var bg := TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if ResourceLoader.exists("res://assets/art/ui/menu_bg.png"):
		bg.texture = load("res://assets/art/ui/menu_bg.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(bg)

	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.98, 0.95, 0.88, 0.16)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scrim)

	# Drifting blossom petals
	var petals := CPUParticles2D.new()
	petals.position = Vector2(360, -20)
	if ResourceLoader.exists("res://assets/art/ui/glow_soft.png"):
		petals.texture = load("res://assets/art/ui/glow_soft.png")
	petals.amount = 22
	petals.lifetime = 6.5
	petals.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	petals.emission_rect_extents = Vector2(360, 20)
	petals.direction = Vector2(0.35, 1.0)
	petals.spread = 22.0
	petals.initial_velocity_min = 48.0
	petals.initial_velocity_max = 95.0
	petals.gravity = Vector2(12, 16)
	petals.scale_amount_min = 0.08
	petals.scale_amount_max = 0.17
	petals.color = Color(1.0, 0.88, 0.92, 0.78)
	add_child(petals)

	var safe := MarginContainer.new()
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.add_theme_constant_override("margin_left", 20)
	safe.add_theme_constant_override("margin_right", 20)
	UiStyles.apply_safe_area_padding(safe, 20.0, 24.0)
	add_child(safe)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	safe.add_child(v)

	# Top Pill Bar
	var top_h := HBoxContainer.new()
	top_h.add_theme_constant_override("separation", 10)
	v.add_child(top_h)

	var badge_p := PanelContainer.new()
	badge_p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	badge_p.add_theme_stylebox_override("panel", UiStyles.make_panel_style(Color(0.98, 0.96, 0.90, 0.90), UiStyles.COL_SAGE, 16, 2))
	top_h.add_child(badge_p)

	var bh := HBoxContainer.new()
	bh.add_theme_constant_override("separation", 8)
	badge_p.add_child(bh)

	var ic := TextureRect.new()
	if ResourceLoader.exists("res://assets/art/ui/icon_postcard.png"):
		ic.texture = load("res://assets/art/ui/icon_postcard.png")
	ic.custom_minimum_size = Vector2(36, 36)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bh.add_child(ic)

	_progress_lbl = Label.new()
	_progress_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progress_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_progress_lbl.add_theme_font_size_override("font_size", 16)
	_progress_lbl.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	bh.add_child(_progress_lbl)

	var cfg_btn := Button.new()
	cfg_btn.text = "音效设置"
	cfg_btn.custom_minimum_size = Vector2(114, 54)
	UiStyles.style_button(cfg_btn, UiStyles.COL_WOOD, false, 54.0)
	cfg_btn.add_theme_font_size_override("font_size", 16)
	cfg_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		_settings_panel.visible = true
		UiStyles.animate_pop_in(_settings_panel)
	)
	top_h.add_child(cfg_btn)

	# Title Banner Card over Upper Sky
	var brand_p := PanelContainer.new()
	brand_p.add_theme_stylebox_override("panel", UiStyles.make_panel_style(Color(0.99, 0.96, 0.89, 0.84), Color(0.86, 0.65, 0.25, 0.75), 20, 2))
	v.add_child(brand_p)

	var brand_h := HBoxContainer.new()
	brand_h.add_theme_constant_override("separation", 14)
	brand_p.add_child(brand_h)

	var emblem := TextureRect.new()
	if ResourceLoader.exists("res://assets/art/ui/launcher_512.png"):
		emblem.texture = load("res://assets/art/ui/launcher_512.png")
	emblem.custom_minimum_size = Vector2(88, 88)
	emblem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	emblem.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	brand_h.add_child(emblem)

	var bt_v := VBoxContainer.new()
	bt_v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bt_v.alignment = BoxContainer.ALIGNMENT_CENTER
	bt_v.add_theme_constant_override("separation", 4)
	brand_h.add_child(bt_v)

	var title := Label.new()
	title.text = "风息村落物语"
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.18, 0.34, 0.24))
	bt_v.add_child(title)

	var sub := Label.new()
	sub.text = "田园六边形拼接 · 生态微循环 · 慢节奏伴侣"
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.add_theme_font_size_override("font_size", 15)
	sub.add_theme_color_override("font_color", UiStyles.COL_TEXT_DIM)
	bt_v.add_child(sub)

	# Open scenic middle window so key art shines
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(spacer)

	# Bottom Action Dock
	_resume_btn = Button.new()
	_resume_btn.text = "继续上次章节村落"
	UiStyles.style_button(_resume_btn, UiStyles.COL_GOLD, true, 62.0)
	_resume_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		resume_chapter_requested.emit()
	)
	v.add_child(_resume_btn)

	var ch_btn := Button.new()
	ch_btn.text = "章节箱庭之旅 (6 大主题村落)"
	UiStyles.style_button(ch_btn, UiStyles.COL_SAGE, true, 72.0)
	ch_btn.add_theme_font_size_override("font_size", 22)
	ch_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		open_chapters_requested.emit()
	)
	v.add_child(ch_btn)

	_zen_btn = Button.new()
	_zen_btn.text = "无尽禅意造景 (自由建造画卷)"
	UiStyles.style_button(_zen_btn, UiStyles.COL_BROOK, true, 62.0)
	_zen_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		open_zen_requested.emit()
	)
	v.add_child(_zen_btn)

	var bot_row := HBoxContainer.new()
	bot_row.add_theme_constant_override("separation", 10)
	v.add_child(bot_row)

	var guide_btn := Button.new()
	guide_btn.name = "GuideButton"
	guide_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	guide_btn.text = "玩法说明与教程"
	UiStyles.style_button(guide_btn, UiStyles.COL_GOLD, true, 56.0)
	guide_btn.add_theme_font_size_override("font_size", 18)
	guide_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		open_guide_requested.emit()
	)
	bot_row.add_child(guide_btn)

	var alm_btn := Button.new()
	alm_btn.name = "AlmanacButton"
	alm_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	alm_btn.text = "风物图鉴 · 明信片"
	UiStyles.style_button(alm_btn, UiStyles.COL_WOOD, false, 56.0)
	alm_btn.add_theme_font_size_override("font_size", 18)
	alm_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		open_almanac_requested.emit()
	)
	bot_row.add_child(alm_btn)

	_build_settings_modal()


func _build_settings_modal() -> void:
	_settings_panel = PanelContainer.new()
	_settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	_settings_panel.offset_left = -280
	_settings_panel.offset_right = 280
	_settings_panel.offset_top = -250
	_settings_panel.offset_bottom = 250
	_settings_panel.visible = false
	_settings_panel.add_theme_stylebox_override("panel", UiStyles.make_panel_style(UiStyles.COL_PANEL, UiStyles.COL_SAGE, 20, 3))
	add_child(_settings_panel)

	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 12)
	_settings_panel.add_child(sv)

	var t := Label.new()
	t.text = "田园声音与触感设置"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 24)
	t.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	sv.add_child(t)

	_add_slider(sv, "田园配乐音量 (BGM)", "bgm_volume", 0.65)
	_add_slider(sv, "溪流风声环境音", "amb_volume", 0.60)
	_add_slider(sv, "操作音效音量", "sfx_volume", 0.80)

	var rain_chk := CheckButton.new()
	rain_chk.text = "开启林间细雨白噪音"
	rain_chk.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	rain_chk.button_pressed = bool(SaveManager.get_setting("rain_enabled", false))
	rain_chk.toggled.connect(func(on: bool): SaveManager.set_setting("rain_enabled", on))
	sv.add_child(rain_chk)

	var hap_chk := CheckButton.new()
	hap_chk.text = "触控落子轻震动反馈"
	hap_chk.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	hap_chk.button_pressed = bool(SaveManager.get_setting("haptics", true))
	hap_chk.toggled.connect(func(on: bool): SaveManager.set_setting("haptics", on))
	sv.add_child(hap_chk)

	var close_btn := Button.new()
	close_btn.text = "完成"
	UiStyles.style_button(close_btn, UiStyles.COL_SAGE, true, 52.0)
	close_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		_settings_panel.visible = false
	)
	sv.add_child(close_btn)


func _add_slider(parent: VBoxContainer, label_txt: String, key: String, def_val: float) -> void:
	var lbl := Label.new()
	lbl.text = label_txt
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	parent.add_child(lbl)

	var sl := HSlider.new()
	sl.min_value = 0.0
	sl.max_value = 1.0
	sl.step = 0.05
	sl.value = float(SaveManager.get_setting(key, def_val))
	sl.value_changed.connect(func(v: float): SaveManager.set_setting(key, v))
	parent.add_child(sl)


func refresh_ui() -> void:
	var done_chs: int = (SaveManager.meta_data.get("completed_chapters", []) as Array).size()
	var pcs: int = (SaveManager.meta_data.get("unlocked_postcards", []) as Array).size()
	var res: int = (SaveManager.meta_data.get("unlocked_residents", []) as Array).size()
	_progress_lbl.text = "通关 %d/6 章  ·  明信片 %d/4  ·  居民 %d/6" % [done_chs, pcs, res]

	_resume_btn.visible = SaveManager.has_chapter_resume()
	if _resume_btn.visible:
		var r := SaveManager.load_session(false)
		if r != null:
			var cname := String(GameData.get_chapter(r.chapter_id).get("name", "箱庭"))
			_resume_btn.text = "继续：%s (和煦度 %d)" % [cname, r.harmony]
		else:
			_resume_btn.visible = false

	_zen_btn.text = "继续禅意造景画卷" if SaveManager.has_zen_save() else "无尽禅意造景 (自由建造画卷)"
