class_name GroundEntity
extends Sprite


var blueprint: BlueprintEntity
var area: Area2D


func setup(_blueprint: BlueprintEntity) -> void:
	blueprint = _blueprint
	var sprite := blueprint.get_node("Sprite")
	texture = sprite.texture
	region_enabled = sprite.region_enabled
	region_rect = sprite.region_rect
	centered = sprite.centered
	scale = Vector2(0.25, 0.25)
	
	area = Area2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 10
	var collider := CollisionShape2D.new()
	collider.shape = shape
	
	area.add_child(collider)
	add_child(area)
	

func do_pickup(target: KinematicBody2D) -> void:
	var elapsed_time := 0.1
	area.monitoring = false
	while true:
		var distance_to_target := global_position.distance_to(target.global_position)
		if distance_to_target < 5.0:
			queue_free()
			return

		global_position = global_position.move_toward(target.global_position, elapsed_time)
		elapsed_time += 0.1
		yield(get_tree(), "idle_frame")
