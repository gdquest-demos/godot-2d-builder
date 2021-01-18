extends Node2D

## Sprite regions from the sprite sheet, split into two arrays. Top row, left right,
## bottom row, right left, essentially in clock wise order. This is arbitrary, the
## important part is to assign them correctly in the setter.
const REGIONS := [
	[Rect2(899, 134, 31, 17), Rect2(950, 179, 31, 17)],
	[Rect2(950, 134, 31, 17), Rect2(899, 179, 31, 17)]
]

## A flag based enum to set which of the blueprint's directions are for power _output_
## All other directions will be input.
export (Types.Direction, FLAGS) var output_directions: int = 15 setget _set_output_directions

## The sprites to configure in the setter
onready var west := $W
onready var north := $N
onready var east := $E
onready var south := $S


## Compares the output directions to the direction enum and assigns the correct
## arrow, in or out, based on whether it's an arrow at the near or far side
func set_indicators() -> void:
	# If LEFT's bits are contained in output_directions'
	if output_directions & Types.Direction.LEFT != 0:
		# Set the west arrow to point out
		west.region_rect = REGIONS[0][0]
	else:
		# Otherwise, set it to point in by using the bottom right arrow graphic
		# See? Now the madness of the clockwise order makes sense.
		west.region_rect = REGIONS[0][1]

	if output_directions & Types.Direction.RIGHT != 0:
		east.region_rect = REGIONS[0][1]
	else:
		east.region_rect = REGIONS[0][0]

	if output_directions & Types.Direction.UP != 0:
		north.region_rect = REGIONS[1][0]
	else:
		north.region_rect = REGIONS[1][1]

	if output_directions & Types.Direction.DOWN != 0:
		south.region_rect = REGIONS[1][1]
	else:
		south.region_rect = REGIONS[1][0]


## The setter for the blueprint's direction value.
func _set_output_directions(value: int) -> void:
	output_directions = value

	# Wait until the blueprint has appeared in the scene tree at least once.
	if not is_inside_tree():
		yield(self, "ready")

	# Set the sprite graphics according to the direction value.
	set_indicators()
