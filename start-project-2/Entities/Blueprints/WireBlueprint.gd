## Specialized blueprint. Holds and set tile/region information, as wires must
## connect to neighbors.
class_name WireBlueprint
extends BlueprintEntity

## Constant dictionary that holds the sprite region information for the wire's spritesheet.
const DIRECTIONS_DATA := {
	1: Rect2(120, 10, 100, 100),
	4: Rect2(120, 10, 100, 100),
	5: Rect2(120, 10, 100, 100),
	2: Rect2(230, 10, 100, 100),
	8: Rect2(230, 10, 100, 100),
	10: Rect2(230, 10, 100, 100),
	15: Rect2(340, 10, 100, 100),
	6: Rect2(450, 10, 100, 100),
	12: Rect2(560, 10, 100, 100),
	3: Rect2(670, 10, 100, 100),
	9: Rect2(780, 10, 100, 100),
	7: Rect2(890, 10, 100, 100),
	14: Rect2(10, 120, 100, 100),
	13: Rect2(120, 120, 100, 100),
	11: Rect2(230, 120, 100, 100)
}

onready var sprite := $Sprite


## Helper function to set the sprite based on the provided direction.
static func set_sprite_for_direction(sprite: Sprite, directions: int) -> void:
	sprite.region_rect = get_region_for_direction(directions)


## Static function to get the correct Rect2 from the constant dictionary.
static func get_region_for_direction(directions: int) -> Rect2:
	# If the direction is invalid, default to 10, which is UP + DOWN.
	if not DIRECTIONS_DATA.has(directions):
		directions = 10

	return DIRECTIONS_DATA[directions]
