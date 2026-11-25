class_name GameplayGuideModal
extends Control
## Illustrated 4-tab gameplay guide modal explaining core loop, edge matching,
## ecological synergies, Wonder crafting, resident unlocks, and game modes.

signal closed()
signal replay_tutorial_requested()

const TAB_NAMES := ["核心操作", "协同加分", "风物居民", "模式图鉴"]

var _active_tab: int = 0
var _tab_btns: Array[Button] = []
var _scroll: TouchScrollContainer
var _content_box: VBoxContainer
var _modal_panel: PanelContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_build_ui()


func _build_ui() -> void:
	var backdrop := ColorRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.color = Color(0.08, 0.11, 0.09, 0.64)
	add_child(backdrop)

	var safe := MarginContainer.new()
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.add_theme_constant_override("margin_left", 18)
	safe.add_theme_constant_override("margin_right", 18)
	UiStyles.apply_safe_area_padding(safe, 26.0, 26.0)
	add_child(safe)

	_modal_panel = PanelContainer.new()
	_modal_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_modal_panel.add_theme_stylebox_override("panel", UiStyles.make_panel_style(UiStyles.COL_PANEL, UiStyles.COL_GOLD, 22, 3))
	safe.add_child(_modal_panel)

	var root_v := VBoxContainer.new()
	root_v.add_theme_constant_override("separation", 10)
	_modal_panel.add_child(root_v)

	# Header
	var hdr := HBoxContainer.new()
	hdr.add_theme_constant_override("separation", 8)
	root_v.add_child(hdr)

	var ic := TextureRect.new()
	if ResourceLoader.exists("res://assets/art/ui/icon_harmony.png"):
		ic.texture = load("res://assets/art/ui/icon_harmony.png")
	ic.custom_minimum_size = Vector2(36, 36)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hdr.add_child(ic)

	var title := Label.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.text = "玩法说明 · 风息村落物语"
	title.add_theme_font_size_override("font_size", 23)
	title.add_theme_color_override("font_color", UiStyles.COL_SAGE)
	hdr.add_child(title)

	var close_top := Button.new()
	close_top.text = "关闭"
	close_top.custom_minimum_size = Vector2(78, 44)
	UiStyles.style_button(close_top, UiStyles.COL_WOOD, false, 44.0)
	close_top.add_theme_font_size_override("font_size", 15)
	close_top.pressed.connect(close_modal)
	hdr.add_child(close_top)

	# Tab Bar
	var tab_h := HBoxContainer.new()
	tab_h.add_theme_constant_override("separation", 6)
	root_v.add_child(tab_h)

	_tab_btns.clear()
	for i in range(TAB_NAMES.size()):
		var b := Button.new()
		b.text = TAB_NAMES[i]
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		UiStyles.style_button(b, UiStyles.COL_SAGE, i == 0, 42.0)
		b.add_theme_font_size_override("font_size", 15)
		var idx := i
		b.pressed.connect(func():
			EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
			switch_tab(idx)
		)
		tab_h.add_child(b)
		_tab_btns.append(b)

	# Scrollable Body
	_scroll = TouchScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	UiStyles.style_scroll(_scroll)
	root_v.add_child(_scroll)

	_content_box = VBoxContainer.new()
	_content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_box.add_theme_constant_override("separation", 10)
	_scroll.add_child(_content_box)

	# Footer Actions
	var foot_h := HBoxContainer.new()
	foot_h.add_theme_constant_override("separation", 10)
	root_v.add_child(foot_h)

	var tut_btn := Button.new()
	tut_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tut_btn.text = "开启 5 步互动引导"
	UiStyles.style_button(tut_btn, UiStyles.COL_GOLD, true, 50.0)
	tut_btn.add_theme_font_size_override("font_size", 16)
	tut_btn.pressed.connect(func():
		EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
		visible = false
		replay_tutorial_requested.emit()
	)
	foot_h.add_child(tut_btn)

	var ok_btn := Button.new()
	ok_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ok_btn.text = "我明白了"
	UiStyles.style_button(ok_btn, UiStyles.COL_SAGE, true, 50.0)
	ok_btn.add_theme_font_size_override("font_size", 16)
	ok_btn.pressed.connect(close_modal)
	foot_h.add_child(ok_btn)


