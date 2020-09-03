class_name Simulation
extends Node


export var simulation_speed := 1.0 / 30

var tracker := EntityTracker.new()

onready var props_map := $GameWorld/YSort/PropsMap
onready var power_system := PowerSystem.new()


func _ready() -> void:
	$Timer.start(simulation_speed)


func place_entity(entity, cellv: Vector2, role: int) -> void:
	tracker.place_entity(entity, cellv, role)


func remove_entity(cellv: Vector2) -> void:
	tracker.remove_entity(cellv)


func is_cell_occupied(cellv: Vector2) -> bool:
	return tracker.is_cell_occupied(cellv)


func convert_to_cell(world_position: Vector2) -> Vector2:
	return props_map.world_to_map(world_position)


func _on_Timer_timeout() -> void:
	Events.emit_signal("systems_ticked", simulation_speed)


func get_entity_at(cellv: Vector2) -> Node2D:
	if tracker.is_cell_occupied(cellv):
		return tracker.entities[cellv]
	else:
		return null
