# Central simulation owner. Delegates tasks and triggers system updates.
# Its main purpose is as a central gateway for all world entities, routing
# calls to sub classes and holding settings and config.
class_name Simulation
extends Node


# Time for systems to update at.
export var simulation_speed := 1.0 / 30

# Repository of all placed entities
var tracker := EntityTracker.new()

# The tilemap used to convert positions into indexible vectors
onready var entity_placer := $GameWorld/YSort/EntityPlacer
# System to update power and keep track of power-related entities
onready var power_system := PowerSystem.new()

onready var gui := $GUI


func _ready() -> void:
	$Timer.start(simulation_speed)
	entity_placer.setup(gui.drag_preview)


func place_entity(entity, cellv: Vector2) -> void:
	tracker.place_entity(entity, cellv)


func remove_entity(cellv: Vector2) -> void:
	tracker.remove_entity(cellv)


func is_cell_occupied(cellv: Vector2) -> bool:
	return tracker.is_cell_occupied(cellv)


func convert_to_cell(world_position: Vector2) -> Vector2:
	return entity_placer.world_to_map(world_position)


func _on_Timer_timeout() -> void:
	Events.emit_signal("systems_ticked", simulation_speed)


func get_entity_at(cellv: Vector2) -> Node2D:
	if tracker.is_cell_occupied(cellv):
		return tracker.entities[cellv].entity
	else:
		return null
