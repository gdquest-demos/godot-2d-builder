class_name Entity
extends Node2D

@export var deconstruct_filter: String

var pickup_count := 1: get = _get_pickup_count


func _setup(_blueprint) -> void:
	pass


func _get_pickup_count() -> int:
	return 1
