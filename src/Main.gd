class_name MainController
extends Node
## Root coordinator for Windbreath Village: manages MainMenu, ChapterSelect, Almanac,
## interactive 2.5D VillageWorld, SkyBackdrop mood gradient, and GameHud.

@onready var sky_rect: ColorRect = $SkyLayer/SkyRect
@onready var world: VillageWorld = $VillageWorld
@onready var hud: GameHud = $GameHud
@onready var ui_layer: CanvasLayer = $UiLayer

var _state: VillageState
var _menu: MainMenu
var _chapters: ChapterSelectScreen
var _almanac: AlmanacScreen
var _active_tile_id: String = ""
var _active_mode: String = "hand" # "hand" | "wonder"
var _active_hand_idx: int = 0
var _active_rot: int = 0


func _ready() -> void:
	_instantiate_menus()
	_connect_signals()
	_show_menu()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if _state != null and world.visible:
			SaveManager.save_session(_state)


func _instantiate_menus() -> void:
	_menu = MainMenu.new()
	_chapters = ChapterSelectScreen.new()
	_almanac = AlmanacScreen.new()
	for w in [_menu, _chapters, _almanac]:
		ui_layer.add_child(w)


func _connect_signals() -> void:
	_menu.resume_chapter_requested.connect(_on_resume_chapter)
	_menu.open_chapters_requested.connect(func():
		_menu.visible = false
		_chapters.open()
	)
	_menu.open_zen_requested.connect(_on_open_zen)
	_menu.open_almanac_requested.connect(func():
		_menu.visible = false
		_almanac.open()
	)

	_chapters.back_requested.connect(_show_menu)
	_chapters.chapter_selected.connect(_start_chapter)
	_almanac.back_requested.connect(_show_menu)

	hud.hand_selected.connect(_on_hand_selected)
	hud.hand_cycled.connect(_on_hand_cycled)
	hud.wonder_selected.connect(_on_wonder_selected)
	hud.rotate_requested.connect(_on_rotate)
	hud.confirm_place_requested.connect(_on_confirm_place)
	hud.undo_requested.connect(_on_undo)
	hud.recenter_requested.connect(func(): world.recenter_camera())
	hud.zoom_requested.connect(func(f: float): world.zoom_by(f))
	hud.mood_cycle_requested.connect(_on_cycle_mood)
	hud.next_chapter_requested.connect(_start_chapter)
	hud.restart_chapter_requested.connect(_on_restart_session)
	hud.exit_menu_requested.connect(_on_exit_to_menu)

	world.slot_previewed.connect(_on_slot_previewed)
	world.slot_confirmed.connect(_on_slot_confirmed)
	world.mood_applied.connect(_on_mood_applied)

	EventBus.resident_unlocked.connect(func(rid: String):
		var rname := String(GameData.get_resident(rid).get("name", ""))
		hud.show_toast("✨ 新伙伴入住：%s" % rname)
		EventBus.sfx_requested.emit("sfx_resident_join", 0.0)
	)
	EventBus.chapter_completed.connect(func(cid: String, pc_id: String):
		SaveManager.record_chapter_complete(cid, pc_id, _state)
		SaveManager.clear_chapter_resume()
		EventBus.sfx_requested.emit("sfx_chapter_clear", 0.0)
		hud.show_chapter_clear(cid, pc_id)
	)
	EventBus.village_updated.connect(func():
		if _state != null:
			hud.refresh_all()
	)


func _show_menu() -> void:
	world.visible = false
	hud.visible = false
	_chapters.visible = false
	_almanac.visible = false
	_menu.refresh_ui()
	_menu.visible = true
	_on_mood_applied("afternoon")


func _start_chapter(ch_id: String) -> void:
	_state = VillageState.new()
	_state.start_chapter(ch_id)
	_enter_world()


func _on_resume_chapter() -> void:
	var loaded := SaveManager.load_session(false)
	if loaded == null:
		_chapters.open()
		return
	_state = loaded
	_enter_world()


func _on_open_zen() -> void:
	var loaded := SaveManager.load_session(true)
	if loaded != null:
		_state = loaded
	else:
		_state = VillageState.new()
		_state.start_zen("afternoon")
	_enter_world()


func _enter_world() -> void:
	_menu.visible = false
	_chapters.visible = false
	_almanac.visible = false
	world.visible = true
	hud.visible = true

	_active_mode = "hand"
	_active_hand_idx = 0
	_active_rot = 0
	_active_tile_id = _state.hand[0] if not _state.hand.is_empty() else "tile_meadow"

	world.bind_state(_state)
	world.set_active_placement(_active_tile_id, _active_rot)
	hud.bind_state(_state)
	SaveManager.save_session(_state)


