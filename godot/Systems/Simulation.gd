class_name Simulation
extends Node


enum { TYPE_ACTOR, TYPE_WIRE }

export var simulation_speed := 1.0 / 30

var tracker := EntityTracker.new()
onready var power_system := PowerSystem.new(self)

onready var props_map := $GameWorld/YSort/PropsMap


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
