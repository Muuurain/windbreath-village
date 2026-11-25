extends Node
## Static game catalog for Windbreath Village:
## 10 core hex tiles, 5 craftable Wonder Landmarks, 6 cozy residents,
## 6 themed chapters, 4 illustrated postcards, and 4 time-of-day moods.

var tiles: Array[Dictionary] = []
var wonders: Array[Dictionary] = []
var residents: Array[Dictionary] = []
var chapters: Array[Dictionary] = []
var postcards: Array[Dictionary] = []
var moods: Array[Dictionary] = []

var _tile_map: Dictionary = {}
var _resident_map: Dictionary = {}
var _chapter_map: Dictionary = {}
var _postcard_map: Dictionary = {}
var _mood_map: Dictionary = {}


func _ready() -> void:
	_build_tiles()
	_build_residents()
	_build_chapters()
	_build_postcards()
	_build_moods()
	_index_all()


func _index_all() -> void:
	_tile_map.clear()
	for t in tiles:
		_tile_map[String(t["id"])] = t
	for w in wonders:
		_tile_map[String(w["id"])] = w
	_resident_map.clear()
	for r in residents:
		_resident_map[String(r["id"])] = r
	_chapter_map.clear()
	for c in chapters:
		_chapter_map[String(c["id"])] = c
	_postcard_map.clear()
	for p in postcards:
		_postcard_map[String(p["id"])] = p
	_mood_map.clear()
	for m in moods:
		_mood_map[String(m["id"])] = m


func get_tile(id: String) -> Dictionary:
	return _tile_map.get(id, {})


func get_resident(id: String) -> Dictionary:
	return _resident_map.get(id, {})


func get_chapter(id: String) -> Dictionary:
	return _chapter_map.get(id, {})


func get_postcard(id: String) -> Dictionary:
	return _postcard_map.get(id, {})


func get_mood(id: String) -> Dictionary:
	return _mood_map.get(id, {})


