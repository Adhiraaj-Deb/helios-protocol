shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap, repeat_disable;
uniform bool has_texture = false;
uniform float discard_threshold : hint_range(0.0, 1.0) = 0.1;
uniform float roughness : hint_range(0.0, 1.0) = 0.85;

void fragment() {
	vec3 base_color = vec3(0.5, 0.45, 0.4); // Sand/Rock fallback color
	float alpha_val = 1.0;
	
	if (has_texture) {
		vec4 col = texture(albedo_tex, UV);
		base_color = col.rgb;
		
		// Calculate luminance using perceptual weights
		float lum = dot(col.rgb, vec3(0.299, 0.587, 0.114));
		
		// Discard fragments where the texture is essentially black (padding/void)
		if (lum < discard_threshold) {
			alpha_val = 0.0;
		}
	}
	
	ALPHA = alpha_val;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	
	ALBEDO = base_color;
	ROUGHNESS = roughness;
	METALLIC = 0.0;
}
