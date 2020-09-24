extends PanelContainer

onready var sprite := $HBoxContainer/Control/Sprite
onready var label := $HBoxContainer/Label


func setup(name: String, texture: Texture, uses_region_rect: bool, region_rect: Rect2) -> void:
	label.text = name
	sprite.texture = texture
	sprite.region_enabled = uses_region_rect
	sprite.region_rect = region_rect
