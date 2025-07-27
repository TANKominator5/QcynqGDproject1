shader_type spatial;

render_mode depth_draw_always, cull_back;

uniform vec3 albedo : source_color;
uniform float roughness : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
uniform sampler2D vertex_wave1;//for the vertex shader wave1
uniform sampler2D vertex_wave2;//for the vertex shader wave2
uniform sampler2D vertex_wave3;
uniform sampler2D vertex_wave4;
uniform sampler2D vertex_wave5;
uniform vec2 wave_dir1 = vec2(1.0, 0.0);
uniform vec2 wave_dir2 = vec2(0.0, 1.0);
uniform vec2 wave_dir3 = vec2(1.0, 1.0);
uniform float noise_scale : hint_range(0.0, 10.0) = 0.1;
uniform float height_scale : hint_range(0.0, 10.0) = 0.45;

varying float height;
varying vec3 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float mix1 = mix(texture(vertex_wave1, world_pos.xz * noise_scale + wave_dir1).r, texture(vertex_wave2, world_pos.xz * noise_scale + wave_dir2).r, 0.5);
	float mix2 = mix(mix1, texture(vertex_wave3, world_pos.xz * noise_scale + wave_dir3).r, 0.5);
	float mix3 = mix(mix2, texture(vertex_wave4, UV).r, 0.9);
	height = mix(mix3, texture(vertex_wave5, UV).r, 0.4);
	
	VERTEX.y += height * height_scale;
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
