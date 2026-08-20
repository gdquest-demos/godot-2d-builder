class_name GroundItem
extends Node2D

var blueprint: BlueprintEntity

@onready var collision_shape := $Area2D/CollisionShape2D
@onready var animation := $AnimationPlayer
@onready var sprite := $Sprite2D
@onready var tween := create_tween()


func setup(_blueprint: BlueprintEntity, location: Vector2) -> void:
	blueprint = _blueprint
	
	var blueprint_sprite := blueprint.get_node("Sprite2D")
	sprite.texture = blueprint_sprite.texture
	sprite.region_enabled = blueprint_sprite.region_enabled
	sprite.region_rect = blueprint_sprite.region_rect
	sprite.centered = blueprint_sprite.centered
	
	global_position = location
	
	_pop()


func do_pickup(target: CharacterBody2D) -> void:
	var travel_distance := 0.1
	
	collision_shape.set_deferred("disabled", true)

	while true:
		var distance_to_target := global_position.distance_to(target.global_position)
		if distance_to_target < 5.0:
			break

		global_position = global_position.move_toward(target.global_position, travel_distance)
		travel_distance += 0.1
		
		await get_tree().process_frame

	queue_free()


func _pop() -> void:
	var direction := Vector2.UP.rotated(randf_range(-PI, PI))
	
	direction.y /= 2.0
	direction *= randf_range(20, 70)

	var target_position := global_position + direction
	
	var height_position := global_position + direction * Vector2(0.5, 2 * -sign(direction.y))

	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		self,
		"global_position",
		height_position,
		0.15,
	).from(global_position)
	
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(
		self, "global_position", target_position, 0.25 
	).from(height_position)
	await tween.tween_interval(0.15).finished
	
	await tween.finished
	animation.play("Float")
