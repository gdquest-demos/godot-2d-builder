shader_type canvas_item;

uniform float fill_amount : hint_range(0, 1.0) = 0.0;
uniform vec2 region_position;
uniform vec2 region_size;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec2 texture_size = vec2(textureSize(TEXTURE, 0));

	vec2 region_end = region_position + region_size;

	float pixel_fill = step(UV.x * texture_size.x, fill_amount * region_end.x);
	
	COLOR = clamp(color + (color * pixel_fill), 0, 1);
}