func open(initial_tab: int = 0) -> void:
	visible = true
	switch_tab(initial_tab)
	UiStyles.animate_pop_in(_modal_panel)


func close_modal() -> void:
	EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
	visible = false
	closed.emit()


func switch_tab(tab_idx: int) -> void:
	_active_tab = clampi(tab_idx, 0, TAB_NAMES.size() - 1)
	for i in range(_tab_btns.size()):
		UiStyles.style_button(_tab_btns[i], UiStyles.COL_SAGE, i == _active_tab, 42.0)
		_tab_btns[i].add_theme_font_size_override("font_size", 15)
	_rebuild_tab_content()
	if _scroll != null:
		_scroll.scroll_vertical = 0


func _rebuild_tab_content() -> void:
	for c in _content_box.get_children():
		c.queue_free()

	match _active_tab:
		0:
			_build_tab_basics()
		1:
			_build_tab_synergies()
		2:
			_build_tab_wonders_residents()
		3:
			_build_tab_modes()


func _build_tab_basics() -> void:
	_add_info_card(
		"一句话看懂《风息村落物语》",
		"这是一款没有倒计时、不会失败的慢节奏六边形田园拼图游戏。\n每步从底部行囊挑选 1 块地形放进村落，把【小溪连成水网】、【石板路连成路网】，让农田、花海和民居彼此邻接触发加分，积累稻穗/茶香/竹木建造风物奇观、吸引 6 位伙伴散步安家，完成顶部 3 项温和目标就能通关收下明信片！",
		UiStyles.COL_SAGE
	)

	# Step 1 with rotating preview pair
	var c1 := _make_card(UiStyles.COL_BROOK)
	var v1 := _card_vbox(c1)
	_add_card_title(v1, "第 1 步 · 点选行囊卡片，再点可旋转朝向", UiStyles.COL_BROOK)
	var h1 := HBoxContainer.new()
	h1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h1.add_theme_constant_override("separation", 10)
	v1.add_child(h1)

	var wheat_def := GameData.get_tile("tile_wheat")
	var p1 := HexEdgePreview.new(wheat_def.get("edges", []), 0, false, String(wheat_def.get("prop_tex", "")), false)
	p1.custom_minimum_size = Vector2(64, 56)
	h1.add_child(p1)

	var arr1 := Label.new()
	arr1.text = "点击旋转\n60° →"
	arr1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arr1.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arr1.add_theme_font_size_override("font_size", 12)
	arr1.add_theme_color_override("font_color", UiStyles.COL_GOLD)
	h1.add_child(arr1)

	var p2 := HexEdgePreview.new(wheat_def.get("edges", []), 5, false, String(wheat_def.get("prop_tex", "")), true)
	p2.custom_minimum_size = Vector2(64, 56)
	h1.add_child(p2)

	var t1 := Label.new()
	t1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t1.text = "地砖边上的【蓝色线=溪流】、【米色线=石路】。再点一下选中的卡片就顺时针转 60°；如果手牌不合心意，点卡片下方的「换一块」免费换新！"
	t1.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t1.add_theme_font_size_override("font_size", 14)
	t1.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	h1.add_child(t1)

	_add_info_card(
		"第 2 步 · 点击地图上的「白色虚线空位」预览效果",
		"点一下村子外圈的白色虚线六边形，地图上立刻出现半透明虚影与【金色协同连线】，预览栏会明确告诉你：能触发什么配合（如溪流灌溉 ×2）以及会涨多少和煦度。\n如果水路/石路方向还没对上，点预览栏「旋转」边看连线边转动！",
		UiStyles.COL_GOLD
	)

	_add_info_card(
		"第 3 步 · 再次点击确认放置（可随时撤回）",
		"满意后【再点一次同一个空位】（或点预览栏「放置」按钮）正式落子！放错了没关系，按屏幕右侧「撤回」键可以立刻退回上一步。",
		UiStyles.COL_TERRA
	)

	_add_info_card(
		"视野、昼夜氛围与纯净赏景",
		"• 移动/缩放：单指拖动平移村落，双指捏合或右侧「+ / -」缩放，「居中」一键回村。\n• 昼夜换装：点右上角「午后暖阳」循环切换 晨曦薄雾 / 午后暖阳 / 落日余晖 / 萤火夏夜，夏夜会亮起纸灯笼与萤火虫！\n• 赏景模式：点右上角「赏景」隐藏全部按钮，当作随身白噪音桌面陪伴画卷。",
		UiStyles.COL_WOOD
	)


