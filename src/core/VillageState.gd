class_name VillageState
extends RefCounted
## Complete mutable state of an active village session (chapter or zen sandbox).

var mode: String = "chapter" # "chapter" | "zen"
var chapter_id: String = "ch_01"
var mood_id: String = "afternoon"

## "q,r" -> {"q": int, "r": int, "id": String, "rot": int, "synergies": Array}
var board: Dictionary = {}
var resources: Dictionary = {"grain": 4, "tea": 3, "bamboo": 3}
var harmony: int = 0
var hand: Array[String] = []
var unlocked_residents: Array[String] = []
var metrics: Dictionary = {}
var per_cycle: Dictionary = {"grain": 0, "tea": 0, "bamboo": 0}
var road_edges: Array = []
var water_edges: Array = []
var goal_progress: Array[Dictionary] = []
var chapter_cleared: bool = false
var elapsed_seconds: float = 0.0
var undo_snapshot: Dictionary = {}


func start_chapter(p_chapter_id: String) -> void:
	mode = "chapter"
	chapter_id = p_chapter_id
	var ch := GameData.get_chapter(chapter_id)
	mood_id = String(ch.get("default_mood", "afternoon"))
	board.clear()
	resources = {"grain": 4, "tea": 3, "bamboo": 3}
	hand.clear()
	unlocked_residents.clear()
	chapter_cleared = false
	elapsed_seconds = 0.0
	undo_snapshot.clear()

	for s in ch.get("seed_tiles", []):
		var q := int(s["q"])
		var r := int(s["r"])
		board[HexMath.key(q, r)] = {
			"q": q,
			"r": r,
			"id": String(s["id"]),
			"rot": int(s.get("rot", 0)),
			"synergies": [],
		}

	_refill_hand()
	recalculate(false)


func start_zen(p_mood: String = "afternoon") -> void:
	mode = "zen"
	chapter_id = ""
	mood_id = p_mood
	board.clear()
	resources = {"grain": 10, "tea": 10, "bamboo": 10}
	hand.clear()
	unlocked_residents.clear()
	chapter_cleared = false
	elapsed_seconds = 0.0
	undo_snapshot.clear()

	var seeds := [
		{"q": 0, "r": 0, "id": "tile_pond", "rot": 0},
		{"q": 1, "r": -1, "id": "tile_wheat", "rot": 0},
		{"q": -1, "r": 1, "id": "tile_road_cottage", "rot": 0},
		{"q": 0, "r": 1, "id": "tile_tea", "rot": 4},
	]
	for s in seeds:
		var q := int(s["q"])
		var r := int(s["r"])
		board[HexMath.key(q, r)] = {
			"q": q,
			"r": r,
			"id": String(s["id"]),
			"rot": int(s["rot"]),
			"synergies": [],
		}

	_refill_hand()
	recalculate(false)


func _refill_hand() -> void:
	while hand.size() < 3:
		hand.append(EcosystemEngine.pick_smart_hand_tile(board, hand))


func can_afford_wonder(wonder_id: String) -> bool:
	var wdef := GameData.get_tile(wonder_id)
	if wdef.is_empty():
		return false
	var cost: Dictionary = wdef.get("cost", {})
	for k in cost.keys():
		if int(resources.get(k, 0)) < int(cost[k]):
			return false
	return true


func place_hand_tile(hand_idx: int, q: int, r: int, rot: int) -> Dictionary:
	if hand_idx < 0 or hand_idx >= hand.size():
		return {"ok": false}
	var tid := hand[hand_idx]
	var preview := EcosystemEngine.evaluate_placement_preview(board, tid, q, r, rot)
	if not bool(preview["valid"]):
		return {"ok": false}

	undo_snapshot = to_dict(false)

	board[HexMath.key(q, r)] = {
		"q": q,
		"r": r,
		"id": tid,
		"rot": ((rot % 6) + 6) % 6,
		"synergies": [],
	}
	hand.remove_at(hand_idx)
	_refill_hand()

	var gained := _grant_placement_yield(tid, preview)
	var unlocked_new := recalculate(true)
	EventBus.tile_placed.emit(q, r, tid)
	EventBus.village_updated.emit()

	return {
		"ok": true,
		"preview": preview,
		"gained": gained,
		"unlocked_residents": unlocked_new,
	}


func craft_wonder(wonder_id: String, q: int, r: int, rot: int) -> Dictionary:
	if not can_afford_wonder(wonder_id):
		return {"ok": false, "reason": "insufficient_resources"}
	var preview := EcosystemEngine.evaluate_placement_preview(board, wonder_id, q, r, rot)
	if not bool(preview["valid"]):
		return {"ok": false, "reason": "invalid_slot"}

	undo_snapshot = to_dict(false)

	var wdef := GameData.get_tile(wonder_id)
	var cost: Dictionary = wdef.get("cost", {})
	for k in cost.keys():
		resources[k] = maxi(0, int(resources.get(k, 0)) - int(cost[k]))

	board[HexMath.key(q, r)] = {
		"q": q,
		"r": r,
		"id": wonder_id,
		"rot": ((rot % 6) + 6) % 6,
		"synergies": [],
	}

	var gained := _grant_placement_yield(wonder_id, preview)
	var unlocked_new := recalculate(true)
	EventBus.tile_placed.emit(q, r, wonder_id)
	EventBus.village_updated.emit()

	return {
		"ok": true,
		"preview": preview,
		"gained": gained,
		"unlocked_residents": unlocked_new,
	}


