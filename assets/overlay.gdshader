shader_type spatial;
render_mode unshaded, fog_disabled, depth_draw_never;

uniform sampler2D screen_texture ;
uniform float pixel_size : hint_range(1.0, 20.0, 1.0) = 4.0;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 tex_size = vec2(textureSize(screen_texture, 0));

	// Prevent division by zero.
	float safe_pixel_size = max(pixel_size, 1.0);
	vec2 pixel_count = tex_size / safe_pixel_size;

	vec2 pixelated_uv =
		floor(SCREEN_UV * pixel_count) / pixel_count;

	ALBEDO = texture(screen_texture, pixelated_uv).rgb;

	// Do not write ALPHA for the fullscreen post-process material.
}