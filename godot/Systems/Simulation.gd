# Central simulation owner. Delegates tasks and triggers system updates.
# Its main purpose is as a central gateway for all world entities, routing
# calls to sub classes and holding settings and config.
class_name Simulation
extends Node

const BARRIER_ID := 1
const INVISIBLE_BARRIER_ID := 2

export var simulation_speed := 1.0 / 30.0

var _tracker := EntityTracker.new()

onready var _entity_placer := $GameWorld/YSort/EntityPlacer
onready var _power_system := PowerSystem.new()
onready var _work_system := WorkSystem.new()
onready var _gui := $CanvasLayer/GUI
onready var _player := $GameWorld/YSort/Player
onready var _ground := $GameWorld/Ground


func _ready() -> void:
	$Timer.start(simulation_speed)
	_entity_placer.setup(_tracker, $GameWorld/FlatEntities, _gui, _ground, _player)

	var barriers: Array = _ground.get_used_cells_by_id(BARRIER_ID)
	for cellv in barriers:
		_ground.set_cellv(cellv, INVISIBLE_BARRIER_ID)


func _on_Timer_timeout() -> void:
	Events.emit_signal("systems_ticked", simulation_speed)
