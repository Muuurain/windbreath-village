class_name HexEdgePreview
extends Control
## Shared mini flat-top hexagon widget showing terrain tint, optional prop/building
## thumbnail, and rotated river (blue) / road (cream) edge connectors.

var _edges: Array[String] = ["grass", "grass", "grass", "grass", "grass", "grass"]
var _is_water: bool = false
var _prop_tex: Texture2D = null
var _highlight: bool = false


func _init(base_edges: Array = [], rot: int = 0, is_water: bool = false, prop_tex_path: String = "", highlight: bool = false) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not base_edges.is_empty():
		setup(base_edges, rot, is_water, prop_tex_path, highlight)


func setup(base_edges: Array, rot: int, is_water: bool, prop_tex_path: String = "", highlight: bool = false) -> void:
	_edges = HexMath.rotated_edges(base_edges, rot)
	_is_water = is_water
	_highlight = highlight
	_prop_tex = null
	if not prop_tex_path.is_empty() and ResourceLoader.exists(prop_tex_path):
		_prop_tex = load(prop_tex_path)
	queue_redraw()


func _draw() -> void:
	var c := size * 0.5
	var rad := minf(size.x * 0.44, size.y * 0.47)
	if rad <= 2.0:
		return

	var pts := HexMath.hex_polygon(rad)
	var poly := PackedVector2Array()
	for p in pts:
		poly.append(c + p)

	var fill_col := Color(0.56, 0.82, 0.72) if _is_water else Color(0.64, 0.84, 0.62)
	var border_col := UiStyles.COL_GOLD if _highlight else Color(0.32, 0.55, 0.40)
	draw_colored_polygon(poly, fill_col)
	poly.append(poly[0])
	draw_polyline(poly, border_col, 2.4 if _highlight else 1.8, true)

	var r_pts: Array[Vector2] = []
	var p_pts: Array[Vector2] = []
	for i in range(6):
		var mp := c + HexMath.edge_midpoint(i, rad)
		if _edges[i] == "river":
			r_pts.append(mp)
		elif _edges[i] == "road":
			p_pts.append(mp)

	# Draw edge connectors out to the hex boundary so directions stay unmistakable behind props
	for rp in r_pts:
		draw_line(c, rp, Color(0.24, 0.56, 0.64, 0.90), 8.2, true)
		draw_line(c, rp, Color(0.38, 0.80, 0.92, 0.98), 5.6, true)
		draw_circle(rp, 3.3, Color(0.38, 0.80, 0.92, 1.0))
	if r_pts.size() == 1 or r_pts.size() >= 3:
		draw_circle(c, 4.0, Color(0.38, 0.80, 0.92, 0.98))

	for pp in p_pts:
		draw_line(c, pp, Color(0.58, 0.46, 0.30, 0.90), 6.2, true)
		draw_line(c, pp, Color(0.95, 0.87, 0.68, 0.98), 4.0, true)
		draw_circle(pp, 2.7, Color(0.95, 0.87, 0.68, 1.0))

	if _prop_tex != null:
		var icon_sz := rad * 1.24
		var rect := Rect2(c - Vector2(icon_sz, icon_sz) * 0.5, Vector2(icon_sz, icon_sz))
		draw_texture_rect(_prop_tex, rect, false)
