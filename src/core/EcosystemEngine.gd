class_name EcosystemEngine
extends RefCounted
## Evaluates hex edge connections, ecological synergies, villager logistics paths,
## resident unlocks, and chapter objective progress deterministically.


static func can_place_at(board: Dictionary, q: int, r: int) -> bool:
	if board.has(HexMath.key(q, r)):
		return false
	if board.is_empty():
		return q == 0 and r == 0
	for nb in HexMath.neighbors(q, r):
		if board.has(HexMath.key(nb.x, nb.y)):
			return true
	return false


static func get_open_slots(board: Dictionary) -> Array[Vector2i]:
	if board.is_empty():
		return [Vector2i.ZERO]
	var seen := {}
	var out: Array[Vector2i] = []
	for k in board.keys():
		var pos := HexMath.parse_key(String(k))
		for nb in HexMath.neighbors(pos.x, pos.y):
			var nk := HexMath.key(nb.x, nb.y)
			if not board.has(nk) and not seen.has(nk):
				seen[nk] = true
				out.append(nb)
	return out


static func _get_edges_at(entry: Dictionary) -> Array[String]:
	var tdef := GameData.get_tile(String(entry.get("id", "")))
	if tdef.is_empty():
		return ["grass", "grass", "grass", "grass", "grass", "grass"]
	return HexMath.rotated_edges(tdef.get("edges", []), int(entry.get("rot", 0)))


static func evaluate_placement_preview(board: Dictionary, tile_id: String, q: int, r: int, rot: int) -> Dictionary:
	var valid := can_place_at(board, q, r)
	var tdef := GameData.get_tile(tile_id)
	if not valid or tdef.is_empty():
		return {
			"valid": false,
			"matched_rivers": 0,
			"matched_roads": 0,
			"synergy_tags": [] as Array[String],
			"harmony_gain": 0,
			"highlight_coords": [] as Array[Vector2i],
		}

	var my_edges := HexMath.rotated_edges(tdef.get("edges", []), rot)
	var matched_rivers := 0
	var matched_roads := 0
	var highlights: Array[Vector2i] = []
	var tags: Array[String] = []

	var has_adj_water := false
	var has_adj_nature_beauty := false
	var has_adj_farm := false
	var has_adj_cottage := false
	var has_adj_windchime := false

	for dir_idx in range(6):
		var nb := Vector2i(q, r) + HexMath.DIRS[dir_idx]
		var nk := HexMath.key(nb.x, nb.y)
		if not board.has(nk):
			continue
		var nb_entry: Dictionary = board[nk]
		var nb_id := String(nb_entry.get("id", ""))
		var nb_def := GameData.get_tile(nb_id)
		var nb_edges := _get_edges_at(nb_entry)
		var opp := (dir_idx + 3) % 6

		var e_mine := my_edges[dir_idx]
		var e_nb := nb_edges[opp]
		if e_mine == "river" and e_nb == "river":
			matched_rivers += 1
			if not highlights.has(nb):
				highlights.append(nb)
		elif e_mine == "road" and e_nb == "road":
			matched_roads += 1
			if not highlights.has(nb):
				highlights.append(nb)

		if bool(nb_def.get("is_water", false)):
			has_adj_water = true
		if nb_id in ["tile_blossom", "tile_bamboo", "tile_pond", "wonder_windchime", "wonder_hotspring"]:
			has_adj_nature_beauty = true
		if String(nb_def.get("category", "")) == "farm":
			has_adj_farm = true
		if nb_id in ["tile_road_cottage", "wonder_teahouse"]:
			has_adj_cottage = true
		if nb_id == "wonder_windchime":
			has_adj_windchime = true

	var cat := String(tdef.get("category", ""))
	if matched_rivers > 0:
		tags.append("水系连通 +%d" % (matched_rivers * 3))
	if matched_roads > 0:
		tags.append("石路连通 +%d" % (matched_roads * 2))

	if cat == "farm" and has_adj_water:
		tags.append("溪流灌溉 ×2")
	if bool(tdef.get("is_water", false)) and has_adj_farm:
		tags.append("灌溉相邻农田")
	if tile_id in ["tile_road_cottage", "wonder_teahouse"] and has_adj_nature_beauty:
		tags.append("宜居风景宅 +4")
	if tile_id in ["tile_blossom", "tile_bamboo", "tile_pond"] and has_adj_cottage:
		tags.append("美化邻舍 +4")
	if tile_id == "wonder_watermill" and (has_adj_water or has_adj_farm):
		tags.append("水力丰收 ×2")
	if tile_id == "wonder_bridge" and matched_rivers > 0 and matched_roads > 0:
		tags.append("跨溪通途 +6")
	if tile_id == "wonder_hotspring" and has_adj_nature_beauty:
		tags.append("温泉静谧 +6")
	if has_adj_windchime:
		tags.append("风铃和鸣 +3")

	var base_h := int((tdef.get("produces", {}) as Dictionary).get("harmony", 2))
	var bonus_h := matched_rivers * 3 + matched_roads * 2 + tags.size() * 2
	return {
		"valid": true,
		"matched_rivers": matched_rivers,
		"matched_roads": matched_roads,
		"synergy_tags": tags,
		"harmony_gain": base_h + bonus_h,
		"highlight_coords": highlights,
	}