func _grant_placement_yield(tid: String, preview: Dictionary) -> Dictionary:
	var tdef := GameData.get_tile(tid)
	var prod: Dictionary = tdef.get("produces", {})
	var syn_tags: Array = preview.get("synergy_tags", [])
	var bonus := 1 if syn_tags.size() > 0 else 0
	var gained := {}
	for rk in ["grain", "tea", "bamboo"]:
		var amt := int(prod.get(rk, 0))
		if amt > 0:
			var total_amt := amt + bonus
			resources[rk] = int(resources.get(rk, 0)) + total_amt
			gained[rk] = total_amt
	if gained.is_empty() and (int(preview.get("matched_rivers", 0)) > 0 or int(preview.get("matched_roads", 0)) > 0):
		var pick := "tea" if tid.contains("tea") or tid.contains("blossom") else ("bamboo" if tid.contains("bamboo") or tid.contains("pond") else "grain")
		resources[pick] = int(resources.get(pick, 0)) + 1
		gained[pick] = 1
	return gained


func cycle_hand_slot(hand_idx: int) -> bool:
	if hand_idx < 0 or hand_idx >= hand.size():
		return false
	var old_id := hand[hand_idx]
	var exclude := hand.duplicate()
	var next_id := EcosystemEngine.pick_smart_hand_tile(board, exclude)
	if next_id == old_id:
		next_id = "tile_meadow"
	hand[hand_idx] = next_id
	EventBus.village_updated.emit()
	return true


func undo_last_move() -> bool:
	if undo_snapshot.is_empty():
		return false
	var snap := undo_snapshot.duplicate(true)
	from_dict(snap)
	undo_snapshot.clear()
	EventBus.village_updated.emit()
	return true


func produce_tick_yield() -> Dictionary:
	var gained := {}
	for rk in ["grain", "tea", "bamboo"]:
		var rate := int(per_cycle.get(rk, 0))
		if rate <= 0:
			continue
		var amt := maxi(1, int(ceilf(float(rate) * 0.22)))
		resources[rk] = mini(999, int(resources.get(rk, 0)) + amt)
		gained[rk] = amt
	if not gained.is_empty():
		EventBus.village_updated.emit()
	return gained


func recalculate(notify: bool = true) -> Array[String]:
	var prev_res := unlocked_residents.duplicate()
	var eval := EcosystemEngine.recalculate(self)
	harmony = int(eval["harmony"])
	per_cycle = eval["per_cycle"]
	road_edges = eval["road_edges"]
	water_edges = eval["water_edges"]
	metrics = eval["metrics"]
	unlocked_residents = eval["unlocked_residents"]

	var newly_unlocked: Array[String] = []
	for rid in unlocked_residents:
		if not prev_res.has(rid):
			newly_unlocked.append(rid)
			if notify:
				EventBus.resident_unlocked.emit(rid)

	if mode == "chapter" and not chapter_id.is_empty():
		goal_progress = EcosystemEngine.evaluate_chapter_goals(chapter_id, metrics)
		var all_done := not goal_progress.is_empty()
		for g in goal_progress:
			if not bool(g["done"]):
				all_done = false
				break
		if all_done and not chapter_cleared:
			chapter_cleared = true
			if notify:
				var pc := String(GameData.get_chapter(chapter_id).get("postcard_id", "pc_01"))
				EventBus.chapter_completed.emit(chapter_id, pc)
	else:
		goal_progress.clear()

	return newly_unlocked


func to_dict(include_undo: bool = true) -> Dictionary:
	var d := {
		"mode": mode,
		"chapter_id": chapter_id,
		"mood_id": mood_id,
		"board": board.duplicate(true),
		"resources": resources.duplicate(true),
		"hand": hand.duplicate(),
		"unlocked_residents": unlocked_residents.duplicate(),
		"chapter_cleared": chapter_cleared,
		"elapsed_seconds": elapsed_seconds,
	}
	if include_undo and not undo_snapshot.is_empty():
		d["undo_snapshot"] = undo_snapshot.duplicate(true)
	return d


func from_dict(d: Dictionary) -> void:
	mode = String(d.get("mode", "chapter"))
	chapter_id = String(d.get("chapter_id", "ch_01"))
	mood_id = String(d.get("mood_id", "afternoon"))
	board = (d.get("board", {}) as Dictionary).duplicate(true)
	resources = (d.get("resources", {"grain": 4, "tea": 3, "bamboo": 3}) as Dictionary).duplicate(true)

	hand.clear()
	for h in d.get("hand", []):
		hand.append(String(h))
	_refill_hand()

	unlocked_residents.clear()
	for r in d.get("unlocked_residents", []):
		unlocked_residents.append(String(r))

	chapter_cleared = bool(d.get("chapter_cleared", false))
	elapsed_seconds = float(d.get("elapsed_seconds", 0.0))
	undo_snapshot = (d.get("undo_snapshot", {}) as Dictionary).duplicate(true)
	recalculate(false)
