class_name BlueprintEntity
extends Node2D

export var placeable := true

onready var _power_indicator := find_node("PowerDirection")


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