func _build_tiles() -> void:
	tiles = [
		{
			"id": "tile_meadow",
			"name": "野花草甸",
			"category": "terrain",
			"base_tex": "res://assets/art/tiles/hex_base_grass.png",
			"prop_tex": "res://assets/art/tiles/prop_meadow.png",
			"edges": ["grass", "grass", "grass", "grass", "grass", "grass"],
			"produces": {"harmony": 2},
			"sway": true,
			"is_water": false,
			"weight": 1.1,
			"desc": "柔和的野花绿地，适合舒展村落轮廓，提升周围生机。",
		},
		{
			"id": "tile_wheat",
			"name": "金色麦田",
			"category": "farm",
			"base_tex": "res://assets/art/tiles/hex_base_farm.png",
			"prop_tex": "res://assets/art/tiles/prop_wheat.png",
			"edges": ["grass", "road", "grass", "grass", "grass", "grass"],
			"produces": {"grain": 3, "harmony": 2},
			"sway": true,
			"is_water": false,
			"weight": 1.4,
			"desc": "邻近溪流/荷塘触发「溪流灌溉」产量翻倍；小路连接村舍可送麦。",
		},
		{
			"id": "tile_tea",
			"name": "翠绿茶园",
			"category": "farm",
			"base_tex": "res://assets/art/tiles/hex_base_farm.png",
			"prop_tex": "res://assets/art/tiles/prop_tea.png",
			"edges": ["grass", "road", "grass", "grass", "grass", "grass"],
			"produces": {"tea": 3, "harmony": 3},
			"sway": true,
			"is_water": false,
			"weight": 1.35,
			"desc": "梯田嫩茶，靠近溪流触发灌溉翻倍，邻近花海提升茶香和煦度。",
		},
		{
			"id": "tile_blossom",
			"name": "樱雪花海",
			"category": "nature",
			"base_tex": "res://assets/art/tiles/hex_base_blossom.png",
			"prop_tex": "res://assets/art/tiles/prop_blossom.png",
			"edges": ["grass", "grass", "road", "grass", "grass", "grass"],
			"produces": {"harmony": 5},
			"sway": true,
			"is_water": false,
			"weight": 1.1,
			"desc": "为相邻农田传粉增香，并让邻接民居成为宜居风景宅。",
		},
		{
			"id": "tile_bamboo",
			"name": "青翠竹林",
			"category": "nature",
			"base_tex": "res://assets/art/tiles/hex_base_bamboo.png",
			"prop_tex": "res://assets/art/tiles/prop_bamboo.png",
			"edges": ["grass", "road", "grass", "grass", "grass", "grass"],
			"produces": {"bamboo": 3, "harmony": 3},
			"sway": true,
			"is_water": false,
			"weight": 1.25,
			"desc": "稳定产出竹木，与民居或温泉亭相邻时散发清幽禅意。",
		},
		{
			"id": "tile_brook_straight",
			"name": "清冽直溪",
			"category": "water",
			"base_tex": "res://assets/art/tiles/hex_base_water.png",
			"prop_tex": "",
			"edges": ["grass", "river", "grass", "grass", "river", "grass"],
			"produces": {"harmony": 3},
			"sway": false,
			"is_water": true,
			"weight": 1.25,
			"desc": "贯穿两侧的清泉小溪，自动灌溉相邻麦田与茶园并驱动水车。",
		},
		{
			"id": "tile_brook_curve",
			"name": "弯月小溪",
			"category": "water",
			"base_tex": "res://assets/art/tiles/hex_base_water.png",
			"prop_tex": "",
			"edges": ["river", "grass", "river", "grass", "grass", "grass"],
			"produces": {"harmony": 3},
			"sway": false,
			"is_water": true,
			"weight": 1.25,
			"desc": "温柔转弯的林间溪流，灵活绕行山坡农田，接通水系。",
		},
		{
			"id": "tile_pond",
			"name": "碧波荷塘",
			"category": "water",
			"base_tex": "res://assets/art/tiles/hex_base_water.png",
			"prop_tex": "res://assets/art/tiles/prop_pond.png",
			"edges": ["river", "grass", "river", "grass", "river", "grass"],
			"produces": {"harmony": 4},
			"sway": false,
			"is_water": true,
			"weight": 0.95,
			"desc": "三向汇水灵泉荷塘，可同时接通三条溪流并吸引溪畔白鹭。",
		},
		{
			"id": "tile_road_cottage",
			"name": "青瓦民居",
			"category": "village",
			"base_tex": "res://assets/art/tiles/hex_base_village.png",
			"prop_tex": "res://assets/art/landmarks/lm_cottage.png",
			"edges": ["grass", "road", "grass", "grass", "road", "grass"],
			"produces": {"harmony": 5},
			"sway": false,
			"is_water": false,
			"has_lantern": true,
			"weight": 1.15,
			"desc": "炊烟袅袅的乡间木屋，连通路网后迎来村民挑货并吸引打盹橘猫。",
		},
		{
			"id": "tile_road_cross",
			"name": "青石岔路",
			"category": "village",
			"base_tex": "res://assets/art/tiles/hex_base_village.png",
			"prop_tex": "res://assets/art/tiles/prop_meadow.png",
			"edges": ["road", "grass", "road", "grass", "road", "grass"],
			"produces": {"harmony": 2},
			"sway": true,
			"is_water": false,
			"weight": 1.0,
			"desc": "三岔石板小路枢纽，方便把农田、工坊与民居连成完整路网。",
		},
	]

	wonders = [
		{
			"id": "wonder_watermill",
			"name": "水车磨坊",
			"category": "wonder",
			"base_tex": "res://assets/art/tiles/hex_base_village.png",
			"prop_tex": "res://assets/art/landmarks/lm_watermill.png",
			"edges": ["road", "river", "grass", "grass", "river", "grass"],
			"produces": {"grain": 4, "harmony": 12},
			"cost": {"grain": 8, "bamboo": 4},
			"sway": false,
			"is_water": true,
			"has_lantern": true,
			"short_desc": "临溪转动 · 周边农田×2",
			"desc": "【风物】临溪而建时扇叶转动，使周围农田产量翻倍并产出丰裕稻穗。",
		},
		{
			"id": "wonder_teahouse",
			"name": "灯笼茶寮",
			"category": "wonder",
			"base_tex": "res://assets/art/tiles/hex_base_village.png",
			"prop_tex": "res://assets/art/landmarks/lm_teahouse.png",
			"edges": ["road", "grass", "road", "grass", "road", "grass"],
			"produces": {"tea": 4, "harmony": 14},
			"cost": {"tea": 8, "bamboo": 5},
			"sway": false,
			"is_water": false,
			"has_lantern": true,
			"short_desc": "路网驿站 · 产茶且宜居",
			"desc": "【风物】村民最爱歇脚的木质茶亭，提升连通民居和煦度并产出佳茗。",
		},
		{
			"id": "wonder_bridge",
			"name": "灯笼木桥",
			"category": "wonder",
			"base_tex": "res://assets/art/tiles/hex_base_water.png",
			"prop_tex": "res://assets/art/landmarks/lm_bridge.png",
			"edges": ["road", "river", "grass", "road", "river", "grass"],
			"produces": {"harmony": 10},
			"cost": {"bamboo": 6, "grain": 4},
			"sway": false,
			"is_water": true,
			"has_lantern": true,
			"short_desc": "水陆双通 · 贯通两岸",
			"desc": "【风物】同时纵贯溪流与横跨石路的拱桥，让两岸村落完美互通！",
		},
		{
			"id": "wonder_windchime",
			"name": "风铃花塔",
			"category": "wonder",
			"base_tex": "res://assets/art/tiles/hex_base_blossom.png",
			"prop_tex": "res://assets/art/landmarks/lm_windchime.png",
			"edges": ["grass", "road", "grass", "grass", "road", "grass"],
			"produces": {"harmony": 16},
			"cost": {"tea": 6, "grain": 6},
			"sway": true,
			"is_water": false,
			"has_lantern": true,
			"short_desc": "风铃和鸣 · 周围全加成",
			"desc": "【风物】微风吹动繁花风铃，为周围一圈全部地块带来额外风物和煦加成。",
		},
		{
			"id": "wonder_hotspring",
			"name": "云泉温泉亭",
			"category": "wonder",
			"base_tex": "res://assets/art/tiles/hex_base_water.png",
			"prop_tex": "res://assets/art/landmarks/lm_hotspring.png",
			"edges": ["grass", "river", "grass", "grass", "road", "grass"],
			"produces": {"harmony": 20},
			"cost": {"tea": 10, "bamboo": 8},
			"sway": false,
			"is_water": true,
			"has_lantern": true,
			"short_desc": "温泉静谧 · 招雪顶小狐",
			"desc": "【风物】热气袅袅的天然石泉亭，吸引珍稀雪顶狐狸前来看景安居。",
		},
	]