func _build_tab_synergies() -> void:
	# 4 Resource icons overview
	var res_card := _make_card(UiStyles.COL_GOLD)
	var rv := _card_vbox(res_card)
	_add_card_title(rv, "顶部 4 种数值的作用", UiStyles.COL_GOLD)

	_add_icon_row(rv, "res://assets/art/ui/icon_grain.png", "稻穗 · 麦田与水车产出的粮食材料，用于建造水车磨坊、灯笼木桥等风物。", UiStyles.COL_GOLD)
	_add_icon_row(rv, "res://assets/art/ui/icon_tea.png", "茶香 · 茶园与茶寮产出的茗茶材料，用于建造灯笼茶寮、风铃花塔、云泉温泉亭。", UiStyles.COL_SAGE)
	_add_icon_row(rv, "res://assets/art/ui/icon_bamboo.png", "竹木 · 青翠竹林产出的营造木材，多种风物建筑的基础材料（落子与每隔数秒自动产出）。", Color(0.24, 0.54, 0.32))
	_add_icon_row(rv, "res://assets/art/ui/icon_harmony.png", "和煦度 · 整座村落的生机繁荣分！把水路/石路和邻接协同拼出来就会大幅提高，是每章通关核心指标。", UiStyles.COL_TERRA)

	_add_synergy_pair_card(
		"溪流灌溉 ×2  (核心高产组合)",
		"金色麦田 或 翠绿茶园 紧挨着 任意水系（直溪、弯溪、荷塘、水车、木桥、温泉亭）时：该农田产量翻倍，和煦度额外 +3，并计入「灌溉农田」目标！",
		"tile_wheat", 5, "tile_brook_straight", 2, "×2 翻倍"
	)

	_add_synergy_pair_card(
		"水系连通 +3  /  石路连通 +2",
		"相邻两块地砖的【蓝色溪边对齐蓝色溪边】或【米色路边对齐米色路边】，溪流与石路会自动汇合成一条完整通道；村民与动物只会在连通的路网与水系上巡游！",
		"tile_brook_straight", 2, "tile_pond", 1, "同边对接"
	)

	_add_synergy_pair_card(
		"宜居风景宅 +4  (吸引打盹橘猫)",
		"青瓦民居 或 灯笼茶寮 紧挨着 樱雪花海、青翠竹林、碧波荷塘、风铃花塔或云泉温泉亭时：触发「宜居风景宅 +4」，打造 2 处即可迎来打盹橘猫·团子！",
		"tile_road_cottage", 0, "tile_blossom", 0, "宅 + 景"
	)

	_add_synergy_pair_card(
		"水力丰收 ×2  &  跨溪通途 +6",
		"【水车磨坊】会让相邻的所有农田享受水力丰收 ×2；【灯笼木桥】既能上下通溪流、又能左右连石板路，一桥同时连起两岸，额外 +6 和煦度！",
		"wonder_bridge", 0, "tile_road_cottage", 2, "水陆双通"
	)

	_add_synergy_pair_card(
		"风铃和鸣 +3  (周围一整圈加分)",
		"把【风铃花塔】放在村落中心十字位置，它周围一圈最多 6 块相邻地块每块都会享受到额外 +3 和煦，是冲刺章节和煦度的利器！",
		"wonder_windchime", 0, "tile_tea", 0, "周围 +3"
	)


