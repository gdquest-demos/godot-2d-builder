class_name Pipe
extends Entity


enum Direction { BOTTOM_TOP, TOP_BOTTOM, LEFT_RIGHT_FRONT, RIGHT_LEFT_FRONT, LEFT_RIGHT_BACK, RIGHT_LEFT_BACK }

const SCALE_DURATION := 0.25
const MOVE_DURATION := 2.0
const NORMAL_SCALE := Vector2(0.25, 0.25)

const REGIONS := {
	horizontal_front = {
		back_position = Vector2.ZERO,
		back_region = Rect2(795, 797, 70, 56),
		front_region = Rect2(905, 797, 70, 56),
		start_scale = Vector2(0, 0.25),
		position_1 = Vector2(-25, -12.5),
		position_2 = Vector2(25, 12.5)
	},
	horizontal_back = {
		back_position = Vector2.ZERO,
		back_region = Rect2(795, 907, 70, 56),
		front_region = Rect2(905, 907, 70, 56),
		start_scale = Vector2(0, 0.25),
		position_1 = Vector2(-25, 12.5),
		position_2 = Vector2(25, -12.5)
	},
	vertical = {
		back_position = Vector2(0, -4),
		back_region = Rect2(725, 799, 38, 50),
		front_region = Rect2(675, 799, 38, 59),
		start_scale = Vector2(0.25, 0),
		position_1 = Vector2(0, 20),
		position_2 = Vector2(0, -20)
	}
}


onready var tween := $Tween
onready var item := $Item
onready var back_pipe := $Back
onready var front_pipe := $Front


func _ready() -> void:
	yield(get_tree().create_timer(0.5), "timeout")
	for i in 6:
		configure_pipe(i)
		play_item_transfer(i, Library.blueprints["Axe"].instance())
		yield(tween, "tween_all_completed")


func configure_pipe(direction: int) -> void:
	if direction == Direction.BOTTOM_TOP or direction == Direction.TOP_BOTTOM:
		back_pipe.position = REGIONS.vertical.back_position
		back_pipe.region_rect = REGIONS.vertical.back_region
		front_pipe.region_rect = REGIONS.vertical.front_region

	elif direction == Direction.LEFT_RIGHT_FRONT or direction == Direction.RIGHT_LEFT_FRONT:
		back_pipe.position = REGIONS.horizontal_front.back_position
		back_pipe.region_rect = REGIONS.horizontal_front.back_region
		front_pipe.region_rect = REGIONS.horizontal_front.front_region

	elif direction == Direction.LEFT_RIGHT_BACK or direction == Direction.RIGHT_LEFT_BACK:
		back_pipe.position = REGIONS.horizontal_back.back_position
		back_pipe.region_rect = REGIONS.horizontal_back.back_region
		front_pipe.region_rect = REGIONS.horizontal_back.front_region


func play_item_transfer(direction: int, blueprint: BlueprintEntity) -> void:
	var start_position: Vector2
	var end_position: Vector2
	var start_scale: Vector2
	var end_scale := NORMAL_SCALE
	
	item.region_rect = blueprint.get_node("Sprite").region_rect

	match direction:
		Direction.BOTTOM_TOP:
			start_scale = REGIONS.vertical.start_scale
			start_position = REGIONS.vertical.position_1
			end_position = REGIONS.vertical.position_2

		Direction.TOP_BOTTOM:
			start_scale = REGIONS.vertical.start_scale
			start_position = REGIONS.vertical.position_2
			end_position = REGIONS.vertical.position_1
			
		Direction.LEFT_RIGHT_FRONT:
			start_scale = REGIONS.horizontal_front.start_scale
			start_position = REGIONS.horizontal_front.position_1
			end_position = REGIONS.horizontal_front.position_2

		Direction.RIGHT_LEFT_FRONT:
			start_scale = REGIONS.horizontal_front.start_scale
			start_position = REGIONS.horizontal_front.position_2
			end_position = REGIONS.horizontal_front.position_1

		Direction.LEFT_RIGHT_BACK:
			start_scale = REGIONS.horizontal_back.start_scale
			start_position = REGIONS.horizontal_back.position_1
			end_position = REGIONS.horizontal_back.position_2

		Direction.RIGHT_LEFT_BACK:
			start_scale = REGIONS.horizontal_back.start_scale
			start_position = REGIONS.horizontal_back.position_2
			end_position = REGIONS.horizontal_back.position_1

	tween.interpolate_property(item, "scale", start_scale, end_scale, SCALE_DURATION)
	tween.interpolate_property(item, "position", start_position, end_position, MOVE_DURATION)
	tween.interpolate_property(item, "scale", end_scale, start_scale, SCALE_DURATION, 0, 2, MOVE_DURATION - SCALE_DURATION)
	tween.start()
