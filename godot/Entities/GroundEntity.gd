class_name GroundEntity
extends Sprite


var blueprint: BlueprintEntity


func setup(_blueprint: BlueprintEntity) -> void:
	blueprint = _blueprint
	var sprite := blueprint.get_node("Sprite")
	texture = sprite.texture
	region_enabled = sprite.region_enabled
	region_rect = sprite.region_rect
	centered = sprite.centered
	scale = Vector2(0.25, 0.25)
	
	var area := Area2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 10
	var collider := CollisionShape2D.new()
	collider.shape = shape
	
	area.add_child(collider)
	add_child(area)
	