func _build_tab_wonders_residents() -> void:
	_add_info_card(
		"如何建造「风物奇观」？",
		"当你攒够一定数量的稻穗、茶香和竹木，点击底部右侧【风物工坊】页签：材料足够的奇观会自动亮起，点击它再像普通地块一样放到地图空位并旋转对齐即可建成！",
		UiStyles.COL_GOLD
	)

	for w in GameData.wonders:
		var card := _make_card(UiStyles.COL_GOLD)
		var v := _card_vbox(card)
		var h := HBoxContainer.new()
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_theme_constant_override("separation", 10)
		v.add_child(h)

		var preview := HexEdgePreview.new(w.get("edges", []), 0, bool(w.get("is_water", false)), String(w.get("prop_tex", "")), true)
		preview.custom_minimum_size = Vector2(64, 56)
		h.add_child(preview)

		var tv := VBoxContainer.new()
		tv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(tv)

		var cost_parts: Array[String] = []
		var cost: Dictionary = w.get("cost", {})
		if cost.has("grain"):
			cost_parts.append("稻穗 %d" % int(cost["grain"]))
		if cost.has("tea"):
			cost_parts.append("茶香 %d" % int(cost["tea"]))
		if cost.has("bamboo"):
			cost_parts.append("竹木 %d" % int(cost["bamboo"]))

		var tl := Label.new()
		tl.text = "%s   [消耗：%s]" % [String(w["name"]), " · ".join(cost_parts)]
		tl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tl.add_theme_font_size_override("font_size", 15)
		tl.add_theme_color_override("font_color", UiStyles.COL_GOLD)
		tv.add_child(tl)

		var dl := Label.new()
		dl.text = String(w["desc"])
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		dl.add_theme_font_size_override("font_size", 13)
		dl.add_theme_color_override("font_color", UiStyles.COL_TEXT)
		tv.add_child(dl)

	_add_info_card(
		"6 位村民与动物伙伴怎么解锁？",
		"无需额外购买——只要你的村落布局满足对应生态条件，伙伴就会自动入住并在连通的路网与溪流上散步打招呼：",
		UiStyles.COL_SAGE
	)

	for r in GameData.residents:
		var card := _make_card(UiStyles.COL_SAGE)
		var v := _card_vbox(card)
		var h := HBoxContainer.new()
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_theme_constant_override("separation", 10)
		v.add_child(h)

		var sp := TextureRect.new()
		if ResourceLoader.exists(String(r["sprite"])):
			sp.texture = load(String(r["sprite"]))
		sp.custom_minimum_size = Vector2(54, 54)
		sp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sp.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(sp)

		var tv := VBoxContainer.new()
		tv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(tv)

		var nl := Label.new()
		nl.text = String(r["name"])
		nl.add_theme_font_size_override("font_size", 15)
		nl.add_theme_color_override("font_color", UiStyles.COL_SAGE)
		tv.add_child(nl)

		var ul := Label.new()
		ul.text = "%s · 解锁条件：%s" % [String(r["role"]), String(r["unlock_desc"])]
		ul.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		ul.add_theme_font_size_override("font_size", 13)
		ul.add_theme_color_override("font_color", UiStyles.COL_TEXT)
		tv.add_child(ul)


