class_name BlueprintEntity
extends Node2D


export var stack_size := 1
export var placeable := true

var stack_count := 1

onready var power_direction := find_node("PowerDirection")


func display_as_inventory_icon() -> void:
	var panel_size: float = ProjectSettings.get_setting("game_gui/inventory_size")
	
	position = Vector2(panel_size * 0.5, panel_size * 0.75)
	
	scale = Vector2(panel_size / 100.0, panel_size / 100.0)
	
	modulate = Color.white

	if power_direction:
		power_direction.hide()


func display_as_world_entity() -> void:
	scale = Vector2.ONE
	position = Vector2.ZERO
	if power_direction:
		power_direction.show()


func rotate_blueprint() -> void:
	if power_direction:
		var directions: int = power_direction.output_directions

		var new_directions := 0

		if directions & Types.Direction.LEFT != 0:
			new_directions |= Types.Direction.UP

		if directions & Types.Direction.UP != 0:
			new_directions |= Types.Direction.RIGHT

		if directions & Types.Direction.RIGHT != 0:
			new_directions |= Types.Direction.DOWN

		if directions & Types.Direction.DOWN != 0:
			new_directions |= Types.Direction.LEFT

		power_direction.output_directions = new_directions
