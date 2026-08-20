# Central simulation owner. Delegates tasks and triggers system updates.
# Its main purpose is as a central gateway for all world entities, routing
# calls to sub classes and holding settings and config.
class_name Simulation
extends Node

const BARRIER_ID := 1
# Atlas source ID
const INVISIBLE_BARRIER_ID := 2
# Position in atlas
const INVISIBLE_BARRIER_POSITION_IN_ATLAS := Vector2i(5, 2)

@export var simulation_speed := 1.0 / 30.0

var _tracker := EntityTracker.new()

@onready var _entity_placer := $GameWorld/Node2D/EntityPlacer


@warning_ignore("unused_private_class_variable")
@onready var _power_system := PowerSystem.new()
@warning_ignore("unused_private_class_variable")
@onready var _work_system := WorkSystem.new()

@onready var _gui := $CanvasLayer/GUI
@onready var _player := $GameWorld/Node2D/Player
@onready var _ground := $GameWorld/Ground


func _ready() -> void:
	$Timer.start(simulation_speed)
	_entity_placer.setup(_tracker, $GameWorld/FlatEntities, _gui, _ground, _player)

	var barriers: Array = _ground.get_used_cells_by_id(BARRIER_ID)
	for cellv in barriers:
		_ground.set_cell(cellv, INVISIBLE_BARRIER_ID, INVISIBLE_BARRIER_POSITION_IN_ATLAS)


func _on_Timer_timeout() -> void:
	Events.emit_signal("systems_ticked", simulation_speed)
