class_name GroundEntity
extends Node2D


var blueprint: BlueprintEntity

onready var area := $Area2D
onready var animation := $AnimationPlayer
onready var sprite := $Sprite


func setup(_blueprint: BlueprintEntity) -> void:
	blueprint = _blueprint
	var blueprint_sprite := blueprint.get_node("Sprite")
	sprite.texture = blueprint_sprite.texture
	sprite.region_enabled = blueprint_sprite.region_enabled
	sprite.region_rect = blueprint_sprite.region_rect
	sprite.centered = blueprint_sprite.centered
	

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