static func recalculate(state: Variant) -> Dictionary:
	var board: Dictionary = state.board
	var total_harmony := 0
	var irrigated_farms := 0
	var scenic_homes := 0
	var road_links := 0
	var water_links := 0
	var farm_cottage_connected := false
	var tea_count := 0
	var road_edges: Array = []
	var water_edges: Array = []
	var wonder_counts: Dictionary = {}
	var per_cycle := {"grain": 0, "tea": 0, "bamboo": 0}

	var edge_cache: Dictionary = {}
	for k in board.keys():
		edge_cache[k] = _get_edges_at(board[k])

	# 1. Count unique road/water connections
	for k in board.keys():
		var pos := HexMath.parse_key(String(k))
		var edges_a: Array[String] = edge_cache[k]
		for dir_idx: int in [0, 1, 2]:
			var nb := pos + HexMath.DIRS[dir_idx]
			var nk := HexMath.key(nb.x, nb.y)
			if not board.has(nk):
				continue
			var edges_b: Array[String] = edge_cache[nk]
			var opp := (dir_idx + 3) % 6
			if edges_a[dir_idx] == "road" and edges_b[opp] == "road":
				road_links += 1
				road_edges.append([pos, nb])
			elif edges_a[dir_idx] == "river" and edges_b[opp] == "river":
				water_links += 1
				water_edges.append([pos, nb])

	# 2. Evaluate per-tile synergies & production
	for k in board.keys():
		var entry: Dictionary = board[k]
		var pos := HexMath.parse_key(String(k))
		var tid := String(entry.get("id", ""))
		var tdef := GameData.get_tile(tid)
		if tdef.is_empty():
			continue

		var cat := String(tdef.get("category", ""))
		if cat == "wonder":
			wonder_counts[tid] = int(wonder_counts.get(tid, 0)) + 1
		if tid == "tile_tea":
			tea_count += 1

		var has_adj_water := false
		var has_adj_beauty := false
		var has_adj_mill := false
		var has_adj_windchime := false
		var has_adj_road_farm_link := false
		var adj_road_matches := 0

		var my_edges: Array[String] = edge_cache[k]
		for dir_idx in range(6):
			var nb := pos + HexMath.DIRS[dir_idx]
			var nk := HexMath.key(nb.x, nb.y)
			if not board.has(nk):
				continue
			var nb_entry: Dictionary = board[nk]
			var nb_id := String(nb_entry.get("id", ""))
			var nb_def := GameData.get_tile(nb_id)
			var nb_edges: Array[String] = edge_cache[nk]
			var opp := (dir_idx + 3) % 6

			if bool(nb_def.get("is_water", false)):
				has_adj_water = true
			if nb_id in ["tile_blossom", "tile_bamboo", "tile_pond", "wonder_windchime", "wonder_hotspring"]:
				has_adj_beauty = true
			if nb_id == "wonder_watermill":
				has_adj_mill = true
			if nb_id == "wonder_windchime":
				has_adj_windchime = true
			if my_edges[dir_idx] == "road" and nb_edges[opp] == "road":
				adj_road_matches += 1
				if String(nb_def.get("category", "")) == "farm" or tid == "tile_road_cottage":
					has_adj_road_farm_link = true

		if (tid == "tile_road_cottage" or tid == "wonder_teahouse") and has_adj_road_farm_link:
			farm_cottage_connected = true

		var tile_syns: Array[String] = []
		var prod: Dictionary = tdef.get("produces", {})
		var h_val := int(prod.get("harmony", 2))
		var mult := 1

		if cat == "farm" and has_adj_water:
			irrigated_farms += 1
			mult = 2
			h_val += 3
			tile_syns.append("irrigation")
		if has_adj_mill and cat == "farm":
			mult = maxi(mult, 2)
			h_val += 3
			tile_syns.append("hydro")
		if (tid == "tile_road_cottage" or tid == "wonder_teahouse") and has_adj_beauty:
			scenic_homes += 1
			h_val += 4
			tile_syns.append("scenic")
		if has_adj_windchime:
			h_val += 3
			tile_syns.append("windchime")
		if adj_road_matches > 0 and cat in ["farm", "village", "wonder"]:
			h_val += adj_road_matches * 2

		entry["synergies"] = tile_syns
		total_harmony += h_val

		per_cycle["grain"] = int(per_cycle["grain"]) + int(prod.get("grain", 0)) * mult
		per_cycle["tea"] = int(per_cycle["tea"]) + int(prod.get("tea", 0)) * mult
		per_cycle["bamboo"] = int(per_cycle["bamboo"]) + int(prod.get("bamboo", 0))

	total_harmony += road_links * 2 + water_links * 3

	# 3. Determine unlocked residents
	var water_tile_count := 0
	for k in board.keys():
		var tdef := GameData.get_tile(String(board[k].get("id", "")))
		if bool(tdef.get("is_water", false)):
			water_tile_count += 1

	var unlocked: Array[String] = []
	if road_links >= 1 and (farm_cottage_connected or irrigated_farms >= 1):
		unlocked.append("res_villager_basket")
	if tea_count >= 2 or int(wonder_counts.get("wonder_teahouse", 0)) >= 1:
		unlocked.append("res_villager_tea")
	if scenic_homes >= 2:
		unlocked.append("res_cat_orange")
	if water_links >= 2 or water_tile_count >= 3 or int(wonder_counts.get("wonder_bridge", 0)) >= 1:
		unlocked.append("res_egret")
	if board.size() >= 12 and (int(wonder_counts.get("wonder_bridge", 0)) >= 1 or int(wonder_counts.get("wonder_windchime", 0)) >= 1):
		unlocked.append("res_traveler")
	if int(wonder_counts.get("wonder_hotspring", 0)) >= 1 and total_harmony >= 90:
		unlocked.append("res_snowfox")

	var metrics := {
		"tile_count": board.size(),
		"irrigated_farms": irrigated_farms,
		"scenic_homes": scenic_homes,
		"road_links": road_links,
		"water_links": water_links,
		"harmony": total_harmony,
		"wonder_counts": wonder_counts,
		"residents": unlocked.size(),
	}

	return {
		"harmony": total_harmony,
		"per_cycle": per_cycle,
		"road_edges": road_edges,
		"water_edges": water_edges,
		"unlocked_residents": unlocked,
		"metrics": metrics,
	}


