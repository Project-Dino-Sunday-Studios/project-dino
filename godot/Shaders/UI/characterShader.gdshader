shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 0.7);
uniform float outline_size : hint_range(0.0, 10.0, 0.1) = 5.0;
uniform float roughness_ammount : hint_range(0.0, 5.0, 0.1) = 2.0;

void vertex() {
	
}

void fragment() {
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
