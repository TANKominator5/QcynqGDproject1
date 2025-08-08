shader_type spatial;

render_mode depth_draw_always, cull_back;

uniform vec3 albedo : source_color;
uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
uniform vec2 wave_dir1 = vec2(1.0, 0.0);
uniform vec2 wave_dir2 = vec2(0.0, 1.0);
uniform vec2 wave_dir3 = vec2(1.0, 1.0);

varying vec3 world_pos;

void vertex() {
}

void fragment() {
	vec3 normal_blend = mix(texture(texture_normal, world_pos.xz + wave_dir1).rgb, texture(texture_normal2, world_pos.xz + wave_dir2).rgb, 0.5);
	ALBEDO = albedo;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal_blend;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