func _build_tab_modes() -> void:
	_add_info_card(
		"章节箱庭之旅（6 大主题关卡）",
		"• 每章开局会先给你一小片特色起始村落与专属时间光影。\n• 只要完成顶部的 3 项温和目标（全部显示 ✓）就算通关！没有手牌耗尽或步数失败限制。\n• 通关可解锁下一章，并把 4 张全彩【纪念明信片】永久收入主菜单的「风物图鉴」。",
		UiStyles.COL_SAGE
	)

	_add_info_card(
		"无尽禅意造景（自由模式）",
		"• 适合想安静慢慢扩建大村庄的玩家：开局直接拥有初始小村与充裕稻穗/茶香/竹木。\n• 无任何过关条件限制，进度实时自动存档；配合右上「赏景」与「林间细雨白噪音」可随时当作疗愈动态桌面画卷。",
		UiStyles.COL_BROOK
	)

	_add_info_card(
		"进阶高分 3 个小技巧",
		"1. 留出接口：铺直溪和石路时，尽量让蓝色/米色开口朝向还没建好的外侧空位，方便以后越接越长。\n2. 善用「换一块」：如果三张手牌都不适合当前位置，尽管免费按「换一块」，直到刷出顺手的地块。\n3. 万金油布局：在池塘或小溪两旁种【麦田/茶园】保证产出，在【花海/竹林】旁边放【青瓦民居】稳拿宜居分，再用攒出的材料把【水车磨坊】和【风铃花塔】放在中心圈里！",
		UiStyles.COL_GOLD
	)


func _make_card(border_col: Color) -> PanelContainer:
	var p := PanelContainer.new()
	p.mouse_filter = Control.MOUSE_FILTER_PASS
	p.add_theme_stylebox_override("panel", UiStyles.make_panel_style(UiStyles.COL_CARD, border_col, 14, 2))
	_content_box.add_child(p)
	return p


func _card_vbox(card: PanelContainer) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_theme_constant_override("separation", 6)
	card.add_child(v)
	return v


func _add_card_title(v: VBoxContainer, txt: String, col: Color) -> void:
	var l := Label.new()
	l.text = txt
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", 17)
	l.add_theme_color_override("font_color", col)
	v.add_child(l)


func _add_info_card(title: String, body: String, col: Color) -> void:
	var c := _make_card(col)
	var v := _card_vbox(c)
	_add_card_title(v, title, col)
	var l := Label.new()
	l.text = body
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", 14)
	l.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	v.add_child(l)


func _add_icon_row(v: VBoxContainer, icon_path: String, body: String, col: Color) -> void:
	var h := HBoxContainer.new()
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_theme_constant_override("separation", 8)
	v.add_child(h)

	var ic := TextureRect.new()
	if ResourceLoader.exists(icon_path):
		ic.texture = load(icon_path)
	ic.custom_minimum_size = Vector2(28, 28)
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(ic)

	var l := Label.new()
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.text = body
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", 13)
	l.add_theme_color_override("font_color", col)
	h.add_child(l)


func _add_synergy_pair_card(title: String, desc: String, id_a: String, rot_a: int, id_b: String, rot_b: int, badge_txt: String) -> void:
	var c := _make_card(UiStyles.COL_SAGE)
	var v := _card_vbox(c)
	_add_card_title(v, title, UiStyles.COL_SAGE)

	var h := HBoxContainer.new()
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_theme_constant_override("separation", 10)
	v.add_child(h)

	var def_a := GameData.get_tile(id_a)
	var def_b := GameData.get_tile(id_b)

	var pair_h := HBoxContainer.new()
	pair_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pair_h.add_theme_constant_override("separation", 4)
	pair_h.alignment = BoxContainer.ALIGNMENT_CENTER
	h.add_child(pair_h)

	var pa := HexEdgePreview.new(def_a.get("edges", []), rot_a, bool(def_a.get("is_water", false)), String(def_a.get("prop_tex", "")), true)
	pa.custom_minimum_size = Vector2(58, 50)
	pair_h.add_child(pa)

	var mid := Label.new()
	mid.text = badge_txt
	mid.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mid.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	mid.add_theme_font_size_override("font_size", 12)
	mid.add_theme_color_override("font_color", UiStyles.COL_GOLD)
	pair_h.add_child(mid)

	var pb := HexEdgePreview.new(def_b.get("edges", []), rot_b, bool(def_b.get("is_water", false)), String(def_b.get("prop_tex", "")), true)
	pb.custom_minimum_size = Vector2(58, 50)
	pair_h.add_child(pb)

	var dl := Label.new()
	dl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dl.text = desc
	dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dl.add_theme_font_size_override("font_size", 13)
	dl.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	h.add_child(dl)
