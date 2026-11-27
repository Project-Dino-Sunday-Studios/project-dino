shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float strength : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float speed : hint_range(0.0, 1.0, 0.1) = 0.5;

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 new_color = texture(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb;
	new_color = vec3(1.0 - new_color);
	COLOR.rgb = new_color;
}
