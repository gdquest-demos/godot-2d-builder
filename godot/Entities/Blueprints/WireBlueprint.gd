class_name WireBlueprint
extends BlueprintEntity


const _directions_data := {
	1: {"tile": 4, "region": Rect2(450, 10, 100, 100)},
	4: {"tile": 4, "region": Rect2(450, 10, 100, 100)},
	5: {"tile": 4, "region": Rect2(450, 10, 100, 100)},
	
	2: {"tile": 5, "region": Rect2(560, 10, 100, 100)},
	8: {"tile": 5, "region": Rect2(560, 10, 100, 100)},
	10: {"tile": 5, "region": Rect2(560, 10, 100, 100)},
	
	15: {"tile": 6, "region": Rect2(670, 10, 100, 100)},
	6: {"tile": 7, "region": Rect2(780, 10, 100, 100)},
	12: {"tile": 8, "region": Rect2(890, 10, 100, 100)},
	3: {"tile": 9, "region": Rect2(10, 120, 100, 100)},
	9: {"tile": 10, "region": Rect2(120, 120, 100, 100)},
	7: {"tile": 11, "region": Rect2(230, 120, 100, 100)},
	14: {"tile": 12, "region": Rect2(340, 120, 100, 100)},
	13: {"tile": 13, "region": Rect2(450, 120, 100, 100)},
	11: {"tile": 14, "region": Rect2(560, 120, 100, 100)}
}

onready var sprite := $Sprite


func set_sprite_for_direction(directions: int) -> void:
	sprite.region_rect = get_region_for_direction(directions)


static func get_region_for_direction(directions: int) -> Rect2:
	if not _directions_data.has(directions):
		directions = 10

	return _directions_data[directions].region


static func get_direction_tile_id(directions: int) -> int:
	if not _directions_data.has(directions):
		directions = 10

	return _directions_data[directions].tile
