class_name Simulation
extends Node


var tracker := EntityTracker.new()


func place_entity(entity, cellv: Vector2) -> void:
	tracker.place_entity(entity, cellv)


func remove_entity(cellv: Vector2) -> void:
	tracker.remove_entity(cellv)


func is_cell_occupied(cellv: Vector2) -> bool:
	return tracker.is_cell_occupied(cellv)
