shader_type canvas_item;

uniform float amount : hint_range(0, 1) = 0.0;

//Get MODULATE colour:
varying vec4 MODULATE; 

void vertex() {
	MODULATE = COLOR;
}

void fragment() {
	vec4 mask = texture(TEXTURE, UV);
	float masking_area = mask.r;
	
	float uv_percentage = step(UV.x, amount);
	
	COLOR = vec4(MODULATE.rgb, uv_percentage * masking_area);
}