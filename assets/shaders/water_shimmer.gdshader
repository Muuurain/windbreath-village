shader_type canvas_item;

uniform float speed : hint_range(0.1, 3.0) = 0.85;
uniform float shimmer_strength : hint_range(0.0, 0.5) = 0.18;
uniform vec4 shimmer_color : source_color = vec4(0.88, 0.97, 1.0, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float wave = sin(UV.x * 18.0 + TIME * speed * 2.2) * cos(UV.y * 14.0 - TIME * speed * 1.6);
	float glint = smoothstep(0.55, 0.95, wave) * shimmer_strength;
	vec3 rgb = mix(tex.rgb, shimmer_color.rgb, glint * tex.a);
	COLOR = vec4(rgb, tex.a) * COLOR;
}
