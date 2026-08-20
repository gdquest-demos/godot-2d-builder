extends Node

const BARRIER_ID := 1

# Atlas source ID
const INVISIBLE_BARRIER_SOURCE_ID := 2
# Will only change if resized atlas
const INVISIBLE_BARRIER_POSITION_IN_ATLAS := Vector2i(0, 0)

@export var simulation_speed := 1.0 / 30.0

var _tracker := EntityTracker.new()

@onready var _power_system := PowerSystem.new()
@onready var _ground := $GameWorld/GroundTiles
@onready var _entity_placer := $GameWorld/Node2D/EntityPlacer
@onready var _player := $GameWorld/Node2D/Player
@onready var _flat_entities := $GameWorld/FlatEntities


func _ready() -> void:
	$Timer.start(simulation_speed)
	_entity_placer.setup(_tracker, _ground, _flat_entities, _player)
	
	var barriers: Array = _ground.get_used_cells_by_id(BARRIER_ID)
	for cell_coordinates in barriers:
		_ground.set_cell(cell_coordinates, INVISIBLE_BARRIER_SOURCE_ID, INVISIBLE_BARRIER_POSITION_IN_ATLAS)


func _on_Timer_timeout() -> void:
	Events.emit_signal("systems_ticked", simulation_speed)
