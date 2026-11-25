extends Node
## Automated headless test suite for Windbreath Village:
## verifies asset/catalog completeness, flat-top axial hex math, river/road edge
## connections, ecological synergies, villager/resident unlocks, Wonder crafting,
## 1-step undo, chapter goal completion, save persistence, TouchScrollContainer
## drag-over-buttons, and full Main scene integration.

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run_all")


func _assert(cond: bool, msg: String) -> void:
	if not cond:
		_failures.append(msg)
		printerr("[FAIL] ", msg)
	else:
		print("[PASS] ", msg)


func _run_all() -> void:
	await get_tree().process_frame
	_test_catalog_and_assets()
	_test_hex_math_and_rotation()
	_test_ecosystem_synergies_and_wonders()
	_test_chapter_completion_and_persistence()
	await _test_full_ui_and_touch_scroll()

	if _failures.is_empty():
		print("\nALL TESTS PASSED (0 failures)")
		get_tree().quit(0)
	else:
		printerr("\nTEST SUITE FAILED: ", _failures.size(), " failures")
		get_tree().quit(1)


func _test_catalog_and_assets() -> void:
	_assert(GameData.tiles.size() == 10, "10 core hex tiles loaded")
	_assert(GameData.wonders.size() == 5, "5 craftable Wonder landmarks loaded")
	_assert(GameData.residents.size() == 6, "6 cozy residents loaded")
	_assert(GameData.chapters.size() == 6, "6 themed chapters loaded")
	_assert(GameData.postcards.size() == 4, "4 illustrated postcards loaded")
	_assert(GameData.moods.size() == 4, "4 ambient moods loaded")

	for t in GameData.tiles + GameData.wonders:
		var base_p := String(t.get("base_tex", ""))
		_assert(ResourceLoader.exists(base_p), "Tile base exists: %s" % base_p)
		var prop_p := String(t.get("prop_tex", ""))
		if not prop_p.is_empty():
			_assert(ResourceLoader.exists(prop_p), "Tile prop exists: %s" % prop_p)
	for r in GameData.residents:
		_assert(ResourceLoader.exists(String(r["sprite"])), "Resident sprite exists: %s" % r["id"])
	for pc in GameData.postcards:
		_assert(ResourceLoader.exists(String(pc["image"])), "Postcard image exists: %s" % pc["id"])

	_assert(ResourceLoader.exists("res://assets/audio/bgm/bgm_village_pastoral_loop_main_v02.ogg"), "Updated v02 pastoral BGM OGG exists")
	_assert(ResourceLoader.exists("res://assets/audio/bgm/amb_village_brook_wind_loop_v02.ogg"), "Updated v02 brook & breeze ambient OGG exists")
	_assert(ResourceLoader.exists("res://assets/audio/bgm/amb_village_rain_breeze_loop_v02.ogg"), "Updated v02 rain drizzle ambient OGG exists")
	_assert(not ResourceLoader.exists("res://assets/audio/bgm/bgm_village_pastoral_loop_main_v01.ogg"), "Unused v01 BGM runtime file removed")
	_assert(not ResourceLoader.exists("res://assets/audio/bgm/amb_brook_loop.ogg"), "Legacy static-hiss amb_brook_loop removed")
	_assert(not ResourceLoader.exists("res://assets/audio/bgm/amb_rain_chime_loop.ogg"), "Legacy static-hiss amb_rain_chime_loop removed")
	_assert(not ResourceLoader.exists("res://assets/audio/bgm/amb_village_brook_wind_loop_v01.ogg"), "Unused v01 brook ambient removed")
	_assert(not ResourceLoader.exists("res://assets/audio/bgm/amb_village_rain_breeze_loop_v01.ogg"), "Unused v01 rain ambient removed")
	_assert(AudioManager._bgm_player != null and AudioManager._bgm_player.stream != null, "AudioManager loads active v02 BGM stream")
	_assert(AudioManager._brook_player != null and AudioManager._brook_player.stream != null, "AudioManager loads active v02 brook stream")
	_assert(AudioManager._rain_player != null and AudioManager._rain_player.stream != null, "AudioManager loads active v02 rain stream")


