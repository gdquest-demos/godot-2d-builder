class_name WireBlueprint
extends Node2D


enum Directions { N = 1, E = 2, S = 4, W = 8 }


const _directions_data := {
	10: {"tile": 4, "region": Rect2(474, 9, 57, 40)},
	5: {"tile": 5, "region": Rect2(579, 9, 57, 40)},
	15: {"tile": 6, "region": Rect2(691, 9, 58, 40)},
	12: {"tile": 7, "region": Rect2(804, 9, 35, 40)},
	9: {"tile": 8, "region": Rect2(914, 9, 57, 29)},
	6: {"tile": 9, "region": Rect2(34, 129, 57, 29)},
	3: {"tile": 10, "region": Rect2(164, 119, 35, 40)},
	14: {"tile": 11, "region": Rect2(251, 119, 57, 40)},
	13: {"tile": 12, "region": Rect2(361, 119, 58, 40)},
	11: {"tile": 13, "region": Rect2(471, 119, 58, 40)},
	7: {"tile": 14, "region": Rect2(582, 119, 57, 40)}
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
