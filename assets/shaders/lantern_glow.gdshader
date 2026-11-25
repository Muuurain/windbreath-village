shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.84, 0.45, 0.72);
uniform float intensity : hint_range(0.0, 2.0) = 0.8;
uniform float pulse_speed : hint_range(0.2, 4.0) = 1.8;

void fragment() {
	float d = distance(UV, vec2(0.5));
	float falloff = smoothstep(0.5, 0.0, d);
	float pulse = 0.86 + 0.14 * sin(TIME * pulse_speed);
	COLOR = vec4(glow_color.rgb, glow_color.a * falloff * falloff * intensity * pulse);
}
