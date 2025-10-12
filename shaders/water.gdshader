shader_type spatial;

render_mode depth_draw_always;
//render_mode depth_prepass_alpha;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture , filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture , repeat_disable, filter_linear_mipmap;
uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;

uniform sampler2D texture_normal;
uniform sampler2D texture_normal2;
uniform sampler2D vertex_wave1;//for the vertex shader wave1
uniform sampler2D vertex_wave2;//for the vertex shader wave2
uniform sampler2D vertex_wave3;//for the vertex shader wave2

uniform vec2 normal_wave_dir1 = vec2(2.0, 0.0);
uniform vec2 normal_wave_dir2 = vec2(0.0, 1.0);
uniform float normal_time_scale1 : hint_range(0.0, 1.0) = 0.025;
uniform float normal_time_scale2 : hint_range(0.0, 1.0) = 0.05;

uniform vec2 vertex_wave_dir1 = vec2(1.0, 1.0);
uniform vec2 vertex_wave_dir2 = vec2(0.0, 1.0);
uniform vec2 vertex_wave_dir3 = vec2(1.0, 0.0);
uniform float vertex_time_scale1 : hint_range(0.0, 1.0) = 0.05;
uniform float vertex_time_scale2 : hint_range(0.0, 1.0) = 0.05;
uniform float vertex_time_scale3 : hint_range(0.0, 1.0) = 0.05;

uniform float noise_scale = 0.05;
uniform float height_scale : hint_range(0.0, 10.0) = 0.15;

varying float height;
varying vec3 world_pos;

uniform vec4 deep_color : source_color;
uniform vec4 shallow_color : source_color;
const float beers_law_value = 10.0;
const float depth_offset = -0.75;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec2 wave1 = vertex_wave_dir1 * TIME * vertex_time_scale1;
	vec2 wave2 = vertex_wave_dir2 * TIME * vertex_time_scale2;
	vec2 wave3 = vertex_wave_dir3 * TIME * vertex_time_scale3;
	
	vec4 mix_texture;
	//first pass of mixing
	mix_texture = mix(texture(vertex_wave1, world_pos.xz * noise_scale + wave1), texture(vertex_wave2, world_pos.xz * noise_scale + wave2), 0.5);
	//2nd pass of mixing
	mix_texture = mix(mix_texture, texture(vertex_wave3, world_pos.xz * noise_scale + wave3), 0.3);
	height = mix_texture.r;
	
	VERTEX.y += height * height_scale;
}

float fresnel_value(float amt, vec3 normal, vec3 view){
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amt);
}
void fragment() {
	//for the depth blending
	float depth_texture = texture(DEPTH_TEXTURE, SCREEN_UV).r * 2.0 - 1.0;//DEPTH_TEXTURE is the depth buffer, SCREEN_UV is the uv coord in screen space
	float depth = PROJECTION_MATRIX[3][2] / (depth_texture + PROJECTION_MATRIX[2][2]);//depth_texture is non-linear(exponential), so it is converted into linear
    float depth_blend = exp((depth + VERTEX.z + depth_offset) * -beers_law_value);//Beer Lambert's law e^(-ad)
	//depth + VERTEX.z(view space z of fragment) + dpeth_offset gives the material thickness
	depth_blend = clamp(1.0 - depth_blend, 0.0, 1.0);//reversing the depth blend which is opacity now and clamping bet. 0 and 1

	vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, depth_blend).rgb;//for a blurring effect depending on the depth
	vec3 depth_color = mix(shallow_color.rgb, deep_color.rgb, depth_blend);//depth is more depth_blend_power is more, effect of shallow color will be less
	vec3 color = mix(screen_color * depth_color * 0.3, depth_color, depth_blend);

	vec2 wave1 = normal_wave_dir1 * TIME * normal_time_scale1;
	vec2 wave2 = normal_wave_dir2 * TIME * normal_time_scale2;

	//for the fresnel effect
	float fresnel = fresnel_value(8, NORMAL, VIEW);
	vec3 surface_color = mix(albedo, albedo2, fresnel);

	//final albedo color calculation
	color = mix(surface_color, color, 0.75);
	vec3 normal_blend = mix(texture(texture_normal, world_pos.xz + wave1).rgb, texture(texture_normal2, world_pos.xz + wave2).rgb, 0.5);

	ALBEDO = color * 1.5;
	ROUGHNESS = roughness;
	NORMAL_MAP = normal_blend * 1.34;
	SPECULAR *= 5.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