func _build_residents() -> void:
	residents = [
		{
			"id": "res_villager_basket",
			"name": "背篓农夫 · 阿禾",
			"sprite": "res://assets/art/characters/char_villager_basket.png",
			"role": "沿着石板小路运送稻穗与茶青",
			"unlock_desc": "任意农田与村居通过石路相连",
			"home_types": ["tile_wheat", "tile_road_cottage", "wonder_watermill"],
			"quote": "「今天风顺，刚割下的麦子带着太阳味。」",
		},
		{
			"id": "res_villager_tea",
			"name": "煮茶婆婆 · 柳姨",
			"sprite": "res://assets/art/characters/char_villager_tea.png",
			"role": "在茶园与茶寮之间奉上热茶",
			"unlock_desc": "拥有至少 2 块茶园或建造 1 座灯笼茶寮",
			"home_types": ["tile_tea", "wonder_teahouse", "tile_road_cottage"],
			"quote": "「路走累了就进亭子歇歇，茶刚温好。」",
		},
		{
			"id": "res_cat_orange",
			"name": "打盹橘猫 · 团子",
			"sprite": "res://assets/art/characters/char_cat_orange.png",
			"role": "蜷在暖洋洋的屋檐与花海旁打呼噜",
			"unlock_desc": "达成至少 2 处「宜居风景宅」邻接",
			"home_types": ["tile_road_cottage", "tile_blossom", "wonder_bridge"],
			"quote": "「呼噜……屋顶的瓦片晒得刚刚好。」",
		},
		{
			"id": "res_egret",
			"name": "溪畔白鹭 · 霜羽",
			"sprite": "res://assets/art/characters/char_egret.png",
			"role": "沿相连清溪巡游并守护农田灌溉",
			"unlock_desc": "拥有 3 格以上相连水系，或建造碧波荷塘/木桥",
			"home_types": ["tile_pond", "tile_brook_straight", "tile_brook_curve", "wonder_bridge"],
			"quote": "「水清草暖，溪里的倒影能照见一整朵云。」",
		},
		{
			"id": "res_traveler",
			"name": "红氅旅人 · 远风",
			"sprite": "res://assets/art/characters/char_traveler.png",
			"role": "漫步风铃花塔与村落长路",
			"unlock_desc": "总地块数达到 12 块且拥有灯笼木桥或风铃花塔",
			"home_types": ["wonder_windchime", "wonder_bridge", "tile_road_cross"],
			"quote": "「走过十座山头，还是这里的风铃声最让人安心。」",
		},
		{
			"id": "res_snowfox",
			"name": "雪顶小狐 · 绒雪",
			"sprite": "res://assets/art/characters/char_snowfox.png",
			"role": "守护云泉温泉亭与青翠竹林",
			"unlock_desc": "建造「云泉温泉亭」且村落和煦度达 90+",
			"home_types": ["wonder_hotspring", "tile_bamboo", "wonder_windchime"],
			"quote": "「泉水暖烘烘的，冬天也不必躲回洞里啦。」",
		},
	]