static func evaluate_chapter_goals(chapter_id: String, metrics: Dictionary) -> Array[Dictionary]:
	var ch := GameData.get_chapter(chapter_id)
	var out: Array[Dictionary] = []
	if ch.is_empty():
		return out

	var wcounts: Dictionary = metrics.get("wonder_counts", {})
	for g in ch.get("goals", []):
		var gtype := String(g["type"])
		var target := int(g["target"])
		var cur := 0
		match gtype:
			"irrigated_farms":
				cur = int(metrics.get("irrigated_farms", 0))
			"scenic_homes":
				cur = int(metrics.get("scenic_homes", 0))
			"road_links":
				cur = int(metrics.get("road_links", 0))
			"harmony":
				cur = int(metrics.get("harmony", 0))
			"residents":
				cur = int(metrics.get("residents", 0))
			"tile_count":
				cur = int(metrics.get("tile_count", 0))
			"wonder_count":
				cur = int(wcounts.get(String(g.get("wonder_id", "")), 0))
		out.append({
			"desc": String(g["desc"]),
			"current": mini(cur, target),
			"target": target,
			"done": cur >= target,
		})
	return out


static func pick_smart_hand_tile(board: Dictionary, current_hand: Array[String]) -> String:
	var pool: Array[Dictionary] = []
	var total_w := 0.0

	var water_n := 0
	var farm_n := 0
	var village_n := 0
	for k in board.keys():
		var tdef := GameData.get_tile(String(board[k].get("id", "")))
		var cat := String(tdef.get("category", ""))
		if bool(tdef.get("is_water", false)):
			water_n += 1
		if cat == "farm":
			farm_n += 1
		elif cat == "village":
			village_n += 1

	for t in GameData.tiles:
		var tid := String(t["id"])
		if current_hand.has(tid):
			continue
		var w := float(t.get("weight", 1.0))
		var cat := String(t.get("category", ""))
		if bool(t.get("is_water", false)) and water_n < maxi(2, farm_n):
			w *= 1.35
		elif cat == "farm" and farm_n <= water_n:
			w *= 1.3
		elif cat == "village" and village_n < 2:
			w *= 1.3
		pool.append({"id": tid, "w": w})
		total_w += w

	if pool.is_empty():
		return "tile_meadow"
	var roll := randf() * total_w
	var acc := 0.0
	for item in pool:
		acc += float(item["w"])
		if roll <= acc:
			return String(item["id"])
	return String(pool[0]["id"])
