shader_type canvas_item;
uniform vec4 target_color: source_color;
uniform vec4 tint_color: source_color;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	if (distance(tex_color.rgb, target_color.rgb) < 0.1) {
		COLOR = vec4(tint_color.rgb, tex_color.a);
	} else {
		COLOR = tex_color;
	}
}