func _build_chapters() -> void:
	chapters = [
		{
			"id": "ch_01",
			"index": 1,
			"name": "第一章 · 山涧初晴",
			"subtitle": "引溪灌溉 · 连通最初的农田与家舍",
			"default_mood": "afternoon",
			"postcard_id": "pc_01",
			"seed_tiles": [
				{"q": 0, "r": 0, "id": "tile_road_cottage", "rot": 2},
				{"q": 0, "r": -1, "id": "tile_brook_curve", "rot": 0},
				{"q": 1, "r": -1, "id": "tile_tea", "rot": 0},
			],
			"goals": [
				{"type": "irrigated_farms", "target": 2, "desc": "让 2 块农田邻接水系触发「溪流灌溉」"},
				{"type": "road_links", "target": 2, "desc": "连通 2 段村落石路迎接阿禾挑货"},
				{"type": "harmony", "target": 38, "desc": "村落和煦度达到 38"},
			],
		},
		{
			"id": "ch_02",
			"index": 2,
			"name": "第二章 · 水车麦浪",
			"subtitle": "攒聚稻谷竹木 · 竖起旋转的水车磨坊",
			"default_mood": "morning",
			"postcard_id": "pc_02",
			"seed_tiles": [
				{"q": 0, "r": 0, "id": "tile_pond", "rot": 0},
				{"q": -1, "r": 1, "id": "tile_wheat", "rot": 0},
				{"q": 1, "r": 0, "id": "tile_road_cottage", "rot": 1},
			],
			"goals": [
				{"type": "wonder_count", "wonder_id": "wonder_watermill", "target": 1, "desc": "建造 1 座【水车磨坊】"},
				{"type": "residents", "target": 3, "desc": "吸引 3 位村民与小动物安家"},
				{"type": "harmony", "target": 65, "desc": "村落和煦度达到 65"},
			],
		},
		{
			"id": "ch_03",
			"index": 3,
			"name": "第三章 · 花桥暮色",
			"subtitle": "跨溪架起灯笼木桥 · 点亮两岸灯火",
			"default_mood": "sunset",
			"postcard_id": "pc_03",
			"seed_tiles": [
				{"q": 0, "r": 0, "id": "tile_brook_straight", "rot": 0},
				{"q": -1, "r": 0, "id": "tile_road_cottage", "rot": 5},
				{"q": 1, "r": 0, "id": "tile_blossom", "rot": 0},
			],
			"goals": [
				{"type": "wonder_count", "wonder_id": "wonder_bridge", "target": 1, "desc": "建造 1 座【灯笼木桥】跨溪通途"},
				{"type": "scenic_homes", "target": 2, "desc": "打造 2 处「宜居风景宅」(民居邻花海/竹林/荷塘)"},
				{"type": "harmony", "target": 78, "desc": "村落和煦度达到 78"},
			],
		},
		{
			"id": "ch_04",
			"index": 4,
			"name": "第四章 · 萤火茶寮",
			"subtitle": "夜色煮茗听风铃 · 伴随萤火虫入夜",
			"default_mood": "night",
			"postcard_id": "pc_03",
			"seed_tiles": [
				{"q": 0, "r": 0, "id": "tile_tea", "rot": 0},
				{"q": 0, "r": 1, "id": "tile_bamboo", "rot": 0},
				{"q": 1, "r": 0, "id": "tile_pond", "rot": 0},
			],
			"goals": [
				{"type": "wonder_count", "wonder_id": "wonder_teahouse", "target": 1, "desc": "建造 1 座【灯笼茶寮】"},
				{"type": "wonder_count", "wonder_id": "wonder_windchime", "target": 1, "desc": "建造 1 座【风铃花塔】"},
				{"type": "harmony", "target": 95, "desc": "村落和煦度达到 95"},
			],
		},
		{
			"id": "ch_05",
			"index": 5,
			"name": "第五章 · 云泉松风",
			"subtitle": "竹林掩映温泉亭 · 静候雪顶小狐来访",
			"default_mood": "sunset",
			"postcard_id": "pc_04",
			"seed_tiles": [
				{"q": 0, "r": 0, "id": "tile_bamboo", "rot": 0},
				{"q": 0, "r": -1, "id": "tile_brook_straight", "rot": 0},
				{"q": -1, "r": 1, "id": "tile_tea", "rot": 0},
			],
			"goals": [
				{"type": "wonder_count", "wonder_id": "wonder_hotspring", "target": 1, "desc": "建造 1 座【云泉温泉亭】"},
				{"type": "residents", "target": 5, "desc": "吸引 5 位居民(含雪顶小狐)入住"},
				{"type": "harmony", "target": 115, "desc": "村落和煦度达到 115"},
			],
		},
		{
			"id": "ch_06",
			"index": 6,
			"name": "第六章 · 万象桃源",
			"subtitle": "山水茶香俱全 · 筑成心中的风息桃源",
			"default_mood": "afternoon",
			"postcard_id": "pc_04",
			"seed_tiles": [
				{"q": 0, "r": 0, "id": "tile_pond", "rot": 0},
				{"q": 1, "r": -1, "id": "tile_wheat", "rot": 0},
				{"q": -1, "r": 1, "id": "tile_road_cottage", "rot": 0},
			],
			"goals": [
				{"type": "tile_count", "target": 18, "desc": "村落扩张至 18 块地块"},
				{"type": "residents", "target": 6, "desc": "聚齐全部 6 位居民与动物伙伴"},
				{"type": "harmony", "target": 150, "desc": "村落和煦度达到 150"},
			],
		},
	]


