extends Node
## Persistent progression & auto-save manager for Windbreath Village.
## Handles meta progression (completed chapters, postcards, resident almanac, settings)
## as well as chapter resume and endless Zen sandbox persistence.

const META_PATH := "user://windbreath_meta.json"
const RESUME_PATH := "user://windbreath_chapter_resume.json"
const ZEN_PATH := "user://windbreath_zen_village.json"

var meta_data: Dictionary = {}


func _ready() -> void:
	load_meta()


func _default_meta() -> Dictionary:
	return {
		"completed_chapters": [],
		"unlocked_postcards": [],
		"unlocked_residents": [],
		"total_tiles_placed": 0,
		"best_zen_harmony": 0,
		"tutorial_seen": false,
		"settings": {
			"bgm_volume": 0.65,
			"amb_volume": 0.60,
			"sfx_volume": 0.80,
			"rain_enabled": false,
			"haptics": true,
		},
	}


func load_meta() -> void:
	if not FileAccess.file_exists(META_PATH):
		meta_data = _default_meta()
		save_meta()
		return
	var f := FileAccess.open(META_PATH, FileAccess.READ)
	if f == null:
		meta_data = _default_meta()
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if parsed is Dictionary:
		meta_data = _default_meta()
		for k in (parsed as Dictionary).keys():
			if k == "settings" and parsed["settings"] is Dictionary:
				for sk in (parsed["settings"] as Dictionary).keys():
					meta_data["settings"][sk] = parsed["settings"][sk]
			else:
				meta_data[k] = parsed[k]
	else:
		meta_data = _default_meta()


func save_meta() -> void:
	var f := FileAccess.open(META_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(meta_data, "\t"))


func get_setting(key: String, default_val: Variant = null) -> Variant:
	var settings: Dictionary = meta_data.get("settings", {})
	return settings.get(key, default_val)


func set_setting(key: String, val: Variant) -> void:
	if not meta_data.has("settings"):
		meta_data["settings"] = {}
	meta_data["settings"][key] = val
	save_meta()
	EventBus.audio_volumes_changed.emit()


func is_chapter_unlocked(index_num: int) -> bool:
	if index_num <= 1:
		return true
	var prev_id := "ch_%02d" % (index_num - 1)
	return (meta_data.get("completed_chapters", []) as Array).has(prev_id)


func is_chapter_completed(ch_id: String) -> bool:
	return (meta_data.get("completed_chapters", []) as Array).has(ch_id)


func record_tile_placed(state: VillageState) -> void:
	meta_data["total_tiles_placed"] = int(meta_data.get("total_tiles_placed", 0)) + 1
	var res_arr: Array = meta_data.get("unlocked_residents", [])
	for r in state.unlocked_residents:
		if not res_arr.has(r):
			res_arr.append(r)
	meta_data["unlocked_residents"] = res_arr
	if state.mode == "zen":
		meta_data["best_zen_harmony"] = maxi(int(meta_data.get("best_zen_harmony", 0)), state.harmony)
	save_meta()


func record_chapter_complete(ch_id: String, postcard_id: String, state: VillageState) -> void:
	var chs: Array = meta_data.get("completed_chapters", [])
	if not chs.has(ch_id):
		chs.append(ch_id)
	meta_data["completed_chapters"] = chs

	var pcs: Array = meta_data.get("unlocked_postcards", [])
	if not postcard_id.is_empty() and not pcs.has(postcard_id):
		pcs.append(postcard_id)
	meta_data["unlocked_postcards"] = pcs

	record_tile_placed(state)


func save_session(state: VillageState) -> void:
	if state == null:
		return
	var path := ZEN_PATH if state.mode == "zen" else RESUME_PATH
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(state.to_dict()))


func has_chapter_resume() -> bool:
	return FileAccess.file_exists(RESUME_PATH)


func has_zen_save() -> bool:
	return FileAccess.file_exists(ZEN_PATH)


func load_session(is_zen: bool) -> VillageState:
	var path := ZEN_PATH if is_zen else RESUME_PATH
	if not FileAccess.file_exists(path):
		return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if not (parsed is Dictionary):
		return null
	var st := VillageState.new()
	st.from_dict(parsed as Dictionary)
	return st


func clear_chapter_resume() -> void:
	if FileAccess.file_exists(RESUME_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RESUME_PATH))


func clear_zen_save() -> void:
	if FileAccess.file_exists(ZEN_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(ZEN_PATH))


func is_tutorial_seen() -> bool:
	return bool(meta_data.get("tutorial_seen", false))


func set_tutorial_seen(seen: bool = true) -> void:
	meta_data["tutorial_seen"] = seen
	save_meta()
