extends Node
## Global decoupled event bus for Windbreath Village.

signal sfx_requested(sfx_id: String, pitch_jitter: float)
signal audio_volumes_changed()

signal tile_placed(q: int, r: int, tile_id: String)
signal synergy_triggered(q: int, r: int, label: String, color: Color)
signal resource_gained(q: int, r: int, res_type: String, amount: int)
signal resident_unlocked(resident_id: String)
signal chapter_completed(chapter_id: String, postcard_id: String)
signal toast_requested(msg: String, color: Color)
signal ambient_mode_changed(mode_id: String)
signal village_updated()