func _test_hex_math_and_rotation() -> void:
	for i in range(6):
		var d := HexMath.DIRS[i]
		var px := HexMath.axial_to_pixel(d.x, d.y)
		var back := HexMath.pixel_to_axial(px)
		_assert(back == d, "Hex pixel<->axial roundtrip matches neighbor %d" % i)

	# Verify edge midpoint direction aligns with neighbor direction vector
	for i in range(6):
		var mp := HexMath.edge_midpoint(i)
		var n_px := HexMath.axial_to_pixel(HexMath.DIRS[i].x, HexMath.DIRS[i].y)
		_assert(mp.normalized().dot(n_px.normalized()) > 0.999, "Edge midpoint %d aligns with neighbor %s" % [i, HexMath.DIRS[i]])

	# Straight brook has rivers on edges 1 (S) & 4 (N); rotating +1 moves them to 2 (SW) & 5 (NE)
	var base_e := ["grass", "river", "grass", "grass", "river", "grass"]
	var rot_e := HexMath.rotated_edges(base_e, 1)
	_assert(rot_e[2] == "river" and rot_e[5] == "river" and rot_e[1] == "grass", "Hex edge rotation clockwise works cleanly")


func _test_ecosystem_synergies_and_wonders() -> void:
	var st := VillageState.new()
	st.start_chapter("ch_01")
	var initial_count := st.board.size()
	_assert(initial_count == 3, "Chapter 1 seeds 3 starter tiles")

	# Place a wheatfield next to starter brook (0,-1) and cottage (0,0)
	st.hand[0] = "tile_wheat"
	var res := st.place_hand_tile(0, -1, 0, 5) # Edge 1->rot 5 places road at dir 0 toward (0,0) cottage!
	_assert(bool(res["ok"]), "Placing wheatfield at (-1,0) succeeds")
	_assert(int(st.metrics["irrigated_farms"]) >= 2, "Adjacent water irrigates tea & wheat farms")
	_assert(int(st.metrics["road_links"]) >= 1, "Rotated road links wheatfield to cottage")
	_assert(st.unlocked_residents.has("res_villager_basket"), "Road+farm connection unlocks Farmer Ahe")

	# Verify 1-step Undo cleanly restores board
	_assert(st.undo_last_move(), "Undo last move succeeds")
	_assert(st.board.size() == initial_count, "Undo restores previous tile count")

	# Craft Wonder Watermill with sufficient resources
	st.resources["grain"] = 20
	st.resources["bamboo"] = 20
	var craft := st.craft_wonder("wonder_watermill", -1, 0, 0)
	_assert(bool(craft["ok"]), "Crafting Watermill wonder succeeds when resources suffice")
	_assert(int((st.metrics["wonder_counts"] as Dictionary).get("wonder_watermill", 0)) == 1, "Watermill wonder counted in village metrics")


func _test_chapter_completion_and_persistence() -> void:
	var st := VillageState.new()
	st.start_chapter("ch_01")
	# Build enough irrigated farms, road links & harmony to complete ch_01
	st.hand[0] = "tile_wheat"
	st.place_hand_tile(0, -1, 0, 5)
	st.hand[0] = "tile_road_cross"
	st.place_hand_tile(0, 1, 0, 0)
	st.hand[0] = "tile_blossom"
	st.place_hand_tile(0, 0, 1, 0)
	st.hand[0] = "tile_bamboo"
	st.place_hand_tile(0, 1, 1, 0)
	st.hand[0] = "tile_road_cottage"
	st.place_hand_tile(0, -1, 1, 0)

	_assert(st.harmony >= 38, "Village harmony reaches Ch1 threshold (%d)" % st.harmony)
	_assert(st.chapter_cleared, "Chapter 1 goals mark chapter_cleared = true")

	# Save & reload resume + Zen persistence
	SaveManager.save_session(st)
	_assert(SaveManager.has_chapter_resume(), "Chapter resume file written")
	var loaded := SaveManager.load_session(false)
	_assert(loaded != null and loaded.board.size() == st.board.size() and loaded.harmony == st.harmony, "Loaded chapter resume preserves board and harmony")
	SaveManager.clear_chapter_resume()

	var zen := VillageState.new()
	zen.start_zen("night")
	SaveManager.save_session(zen)
	var loaded_zen := SaveManager.load_session(true)
	_assert(loaded_zen != null and loaded_zen.mode == "zen" and loaded_zen.mood_id == "night", "Zen village mode & mood persisted cleanly")
	SaveManager.clear_zen_save()

	var orig_tut := SaveManager.is_tutorial_seen()
	SaveManager.set_tutorial_seen(false)
	_assert(not SaveManager.is_tutorial_seen(), "Tutorial seen flag can reset to false")
	SaveManager.set_tutorial_seen(true)
	_assert(SaveManager.is_tutorial_seen(), "Tutorial seen flag persists true")
	SaveManager.set_tutorial_seen(orig_tut)


