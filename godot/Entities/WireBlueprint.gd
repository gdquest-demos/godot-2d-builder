class_name WireBlueprint
extends Node2D


enum Directions { N = 1, E = 2, S = 4, W = 8 }


const _directions_data := {
	10: {"tile": 4, "region": Rect2(450, 10, 100, 100)},
	5: {"tile": 5, "region": Rect2(560, 10, 100, 100)},
	15: {"tile": 6, "region": Rect2(670, 10, 100, 100)},
	12: {"tile": 7, "region": Rect2(780, 10, 100, 100)},
	9: {"tile": 8, "region": Rect2(890, 10, 100, 100)},
	6: {"tile": 9, "region": Rect2(10, 120, 100, 100)},
	3: {"tile": 10, "region": Rect2(120, 120, 100, 100)},
	14: {"tile": 11, "region": Rect2(230, 120, 100, 100)},
	13: {"tile": 12, "region": Rect2(340, 120, 100, 100)},
	11: {"tile": 13, "region": Rect2(450, 120, 100, 100)},
	7: {"tile": 14, "region": Rect2(560, 120, 100, 100)}
}

onready var sprite := $Sprite


func set_sprite_for_direction(directions: int) -> void:
	if not _directions_data.has(directions):
		if directions == 1 or directions == 4:
			directions = 5
		elif directions == 2 or directions == 8:
			directions = 10
		else:
			directions = 10
	var direction: Dictionary = _directions_data[directions]
	sprite.region_rect = direction.region


static func get_direction_tile_id(directions: int) -> int:
	if not _directions_data.has(directions):
		if directions == 1 or directions == 4:
			directions = 5
		elif directions == 2 or directions == 8:
			directions = 10
		else:
			directions = 10
	return _directions_data[directions].tile
