shader_type spatial;

uniform vec3 albedo : source_color;

void vertex() {
}

void fragment() {
	ALBEDO = albedo * 1.3;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
