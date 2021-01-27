class_name BlueprintEntity
extends Node2D


## How many items can be in a stack of the given blueprint type.
export var stack_size := 1
export var placeable := true

## How many items are actually in the stack of the current stack.
var stack_count := 1

## We use find node to search for a PowerDirection scene. If it does not exist,
## then we don't worry about it - find_node returns null if it finds nothing.
onready var _power_indicator := find_node("PowerDirection")


## Sets the position and scale of the node to fit the inventory panels, and hides
## extras like the power direction indicators.
func display_as_inventory_icon() -> void:
	# Get the panel size from project settings as a float
	var panel_size: float = ProjectSettings.get_setting("game_gui/inventory_size")
	
	# Set the position. Horizontally, it's half way across. Vertically, 
	# we move the graphics and collision so that the machine's origin is on the
	# floor of the tile. With our isometric graphic style, it's 75% of the height.
	position = Vector2(panel_size * 0.5, panel_size * 0.75)
	
	# The sprites for blueprints are 100x100, so the scale is the desired size
	# divided by 100.
	scale = Vector2(panel_size / 100.0, panel_size / 100.0)
	
	modulate = Color.white

	# Hide the power indicator, if we have one. We don't need it in the inventory.
	if _power_indicator:
		_power_indicator.hide()


## Sets the scale and position so sprites are at full size and matches the world scale.
## Also shows extras like the power direction indicators.
func display_as_world_entity() -> void:
	scale = Vector2.ONE
	position = Vector2.ZERO
	if _power_indicator:
		_power_indicator.show()


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
