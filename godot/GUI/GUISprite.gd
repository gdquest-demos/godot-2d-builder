tool
class_name GUISprite
extends Control

export var texture: Texture setget _set_texture

export var region_enabled: bool = false setget _set_region_enabled
export var region_rect: Rect2 = Rect2() setget _set_region_rect
export var scale := Vector2.ONE setget _set_scale


func _draw() -> void:
	if not texture:
		return

	if region_enabled:
		draw_texture_rect_region(texture, Rect2(Vector2.ZERO, rect_size), region_rect)
	else:
		draw_texture_rect(texture, Rect2(Vector2.ZERO, rect_size), false)


func _set_texture(value: Texture) -> void:
	texture = value
	_update_region()


func _set_region_enabled(value: bool) -> void:
	region_enabled = value
	_update_region()


func _set_region_rect(value: Rect2) -> void:
	region_rect = value
	_update_region()


func _set_scale(value: Vector2) -> void:
	scale = value
	_update_region()


func _update_region() -> void:
	if region_enabled:
		rect_min_size = region_rect.size * scale
	else:
		if texture:
			rect_min_size = texture.get_size() * scale
		else:
			rect_min_size = Vector2.ZERO
	update()