func _on_hand_selected(idx: int) -> void:
	if _state == null or idx < 0 or idx >= _state.hand.size():
		return
	_active_mode = "hand"
	_active_hand_idx = idx
	_active_tile_id = _state.hand[idx]
	EventBus.sfx_requested.emit("sfx_tile_select", 0.05)
	world.set_active_placement(_active_tile_id, _active_rot)


func _on_hand_cycled(idx: int) -> void:
	if _state == null:
		return
	_state.cycle_hand_slot(idx)
	if _active_mode == "hand" and _active_hand_idx == idx:
		_active_tile_id = _state.hand[idx]
		world.set_active_placement(_active_tile_id, _active_rot)
	SaveManager.save_session(_state)


func _on_wonder_selected(wonder_id: String) -> void:
	_active_mode = "wonder"
	_active_tile_id = wonder_id
	EventBus.sfx_requested.emit("sfx_tile_select", 0.05)
	world.set_active_placement(_active_tile_id, _active_rot)


func _on_rotate() -> void:
	_active_rot = (_active_rot + 1) % 6
	EventBus.sfx_requested.emit("sfx_tile_rotate", 0.08)
	hud.set_active_rot(_active_rot)
	world.set_active_placement(_active_tile_id, _active_rot)


func _on_slot_previewed(_q: int, _r: int, preview: Dictionary) -> void:
	var tname := String(GameData.get_tile(_active_tile_id).get("name", ""))
	hud.show_preview_info(tname, preview)


func _on_slot_confirmed(q: int, r: int) -> void:
	if _state == null:
		return
	var res := {}
	if _active_mode == "wonder":
		res = _state.craft_wonder(_active_tile_id, q, r, _active_rot)
	else:
		res = _state.place_hand_tile(_active_hand_idx, q, r, _active_rot)
	if not bool(res.get("ok", false)):
		return

	UiStyles.trigger_haptic(22)
	var prev: Dictionary = res["preview"]
	var tags: Array = prev.get("synergy_tags", [])
	if _active_mode == "wonder":
		EventBus.sfx_requested.emit("sfx_craft_wonder", 0.0)
	elif not tags.is_empty():
		EventBus.sfx_requested.emit("sfx_synergy_chime", 0.04)
	elif int(prev.get("matched_rivers", 0)) > 0 or int(prev.get("matched_roads", 0)) > 0:
		EventBus.sfx_requested.emit("sfx_edge_match", 0.04)
	else:
		EventBus.sfx_requested.emit("sfx_tile_place", 0.06)

	var hgain := int(prev.get("harmony_gain", 0))
	var popup := "+%d 和煦" % hgain
	if not tags.is_empty():
		popup = "%s (+%d)" % [String(tags[0]), hgain]
	world.spawn_floating_label(HexMath.axial_to_pixel(q, r), popup, Color(1.0, 0.94, 0.48))

	world.sync_after_placement(q, r)
	hud.hide_preview()

	# Reset to hand mode smoothly after crafting a wonder
	if _active_mode == "wonder":
		_active_mode = "hand"
		_active_hand_idx = 0
		hud._dock_tab = 0
		hud._selected_mode = "hand"
		hud._selected_hand_idx = 0
	_active_tile_id = _state.hand[_active_hand_idx] if not _state.hand.is_empty() else "tile_meadow"
	world.set_active_placement(_active_tile_id, _active_rot)

	SaveManager.record_tile_placed(_state)
	SaveManager.save_session(_state)
	hud.refresh_all()


func _on_confirm_place() -> void:
	if world.has_active_preview():
		var c := world.get_preview_coord()
		_on_slot_confirmed(c.x, c.y)


func _on_undo() -> void:
	if _state == null:
		return
	if _state.undo_last_move():
		world.rebuild_board()
		world.clear_preview()
		hud.hide_preview()
		_active_mode = "hand"
		_active_hand_idx = 0
		_active_tile_id = _state.hand[0]
		world.set_active_placement(_active_tile_id, _active_rot)
		SaveManager.save_session(_state)
		hud.refresh_all()


func _on_cycle_mood() -> void:
	if _state == null:
		return
	var ids := ["morning", "afternoon", "sunset", "night"]
	var cur_i := ids.find(_state.mood_id)
	var next_id := String(ids[(cur_i + 1) % ids.size()])
	world.apply_mood(next_id)
	SaveManager.save_session(_state)
	hud.refresh_all()


func _on_mood_applied(mood_id: String) -> void:
	var mdef := GameData.get_mood(mood_id)
	if sky_rect != null and not mdef.is_empty():
		var tw := create_tween()
		tw.tween_property(sky_rect, "color", Color(mdef["sky_top"]), 0.45)


func _on_restart_session() -> void:
	if _state == null:
		return
	if _state.mode == "zen":
		_state.start_zen(_state.mood_id)
	else:
		_state.start_chapter(_state.chapter_id)
	_enter_world()


func _on_exit_to_menu() -> void:
	if _state != null:
		SaveManager.save_session(_state)
	_show_menu()
