class_name PipeEntity
extends Entity


enum TravelDirections {
	DI,
	DR,
	DU,
	LD,
	LI,
	LR,
	LU,
	RI,
	UI,
	UR,
	ID, # 10: backwards
	RD,
	UD,
	DL,
	IL,
	RL,
	UL,
	IR,
	IU,
	RU
}

const DIRECTIONS_DATA := {
	1: Rect2(120, 10, 100, 100),
	4: Rect2(120, 10, 100, 100),
	5: Rect2(120, 10, 100, 100),
	2: Rect2(230, 10, 100, 100),
	8: Rect2(230, 10, 100, 100),
	10:Rect2(230, 10, 100, 100),
	15:Rect2(340, 10, 100, 100),
	6: Rect2(450, 10, 100, 100),
	12: Rect2(560, 10, 100, 100),
	3: Rect2(670, 10, 100, 100),
	9: Rect2(780, 10, 100, 100),
	7: Rect2(890, 10, 100, 100),
	14: Rect2(10, 120, 100, 100),
	13: Rect2(120, 120, 100, 100),
	11: Rect2(230, 120, 100, 100)
}

const BACK_REGION_Y_OFFSET := 220.0


var item: BlueprintEntity setget _set_item

onready var animation := $AnimationPlayer
onready var item_sprite := $Sprites/Item
onready var insert_back := $Sprites/InsertBack
onready var insert_front := $Sprites/InsertFront
onready var pipe_back := $Sprites/PipeBack
onready var pipe_front := $Sprites/PipeFront


func play_item_travel(direction: int) -> void:
	if direction > TravelDirections.UR:
		animation.play_backwards(TravelDirections.keys()[direction-10])
	else:
		animation.play(TravelDirections.keys()[direction])


func add_insert() -> void:
	insert_back.show()
	insert_front.show()


func remove_insert() -> void:
	insert_back.hide()
	insert_front.hide()


func set_sprite_for_direction(directions: int) -> void:
	pipe_front.region_rect = get_region_for_direction(directions)
	pipe_back.region_rect = get_region_for_direction(directions)
	pipe_back.region_rect.y += BACK_REGION_Y_OFFSET


static func get_region_for_direction(directions: int) -> Rect2:
	if not DIRECTIONS_DATA.has(directions):
		directions = 10

	return DIRECTIONS_DATA[directions].region


func _set_item(value: BlueprintEntity) -> void:
	item = value
	item_sprite.texture = value.sprite.texture if value.sprite else null
	if not item_sprite.texture:
		return
	item_sprite.region_rect = value.sprite.region_rect
	item_sprite.region_enabled = value.sprite.region_enabled
