# Base class for all blueprints. Used by the inventory and entity placer systems
# to represent an item or a stack of items.
class_name BlueprintEntity
extends Node2D

export var stack_size := 1
export var placeable := true
export var description := ""

var stack_count := 1

onready var _power_indicator := find_node("PowerDirection")


func make_inventory() -> void:
	position = Vector2(25, 37.5)
	scale = Vector2(0.5, 0.5)
	modulate = Color.white
	if _power_indicator:
		_power_indicator.hide()


func make_world() -> void:
	scale = Vector2.ONE
	position = Vector2.ZERO
	if _power_indicator:
		_power_indicator.show()


func rotate_blueprint() -> void:
	if _power_indicator:
		var directions: int = _power_indicator.output_directions

		var new_directions := 0

		if directions & Types.Direction.LEFT != 0:
			new_directions |= Types.Direction.UP

		if directions & Types.Direction.UP != 0:
			new_directions |= Types.Direction.RIGHT

		if directions & Types.Direction.RIGHT != 0:
			new_directions |= Types.Direction.DOWN

		if directions & Types.Direction.DOWN != 0:
			new_directions |= Types.Direction.LEFT

		_power_indicator.output_directions = new_directions
