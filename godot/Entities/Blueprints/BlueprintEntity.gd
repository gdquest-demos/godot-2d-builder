# Base class for all blueprints. Used by the inventory and entity placer systems
# to represent an item or a stack of items.
class_name BlueprintEntity
extends Node2D

const DEFAULT_SIZE := 100.0

export var stack_size := 1
export var placeable := true
export (String, MULTILINE) var description := ""

var stack_count := 1

onready var _power_direction := find_node("PowerDirection")


func make_inventory() -> void:
	var gui_scale: float = ProjectSettings.get_setting("game_gui/gui_scale")
	position = Vector2(DEFAULT_SIZE * gui_scale * 0.5, DEFAULT_SIZE * gui_scale * 0.75)
	scale = Vector2(gui_scale, gui_scale)
	modulate = Color.white
	if _power_direction:
		_power_direction.hide()


func make_world() -> void:
	scale = Vector2.ONE
	position = Vector2.ZERO
	if _power_direction:
		_power_direction.show()


func rotate_blueprint() -> void:
	if not _power_direction:
		return

	var directions: int = _power_direction.output_directions

	var new_directions := 0

	if directions & Types.Direction.LEFT != 0:
		new_directions |= Types.Direction.UP

	if directions & Types.Direction.UP != 0:
		new_directions |= Types.Direction.RIGHT

	if directions & Types.Direction.RIGHT != 0:
		new_directions |= Types.Direction.DOWN

	if directions & Types.Direction.DOWN != 0:
		new_directions |= Types.Direction.LEFT

	_power_direction.output_directions = new_directions
