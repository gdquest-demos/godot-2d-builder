shader_type canvas_item;

uniform float fill_amount : hint_range(0, 1.0) = 0.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float pixel_fill = step(UV.x * 8.0, fill_amount);
	
	COLOR = clamp(color + (color * pixel_fill), 0, 1);
}