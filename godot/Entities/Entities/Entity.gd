class_name Entity
extends Node2D


export(String, FILE) var pickup_blueprint: String

var pickup_count := 1 setget , _get_pickup_count


func _setup(blueprint: BlueprintEntity) -> void:
	pass


func _get_pickup_count() -> int:
	return 1
