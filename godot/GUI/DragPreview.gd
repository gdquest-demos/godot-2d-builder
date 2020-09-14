# A control that follows the mouse at all times to control the position of the
# blueprint sprite.
extends Control


var blueprint: BlueprintEntity setget _set_blueprint

onready var count_label := $Label


func _ready() -> void:
	set_as_toplevel(true)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if blueprint:
			blueprint.make_inventory()
		rect_global_position = event.global_position


func update_label() -> void:
	if blueprint and blueprint.stack_size > 1:
		count_label.text = str(blueprint.stack_count)
		count_label.show()
	else:
		count_label.hide()


func _set_blueprint(value: BlueprintEntity) -> void:
	if blueprint:
		remove_child(blueprint)
	blueprint = value
	if blueprint:
		add_child(blueprint)
	update_label()


func destroy_blueprint() -> void:
	if blueprint:
		remove_child(blueprint)
		blueprint.queue_free()
		blueprint = null
		update_label()