class_name ChapterSelectScreen
extends Control
## Scrollable 6-chapter pastoral campaign selector with TouchScrollContainer support.

signal back_requested()
signal chapter_selected(chapter_id: String)

var _list_box: VBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = UiStyles.COL_BG
	add_child(bg)

	var safe := MarginContainer.new()
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.add_theme_constant_override("margin_left", 16)
	safe.add_theme_constant_override("margin_right", 16)
	UiStyles.apply_safe_area_padding(safe, 16.0, 18.0)
	add_child(safe)

	var root_v := VBoxContainer.new()
	root_v.add_theme_constant_override("separation", 12)
	safe.add_child(root_v)

	var top_h := HBoxContainer.new()
	root_v.add_child(top_h)

	var back_btn := Button.new()
	back_btn.text = "返回"
	back_btn.custom_minimum_size = Vector2(92, 48)
	UiStyles.style_button(back_btn, UiStyles.COL_WOOD, false, 48.0)
	back_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		visible = false
		back_requested.emit()
	)
	top_h.add_child(back_btn)

	var title := Label.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text = "章节箱庭村落"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	top_h.add_child(title)

	var scroll := TouchScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UiStyles.style_scroll(scroll)
	root_v.add_child(scroll)

	_list_box = VBoxContainer.new()
	_list_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_box.add_theme_constant_override("separation", 12)
	scroll.add_child(_list_box)


func open() -> void:
	refresh_ui()
	visible = true
	UiStyles.animate_pop_in(self)


func refresh_ui() -> void:
	for c in _list_box.get_children():
		c.queue_free()

	for ch in GameData.chapters:
		var cid := String(ch["id"])
		var idx := int(ch["index"])
		var unlocked := SaveManager.is_chapter_unlocked(idx)
		var completed := SaveManager.is_chapter_completed(cid)
		var mood_name := String(GameData.get_mood(String(ch["default_mood"])).get("name", ""))

		var card := PanelContainer.new()
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		var bcol := UiStyles.COL_GOLD if completed else (UiStyles.COL_SAGE if unlocked else Color(0.68, 0.68, 0.64))
		card.add_theme_stylebox_override("panel", UiStyles.make_panel_style(UiStyles.COL_CARD, bcol, 16, 2))
		_list_box.add_child(card)

		var cv := VBoxContainer.new()
		cv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cv.add_theme_constant_override("separation", 8)
		card.add_child(cv)

		var hdr_h := HBoxContainer.new()
		hdr_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cv.add_child(hdr_h)

		var nl := Label.new()
		nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nl.text = String(ch["name"])
		nl.add_theme_font_size_override("font_size", 21)
		nl.add_theme_color_override("font_color", UiStyles.COL_SAGE if unlocked else UiStyles.COL_TEXT_DIM)
		hdr_h.add_child(nl)

		var tag_l := Label.new()
		tag_l.text = ("✓ 已通关" if completed else ("氛围：" + mood_name if unlocked else "通关上一章解锁"))
		tag_l.add_theme_font_size_override("font_size", 14)
		tag_l.add_theme_color_override("font_color", UiStyles.COL_GOLD if completed else UiStyles.COL_BROOK)
		hdr_h.add_child(tag_l)

		var sub := Label.new()
		sub.text = String(ch["subtitle"])
		sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sub.add_theme_font_size_override("font_size", 15)
		sub.add_theme_color_override("font_color", UiStyles.COL_TEXT_DIM)
		cv.add_child(sub)

		var goals_txt := PackedStringArray()
		for g in ch["goals"]:
			goals_txt.append("• " + String(g["desc"]))
		var gl := Label.new()
		gl.text = "\n".join(goals_txt)
		gl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		gl.add_theme_font_size_override("font_size", 14)
		gl.add_theme_color_override("font_color", UiStyles.COL_TEXT)
		cv.add_child(gl)

		var play_btn := Button.new()
		play_btn.text = "重新游玩本章" if completed else ("进入箱庭" if unlocked else "未解锁")
		play_btn.disabled = not unlocked
		UiStyles.style_button(play_btn, UiStyles.COL_GOLD if completed else UiStyles.COL_SAGE, unlocked, 48.0)
		play_btn.pressed.connect(func():
			EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
			visible = false
			chapter_selected.emit(cid)
		)
		cv.add_child(play_btn)
