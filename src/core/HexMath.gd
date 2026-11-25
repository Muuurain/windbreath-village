class_name HexMath
extends RefCounted
## Flat-top axial hex grid math matching 280x244 hex base textures (R = 128 px).
## Edge i (0..5) points directly from center toward neighbor DIRS[i]:
## 0:SE(+30°), 1:S(+90°), 2:SW(+150°), 3:NW(+210°), 4:N(+270°), 5:NE(+330°).

const HEX_RADIUS := 128.0
const SQRT3 := 1.7320508075688772

const DIRS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(-1, 1),
	Vector2i(-1, 0),
	Vector2i(0, -1),
	Vector2i(1, -1),
]


static func key(q: int, r: int) -> String:
	return "%d,%d" % [q, r]


static func parse_key(k: String) -> Vector2i:
	var parts := k.split(",")
	if parts.size() != 2:
		return Vector2i.ZERO
	return Vector2i(int(parts[0]), int(parts[1]))


static func axial_to_pixel(q: int, r: int, radius: float = HEX_RADIUS) -> Vector2:
	var x := radius * 1.5 * float(q)
	var y := radius * SQRT3 * (float(r) + float(q) * 0.5)
	return Vector2(x, y)


static func pixel_to_axial(pos: Vector2, radius: float = HEX_RADIUS) -> Vector2i:
	var fq := (2.0 / 3.0 * pos.x) / radius
	var fr := (-1.0 / 3.0 * pos.x + SQRT3 / 3.0 * pos.y) / radius
	return axial_round(fq, fr)


static func axial_round(fq: float, fr: float) -> Vector2i:
	var fs := -fq - fr
	var q := roundf(fq)
	var r := roundf(fr)
	var s := roundf(fs)

	var q_diff := absf(q - fq)
	var r_diff := absf(r - fr)
	var s_diff := absf(s - fs)

	if q_diff > r_diff and q_diff > s_diff:
		q = -r - s
	elif r_diff > s_diff:
		r = -q - s
	return Vector2i(int(q), int(r))


static func neighbors(q: int, r: int) -> Array[Vector2i]:
	var res: Array[Vector2i] = []
	for d in DIRS:
		res.append(Vector2i(q + d.x, r + d.y))
	return res


static func hex_distance(a: Vector2i, b: Vector2i) -> int:
	var dq := a.x - b.x
	var dr := a.y - b.y
	return (absi(dq) + absi(dq + dr) + absi(dr)) / 2


static func rotated_edges(base_edges: Array, rot: int) -> Array[String]:
	var out: Array[String] = []
	var norm := ((rot % 6) + 6) % 6
	for dir_idx in range(6):
		var src_idx := (dir_idx - norm + 6) % 6
		out.append(String(base_edges[src_idx]))
	return out


static func edge_midpoint(dir_idx: int, radius: float = HEX_RADIUS) -> Vector2:
	var ang := PI / 6.0 + float(dir_idx) * (PI / 3.0)
	return Vector2.from_angle(ang) * (radius * SQRT3 * 0.5)


static func hex_polygon(radius: float = HEX_RADIUS) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(6):
		var ang := float(i) * (PI / 3.0)
		pts.append(Vector2.from_angle(ang) * radius)
	return pts
