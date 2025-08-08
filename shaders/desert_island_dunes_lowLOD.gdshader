shader_type spatial;

render_mode depth_draw_always, cull_back;


uniform vec3 albedo : source_color;
uniform float roughness : hint_range(0.0, 1.0) = 1.0;

void vertex() {

}

void fragment() {
	ALBEDO = albedo;
	ROUGHNESS = roughness;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
