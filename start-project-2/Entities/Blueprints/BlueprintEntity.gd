class_name BlueprintEntity
extends Node2D

export var placeable := true

## We use find node to search for a PowerDirection scene. If it does not exist,
## then we don't worry about it - find_node returns null if it finds nothing.
onready var _power_indicator := find_node("PowerDirection")


## Rotate the blueprint's direction, if it has one and it is relevant
func rotate_blueprint() -> void:
	# Don't do anything if there is nothing to rotate
	if _power_indicator:
		# Get the current directions flags
		var directions: int = _power_indicator.output_directions

		# Begin the new one at 0
		var new_directions := 0

		# Check if LEFT is inside the current directions.
		if directions & Types.Direction.LEFT != 0:
			# Turn it into UP
			new_directions |= Types.Direction.UP

		# UP becomes RIGHT
		if directions & Types.Direction.UP != 0:
			new_directions |= Types.Direction.RIGHT

		# RIGHT becomes DOWN
		if directions & Types.Direction.RIGHT != 0:
			new_directions |= Types.Direction.DOWN

		# DOWN becomes LEFT
		if directions & Types.Direction.DOWN != 0:
			new_directions |= Types.Direction.LEFT

		# Set the new direction, which should set the arrow sprites
		_power_indicator.output_directions = new_directions
