# Central simulation owner. Delegates tasks and triggers system updates.
# Its main purpose is as a central gateway for all world entities, routing
# calls to sub classes and holding settings and config.
class_name Simulation
extends Node

const BARRIER_ID := 1
const INVISIBLE_BARRIER_ID := 2

export var simulation_speed := 1.0 / 30.0

var tracker := EntityTracker.new()

onready var _entity_placer := $GameWorld/YSort/EntityPlacer
onready var _power_system := PowerSystem.new()
onready var _work_system := WorkSystem.new()
onready var _gui := $CanvasLayer/GUI
onready var _player := $GameWorld/YSort/Player
onready var _ground := $GameWorld/Ground


func _ready() -> void:
	$Timer.start(simulation_speed)
	_entity_placer.setup(self, $GameWorld/FlatEntities, _gui, _ground, _player)

	var barriers: Array = _ground.get_used_cells_by_id(BARRIER_ID)
	for cellv in barriers:
		_ground.set_cellv(cellv, INVISIBLE_BARRIER_ID)


func place_entity(entity, cellv: Vector2) -> void:
	tracker.place_entity(entity, cellv)


func remove_entity(cellv: Vector2) -> void:
	tracker.remove_entity(cellv)


func is_cell_occupied(cellv: Vector2) -> bool:
	return tracker.is_cell_occupied(cellv)


func get_entity_at(cellv: Vector2) -> Node2D:
	if tracker.is_cell_occupied(cellv):
		return tracker.entities[cellv].entity
	else:
		return null


func _on_Timer_timeout() -> void:
	Events.emit_signal("systems_ticked", simulation_speed)