func _build_postcards() -> void:
	postcards = [
		{
			"id": "pc_01",
			"title": "山涧茶烟",
			"image": "res://assets/art/postcards/postcard_01.png",
			"caption": "晨雾尚未散尽，茶园的露水沿着溪石流进村口。阿禾踩着第一缕光出门了。",
		},
		{
			"id": "pc_02",
			"title": "金色水轮",
			"image": "res://assets/art/postcards/postcard_02.png",
			"caption": "木质水车吱呀转起，溪水映着饱满麦穗。忙完这一茬，去桥头喝碗新茶吧。",
		},
		{
			"id": "pc_03",
			"title": "萤火木桥夜",
			"image": "res://assets/art/postcards/postcard_03.png",
			"caption": "纸灯笼亮起来时，萤火虫也循着风铃飞过桥面。橘猫团子在栏杆旁睡得正香。",
		},
		{
			"id": "pc_04",
			"title": "红叶云泉",
			"image": "res://assets/art/postcards/postcard_04.png",
			"caption": "枫叶飘落进冒着白气的石泉，远道而来的雪顶小狐也悄悄坐下赏起晚风。",
		},
	]


func _build_moods() -> void:
	moods = [
		{
			"id": "morning",
			"name": "晨曦薄雾",
			"sky_top": Color(0.79, 0.90, 0.89),
			"sky_bot": Color(0.88, 0.94, 0.87),
			"tint": Color(0.95, 0.99, 1.0, 1.0),
			"lantern_power": 0.25,
			"fireflies": false,
			"petals": true,
		},
		{
			"id": "afternoon",
			"name": "午后暖阳",
			"sky_top": Color(0.82, 0.93, 0.86),
			"sky_bot": Color(0.72, 0.87, 0.78),
			"tint": Color(1.0, 0.99, 0.96, 1.0),
			"lantern_power": 0.15,
			"fireflies": false,
			"petals": true,
		},
		{
			"id": "sunset",
			"name": "落日余晖",
			"sky_top": Color(0.96, 0.78, 0.62),
			"sky_bot": Color(0.83, 0.74, 0.68),
			"tint": Color(1.0, 0.88, 0.78, 1.0),
			"lantern_power": 0.75,
			"fireflies": false,
			"petals": true,
		},
		{
			"id": "night",
			"name": "萤火夏夜",
			"sky_top": Color(0.11, 0.16, 0.28),
			"sky_bot": Color(0.15, 0.23, 0.30),
			"tint": Color(0.72, 0.78, 0.94, 1.0),
			"lantern_power": 1.35,
			"fireflies": true,
			"petals": false,
		},
	]
