class_name AlmanacScreen
extends Control
## Village Almanac showing collected Illustrated Postcards, 6 cozy Residents & quotes,
## and all 15 placeable/craftable Tile & Wonder synergy references.

signal back_requested()

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

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	safe.add_child(v)

	var top_h := HBoxContainer.new()
	v.add_child(top_h)

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
	title.text = "风物图鉴与明信片册"
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	top_h.add_child(title)

	var scroll := TouchScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UiStyles.style_scroll(scroll)
	v.add_child(scroll)

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

	var unlocked_pcs: Array = SaveManager.meta_data.get("unlocked_postcards", [])
	var unlocked_res: Array = SaveManager.meta_data.get("unlocked_residents", [])

	_add_section_hdr("【纪念明信片集】 (%d / %d)" % [unlocked_pcs.size(), GameData.postcards.size()], UiStyles.COL_TERRA)
	for pc in GameData.postcards:
		var pid := String(pc["id"])
		var has_pc := unlocked_pcs.has(pid)
		var card := PanelContainer.new()
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		card.add_theme_stylebox_override("panel", UiStyles.make_panel_style(UiStyles.COL_CARD, UiStyles.COL_GOLD if has_pc else UiStyles.COL_BORDER, 14, 2))
		_list_box.add_child(card)

		var h := HBoxContainer.new()
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_theme_constant_override("separation", 12)
		card.add_child(h)

		var img := TextureRect.new()
		if ResourceLoader.exists(String(pc["image"])):
			img.texture = load(String(pc["image"]))
		img.custom_minimum_size = Vector2(140, 105)
		img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		img.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if not has_pc:
			img.modulate = Color(0.25, 0.25, 0.25, 0.55)
		h.add_child(img)

		var tv := VBoxContainer.new()
		tv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(tv)

		var tl := Label.new()
		tl.text = String(pc["title"]) + ("" if has_pc else " (未收藏)")
		tl.add_theme_font_size_override("font_size", 18)
		tl.add_theme_color_override("font_color", UiStyles.COL_TERRA if has_pc else UiStyles.COL_TEXT_DIM)
		tv.add_child(tl)

		var cl := Label.new()
		cl.text = String(pc["caption"]) if has_pc else "通关对应章节后解锁手绘纪念明信片。"
		cl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cl.add_theme_font_size_override("font_size", 14)
		cl.add_theme_color_override("font_color", UiStyles.COL_TEXT)
		tv.add_child(cl)

	_add_section_hdr("【村落居民与动物伙伴】 (%d / %d)" % [unlocked_res.size(), GameData.residents.size()], UiStyles.COL_SAGE)
	for r in GameData.residents:
		var rid := String(r["id"])
		var has_r := unlocked_res.has(rid)
		var card := PanelContainer.new()
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		card.add_theme_stylebox_override("panel", UiStyles.make_panel_style(UiStyles.COL_CARD, UiStyles.COL_SAGE if has_r else UiStyles.COL_BORDER, 14, 1))
		_list_box.add_child(card)

		var h := HBoxContainer.new()
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_theme_constant_override("separation", 10)
		card.add_child(h)

		var sp := TextureRect.new()
		if ResourceLoader.exists(String(r["sprite"])):
			sp.texture = load(String(r["sprite"]))
		sp.custom_minimum_size = Vector2(72, 72)
		sp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if not has_r:
			sp.modulate = Color(0.28, 0.28, 0.28, 0.65)
		h.add_child(sp)

		var tv := VBoxContainer.new()
		tv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(tv)

		var nl := Label.new()
		nl.text = String(r["name"])
		nl.add_theme_font_size_override("font_size", 17)
		nl.add_theme_color_override("font_color", UiStyles.COL_SAGE if has_r else UiStyles.COL_TEXT_DIM)
		tv.add_child(nl)

		var dl := Label.new()
		dl.text = "%s\n入住条件：%s\n%s" % [String(r["role"]), String(r["unlock_desc"]), String(r["quote"]) if has_r else ""]
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		dl.add_theme_font_size_override("font_size", 13)
		dl.add_theme_color_override("font_color", UiStyles.COL_TEXT)
		tv.add_child(dl)

	_add_section_hdr("【风物地标与地块协同指南】", UiStyles.COL_BROOK)
	for t in GameData.wonders + GameData.tiles:
		var card := PanelContainer.new()
		card.mouse_filter = Control.MOUSE_FILTER_PASS
		var is_w := String(t.get("category", "")) == "wonder"
		card.add_theme_stylebox_override("panel", UiStyles.make_panel_style(UiStyles.COL_CARD, UiStyles.COL_GOLD if is_w else UiStyles.COL_BORDER, 12, 1))
		_list_box.add_child(card)

		var h := HBoxContainer.new()
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_theme_constant_override("separation", 10)
		card.add_child(h)

		var ic := TextureRect.new()
		var ppath := String(t.get("prop_tex", ""))
		if ppath.is_empty():
			ppath = String(t.get("base_tex", ""))
		if ResourceLoader.exists(ppath):
			ic.texture = load(ppath)
		ic.custom_minimum_size = Vector2(58, 58)
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(ic)

		var tv := VBoxContainer.new()
		tv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(tv)

		var nl := Label.new()
		nl.text = String(t["name"])
		nl.add_theme_font_size_override("font_size", 16)
		nl.add_theme_color_override("font_color", UiStyles.COL_GOLD if is_w else UiStyles.COL_TEXT)
		tv.add_child(nl)

		var dl := Label.new()
		dl.text = String(t["desc"])
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		dl.add_theme_font_size_override("font_size", 13)
		dl.add_theme_color_override("font_color", UiStyles.COL_TEXT_DIM)
		tv.add_child(dl)


func _add_section_hdr(txt: String, col: Color) -> void:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", 19)
	l.add_theme_color_override("font_color", col)
	_list_box.add_child(l)
