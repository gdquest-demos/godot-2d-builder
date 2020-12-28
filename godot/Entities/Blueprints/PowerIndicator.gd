extends Node2D

const REGIONS := {
	"UpLeft": Rect2(899, 134, 31, 17),
	"DownRight": Rect2(950, 179, 31, 17),
	"UpRight": Rect2(950, 134, 31, 17),
	"DownLeft": Rect2(899, 179, 31, 17)
}

export (Types.Direction, FLAGS) var output_directions: int = 15 setget _set_output_directions

onready var west := $W
onready var north := $N
onready var east := $E
onready var south := $S


func set_indicators() -> void:
	# If LEFT's bits are in `output_directions`
	if output_directions & Types.Direction.LEFT != 0:
		# ...set the west arrow to point out
		west.region_rect = REGIONS.UpLeft
	else:
		# ...otherwise, set it to point in by using the bottom right arrow graphic
		west.region_rect = REGIONS.DownRight

	# Repeat for all four arrows individually
	if output_directions & Types.Direction.RIGHT != 0:
		east.region_rect = REGIONS.DownRight
	else:
		east.region_rect = REGIONS.UpLeft

	if output_directions & Types.Direction.UP != 0:
		north.region_rect = REGIONS.UpRight
	else:
		north.region_rect = REGIONS.DownLeft

	if output_directions & Types.Direction.DOWN != 0:
		south.region_rect = REGIONS.DownLeft
	else:
		south.region_rect = REGIONS.UpRight


func _set_output_directions(value: int) -> void:
	output_directions = value
	if not is_inside_tree():
		yield(self, "ready")
	set_indicators()
