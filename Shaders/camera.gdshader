shader_type canvas_item;
uniform vec4 canvas_color: source_color;
uniform float intensity = 0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color = mix(color, canvas_color, intensity * color.a);

	COLOR = color;
}
