class_name TutorialCoach
extends Control
## Non-blocking 5-step interactive tutorial overlay shown on first play (and replayable).
## Listens to real player actions (select/rotate, preview slot, place tile) to auto-advance.

signal tutorial_finished()
signal tutorial_skipped()

const STEPS := [
	{
		"badge": "新手引导 1/5 · 游戏目标",
		"title": "这个游戏怎么赢？",
		"body": "上方显示本关的【3 项过关目标】与 4 种产出：稻穗、茶香、竹木（用来建奇观）以及和煦度（繁荣总分）。把三项目标全部达成 ✓ 即可通关并收获明信片！",
		"next": "下一步：看懂地块",
	},
	{
		"badge": "新手引导 2/5 · 选牌与旋转",
		"title": "看下方行囊：试试点选与旋转",
		"body": "卡片边缘的【蓝线=溪流】、【米色线=石路】。点一下任意手牌选中，再点同一张卡可顺时针旋转 60° 对齐地形；不合心意点「换一块」免费刷新。",
		"next": "下一步：学如何放置",
	},
	{
		"badge": "新手引导 3/5 · 点击空位预览",
		"title": "点击地图上【白色虚线空位】",
		"body": "点一下已有村落旁的白色虚线六边形，立即看到半透明虚影、金色协同连线与预计加分！（提示：让麦田/茶园挨着小溪，或让蓝/米色边相连！）",
		"next": "我已预览，下一步",
	},
	{
		"badge": "新手引导 4/5 · 调向与落子",
		"title": "满意后再次点击空位放置",
		"body": "预览时可以随时点预览条的「旋转」转动朝向；确认对齐后，再点一次同一个空位（或点底部「放置」）就能铺好地块！放错了还能按右侧「撤回」。",
		"next": "直接跳到最后一步",
	},
	{
		"badge": "新手引导 5/5 · 核心协同口诀",
		"title": "太棒了！记住 3 条高分秘诀",
		"body": "1. 农田挨着水系 → 溪流灌溉产量×2；2. 民居挨花海/竹林/荷塘 → 宜居风景宅 +4；3. 材料攒够切到下方「风物工坊」建水车/茶寮/木桥，就能吸引 6 位伙伴散步安家！",
		"next": "我学会了，开始建村！",
	},
]

var _step: int = 0
var _active: bool = false

var _card: PanelContainer
var _badge_lbl: Label
var _title_lbl: Label
var _body_lbl: Label
var _skip_btn: Button
var _next_btn: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_build_ui()


func _build_ui() -> void:
	_card = PanelContainer.new()
	_card.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_card.offset_left = 18
	_card.offset_right = -18
	_card.offset_top = 248
	_card.offset_bottom = 428
	_card.add_theme_stylebox_override("panel", UiStyles.make_panel_style(Color(0.99, 0.97, 0.91, 0.97), UiStyles.COL_GOLD, 18, 3))
	add_child(_card)

	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 6)
	_card.add_child(v)

	var top_h := HBoxContainer.new()
	top_h.add_theme_constant_override("separation", 8)
	v.add_child(top_h)

	_badge_lbl = Label.new()
	_badge_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_badge_lbl.add_theme_font_size_override("font_size", 13)
	_badge_lbl.add_theme_color_override("font_color", UiStyles.COL_TERRA)
	top_h.add_child(_badge_lbl)

	_skip_btn = Button.new()
	_skip_btn.text = "跳过引导"
	_skip_btn.custom_minimum_size = Vector2(96, 32)
	UiStyles.style_button(_skip_btn, UiStyles.COL_WOOD, false, 32.0)
	_skip_btn.add_theme_font_size_override("font_size", 13)
	_skip_btn.pressed.connect(_on_skip)
	top_h.add_child(_skip_btn)

	_title_lbl = Label.new()
	_title_lbl.add_theme_font_size_override("font_size", 19)
	_title_lbl.add_theme_color_override("font_color", UiStyles.COL_SAGE)
	v.add_child(_title_lbl)

	_body_lbl = Label.new()
	_body_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body_lbl.add_theme_font_size_override("font_size", 14)
	_body_lbl.add_theme_color_override("font_color", UiStyles.COL_TEXT)
	v.add_child(_body_lbl)

	var btn_h := HBoxContainer.new()
	btn_h.alignment = BoxContainer.ALIGNMENT_END
	v.add_child(btn_h)

	_next_btn = Button.new()
	_next_btn.custom_minimum_size = Vector2(180, 40)
	UiStyles.style_button(_next_btn, UiStyles.COL_SAGE, true, 40.0)
	_next_btn.add_theme_font_size_override("font_size", 15)
	_next_btn.pressed.connect(_on_next)
	btn_h.add_child(_next_btn)


func start_tutorial() -> void:
	_step = 0
	_active = true
	visible = true
	_render_step()
	UiStyles.animate_pop_in(_card)


func stop_tutorial() -> void:
	_active = false
	visible = false


func is_active() -> bool:
	return _active and visible


func get_step() -> int:
	return _step


func notify_hand_action() -> void:
	if is_active() and _step == 1:
		_step = 2
		_render_step()


func notify_slot_previewed() -> void:
	if is_active() and _step == 2:
		_step = 3
		_render_step()


func notify_tile_placed() -> void:
	if is_active() and (_step == 2 or _step == 3):
		_step = 4
		_render_step()


func _render_step() -> void:
	var data: Dictionary = STEPS[clampi(_step, 0, STEPS.size() - 1)]
	_badge_lbl.text = String(data["badge"])
	_title_lbl.text = String(data["title"])
	_body_lbl.text = String(data["body"])
	_next_btn.text = String(data["next"])
	_skip_btn.visible = (_step < STEPS.size() - 1)


func _on_next() -> void:
	EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
	if _step < STEPS.size() - 1:
		_step += 1
		_render_step()
	else:
		stop_tutorial()
		tutorial_finished.emit()


func _on_skip() -> void:
	EventBus.sfx_requested.emit("sfx_ui_click", 0.0)
	stop_tutorial()
	tutorial_skipped.emit()
