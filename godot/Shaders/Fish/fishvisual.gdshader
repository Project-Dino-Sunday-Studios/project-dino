shader_type spatial;
render_mode unshaded;

uniform sampler2D baseImg;
uniform vec4 inner_color : source_color = vec4(0.0, 0.0, 0.6, 1.0);
uniform vec4 outer_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float fresnel_strength : hint_range(0.1, 10.0, 0.1) = 1.0;

uniform float displaceX = 3;
uniform float offset = 0;
uniform float strength = 0.5;
uniform float speed = 1;
uniform float timeOffset = 0;

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

//displacement of vertices
void vertex() {
	vec2 img_uv = UV;
	float area_str = 1.0 - img_uv.y;
	VERTEX.x += sin(img_uv.y * displaceX - (TIME * speed)) * strength * area_str;
	VERTEX.z += sin(img_uv.y * displaceX - (TIME * speed)) * strength * area_str / 2.0 ;
}
//changing the colors
void fragment() {
	vec4 texture_color = texture(baseImg, UV);
	float fres = fresnel(1.0 / fresnel_strength, NORMAL, VIEW);
	vec3 fres_col = fres * outer_color.rgb;
	
	ALBEDO = mix(inner_color.rgb, fres_col.rgb, fres);
	ALPHA = texture_color.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
