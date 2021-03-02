extends Node2D

const REGIONS := [
	[Rect2(899, 134, 31, 17), Rect2(950, 179, 31, 17)],
	[Rect2(950, 134, 31, 17), Rect2(899, 179, 31, 17)]
]

export (Types.Direction, FLAGS) var output_directions: int = 15 setget _set_output_directions

onready var west := $W
onready var north := $N
onready var east := $E
onready var south := $S


func set_indicators() -> void:
	if output_directions & Types.Direction.LEFT != 0:
		west.region_rect = REGIONS[0][0]
	else:
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


func _set_output_directions(value: int) -> void:
	output_directions = value

	if not is_inside_tree():
		yield(self, "ready")

	set_indicators()