func _test_full_ui_and_touch_scroll() -> void:
	var orig_tut := SaveManager.is_tutorial_seen()
	SaveManager.set_tutorial_seen(false)

	get_tree().root.size = Vector2i(720, 1280)
	var scene := load("res://src/scenes/Main.tscn") as PackedScene
	_assert(scene != null, "Main.tscn loads cleanly")
	var inst := scene.instantiate() as MainController
	get_tree().root.add_child(inst)
	await get_tree().process_frame
	await get_tree().process_frame

	_assert(inst._menu.visible, "MainMenu starts visible")

	# Test GameplayGuideModal entry from MainMenu, all 4 tabs, and TouchScrollContainer drag
	var guide_btn := inst._menu.find_child("GuideButton", true, false) as Button
	_assert(guide_btn != null, "MainMenu exposes GuideButton")
	if guide_btn != null:
		guide_btn.pressed.emit()
		await get_tree().process_frame
		await get_tree().process_frame
		_assert(inst._guide.visible, "GameplayGuideModal opens from MainMenu")
		for tab_i in range(4):
			inst._guide.switch_tab(tab_i)
			await get_tree().process_frame
			_assert(inst._guide._content_box.get_child_count() >= 3, "Guide tab %d populates visual content cards" % tab_i)
		inst._guide.switch_tab(2)
		await get_tree().process_frame
		await get_tree().process_frame
		if inst._guide._scroll != null and inst._guide._content_box.get_child_count() > 1:
			var g_scroll := inst._guide._scroll
			_assert(g_scroll.get_v_scroll_bar().max_value > g_scroll.size.y, "Guide tab 2 overflows vertically for scrolling")
			g_scroll.scroll_vertical = 0
			var g_card := inst._guide._content_box.get_child(1) as Control
			var gp := g_card.get_global_rect().get_center()
			await _simulate_touch_drag(gp, gp + Vector2(0, -180), 8)
			_assert(g_scroll.scroll_vertical > 20, "Touch drag over guide cards scrolls GameplayGuideModal (%d)" % g_scroll.scroll_vertical)
		inst._guide.close_modal()
		await get_tree().process_frame
		_assert(not inst._guide.visible, "GameplayGuideModal closes cleanly")

	# Test ChapterSelectScreen vertical TouchScrollContainer drag directly on a chapter Button
	inst._menu.visible = false
	inst._chapters.open()
	await get_tree().process_frame
	await get_tree().process_frame
	_assert(inst._chapters.visible, "ChapterSelectScreen opens cleanly")

	var ch_scroll: TouchScrollContainer = null
	for ch in inst._chapters.find_children("*", "TouchScrollContainer", true, false):
		ch_scroll = ch as TouchScrollContainer
		break
	var ch_btn: Button = null
	for b in inst._chapters.find_children("*", "Button", true, false):
		if b.text != "返回":
			ch_btn = b as Button
			break
	if ch_scroll != null and ch_btn != null:
		ch_scroll.scroll_vertical = 0
		var p := ch_btn.get_global_rect().get_center()
		await _simulate_touch_drag(p, p + Vector2(0, -180), 8)
		_assert(ch_scroll.scroll_vertical > 20, "Vertical drag starting on chapter Button scrolls ChapterSelectScreen (%d)" % ch_scroll.scroll_vertical)
		_assert(inst._chapters.visible, "Dragging on chapter Button does not launch chapter accidentally")
	inst._chapters.visible = false

	# Test AlmanacScreen opens & scrolls cleanly
	inst._almanac.open()
	await get_tree().process_frame
	_assert(inst._almanac.visible, "AlmanacScreen opens cleanly")
	inst._almanac.visible = false

	# Start Chapter 1 live world + HUD + TutorialCoach + mood switch + preview + placement
	inst._start_chapter("ch_01")
	await get_tree().process_frame
	await get_tree().process_frame
	_assert(inst.world.visible and inst.hud.visible, "World and HUD appear when starting chapter")
	_assert(inst.hud.is_tutorial_active() and inst.hud.get_tutorial_step() == 0, "TutorialCoach starts automatically on first Ch1 entry")

	# Verify hand cards expose HexEdgePreview for all tile types
	var hex_prev_count := 0
	for n in inst.hud._hand_box.find_children("*", "", true, false):
		if n is HexEdgePreview:
			hex_prev_count += 1
	_assert(hex_prev_count == inst._state.hand.size(), "All hand cards render HexEdgePreview (%d/%d)" % [hex_prev_count, inst._state.hand.size()])

	# Test horizontal Wonder Craft TouchScrollContainer drag on Wonder Button
	inst.hud._dock_tab = 1
	inst.hud._refresh_dock()
	await get_tree().process_frame
	await get_tree().process_frame
	var wscroll := inst.hud._wonder_scroll
	_assert(wscroll != null and wscroll.get_h_scroll_bar().max_value > wscroll.size.x, "Wonder bar overflows horizontally")
	if wscroll != null and inst.hud._wonder_box.get_child_count() > 0:
		var wbtn := inst.hud._wonder_box.get_child(0) as Control
		var wp := wbtn.get_global_rect().get_center()
		await _simulate_touch_drag(wp, wp + Vector2(-170, 0), 8)
		_assert(wscroll.scroll_horizontal > 20, "Horizontal drag on Wonder card scrolls Wonder bar (%d)" % wscroll.scroll_horizontal)

	# Switch back to Hand, advance interactive TutorialCoach via real actions
	inst.hud._dock_tab = 0
	inst.hud._refresh_dock()
	inst.hud._tutorial_coach._on_next()
	_assert(inst.hud.get_tutorial_step() == 1, "TutorialCoach advances from step 0 -> 1")
	inst._on_rotate()
	_assert(inst.hud.get_tutorial_step() == 2, "Rotating hand card auto-advances TutorialCoach to step 2")

	inst._on_cycle_mood()
	_assert(inst._state.mood_id == "sunset", "Mood cycles cleanly from afternoon -> sunset")
	inst._on_cycle_mood()
	_assert(inst._state.mood_id == "night", "Mood cycles cleanly from sunset -> night")

	inst.world._refresh_preview_at(Vector2i(-1, 0))
	_assert(inst.world.has_active_preview(), "Preview highlights valid slot (-1, 0)")
	_assert(inst.hud.get_tutorial_step() == 3, "Previewing empty slot auto-advances TutorialCoach to step 3")
	inst._on_confirm_place()
	_assert(inst._state.board.size() == 4, "Confirming preview places tile onto board")
	_assert(inst.hud.get_tutorial_step() == 4, "Confirming placement auto-advances TutorialCoach to final step 4")
	inst.hud._tutorial_coach._on_next()
	_assert(not inst.hud.is_tutorial_active() and SaveManager.is_tutorial_seen(), "Completing TutorialCoach persists tutorial_seen = true")

	# Verify HUD guide opens cleanly on UiLayer above GameHud
	var hud_guide_btn := inst.hud.find_child("HudGuideButton", true, false) as Button
	_assert(hud_guide_btn != null, "GameHud exposes HudGuideButton")
	if hud_guide_btn != null:
		hud_guide_btn.pressed.emit()
		await get_tree().process_frame
		_assert(inst._guide.visible and inst.world.input_blocked.call(), "Opening GameplayGuideModal from HUD blocks world input")
		inst._guide.close_modal()

	SaveManager.clear_chapter_resume()
	SaveManager.set_tutorial_seen(orig_tut)
	inst.queue_free()
	await get_tree().process_frame


func _simulate_touch_drag(from_pos: Vector2, to_pos: Vector2, steps: int) -> void:
	var td := InputEventScreenTouch.new()
	td.index = 0
	td.pressed = true
	td.position = from_pos
	get_tree().root.push_input(td)
	await get_tree().process_frame

	var prev := from_pos
	for i in range(1, steps + 1):
		var cur := from_pos.lerp(to_pos, float(i) / float(steps))
		var sd := InputEventScreenDrag.new()
		sd.index = 0
		sd.position = cur
		sd.relative = cur - prev
		prev = cur
		get_tree().root.push_input(sd)
		await get_tree().process_frame

	var tu := InputEventScreenTouch.new()
	tu.index = 0
	tu.pressed = false
	tu.position = to_pos
	get_tree().root.push_input(tu)
	await get_tree().process_frame
