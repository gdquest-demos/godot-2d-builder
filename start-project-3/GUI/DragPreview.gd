extends Control

var blueprint: BlueprintEntity setget _set_blueprint

onready var count_label := $Label


func _ready() -> void:
	set_as_toplevel(true)
	
	var panel_size: float = ProjectSettings.get_setting("game_gui/inventory_size")
	rect_min_size = Vector2(panel_size, panel_size)
	rect_size = rect_min_size
	count_label.rect_min_size = rect_min_size
	count_label.rect_size = rect_min_size


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if blueprint:
			blueprint.display_as_inventory_icon()
		rect_global_position = event.global_position


func update_label() -> void:
	if blueprint and blueprint.stack_count > 1:
		count_label.text = str(blueprint.stack_count)
		count_label.show()
	else:
		count_label.hide()


func destroy_blueprint() -> void:
	if blueprint:
		remove_child(blueprint)
		blueprint.queue_free()
		blueprint = null
		update_label()


func _set_blueprint(value: BlueprintEntity) -> void:
	if blueprint and blueprint.get_parent() == self:
		remove_child(blueprint)

	blueprint = value

	if blueprint:
		add_child(blueprint)
		move_child(blueprint, 0)

	update_label()
