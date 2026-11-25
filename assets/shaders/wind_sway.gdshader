shader_type canvas_item;

uniform float sway_speed : hint_range(0.2, 4.0) = 1.6;
uniform float sway_amount : hint_range(0.0, 8.0) = 2.6;
uniform float phase_offset = 0.0;

void vertex() {
	float top_weight = clamp(1.0 - UV.y, 0.0, 1.0);
	VERTEX.x += sin(TIME * sway_speed + phase_offset + VERTEX.y * 0.04) * sway_amount * top_weight;
}
