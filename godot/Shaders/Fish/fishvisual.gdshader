shader_type spatial;
render_mode unshaded;

uniform sampler2D baseImg;
uniform float displaceX = 3;
uniform float offset = 0;
uniform float strength = 0.5;
uniform float speed = 1;
uniform float timeOffset = 0;

//displacement of vertices
void vertex() {
	vec2 img_uv = UV;
	float area_str = img_uv.y;
	VERTEX.x += sin(img_uv.y * displaceX - (TIME * speed)) * strength * area_str;
}
//changing the colors
void fragment() {
	vec4 texture_color = texture(baseImg, UV);
	ALBEDO = texture_color.rgb;
	ALPHA = texture_color.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
