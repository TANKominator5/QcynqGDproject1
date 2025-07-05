shader_type spatial;

render_mode depth_draw_always;
//render_mode depth_prepass_alpha;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture , filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture , repeat_disable, filter_linear_mipmap;
uniform vec3 albedo : source_color;
uniform vec3 albedo2 : source_color;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;

uniform vec4 deep_color : source_color;
uniform vec4 shallow_color: source_color;
uniform float beers_law_value = 2;
uniform float depth_offset = -0.75;

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
	float depth_blend_power = clamp(pow(depth_blend, 2.5), 0.0, 1.0);

	vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, depth_blend_power * 2.5).rgb;//for a blurring effect depending on the depth
	vec3 depth_color = mix(shallow_color.rgb, deep_color.rgb, depth_blend_power);//depth is more depth_blend_power is more, effect of shallow color will be less
	vec3 color = mix(screen_color * depth_color, depth_color * 0.25, depth_blend_power * 0.5);

	//for the fresnel effect
	float fresnel = fresnel_value(8, NORMAL, VIEW);
	vec3 surface_color = mix(albedo, albedo2, fresnel);

	//final albedo color calculation
	color = mix(surface_color, color, 0.75);
	ALBEDO = color * 1.3;
	METALLIC = metallic;
	ROUGHNESS = roughness;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
