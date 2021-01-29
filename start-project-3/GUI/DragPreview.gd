## A control that follows the mouse at all times to control the position of the
## blueprint sprite.
extends Control

## The blueprint object held by the drag preview. When it changes, we call the setter.
var blueprint: BlueprintEntity setget _set_blueprint

## Reference to the label to keep the numer of items displayed
onready var count_label := $Label


func _ready() -> void:
	set_as_toplevel(true)
	
	var panel_size: float = ProjectSettings.get_setting("game_gui/inventory_size")
	rect_min_size = Vector2(panel_size, panel_size)
	rect_size = rect_min_size
	count_label.rect_min_size = rect_min_size
	count_label.rect_size = rect_min_size


## Events in `_input()` happen regardless of the state of the GUI and they happen first
## so it's ideal for global events like matching the mouse position on the screen.
func _input(event: InputEvent) -> void:
	# If the mouse moved
	if event is InputEventMouseMotion:
		if blueprint:
			blueprint.display_as_inventory_icon()
		# Set the control's global position to the mouse's position on the screen
		rect_global_position = event.global_position


## A helper function to keep the label up to the date to the stack count. We can
## call this whenever the amount changes.
func update_label() -> void:
	# If we have a blueprint and there is more than 1 item in the stack
	if blueprint and blueprint.stack_size > 1:
		# Set the text to the amount and show the label
		count_label.text = str(blueprint.stack_count)
		count_label.show()
	else:
		# Otherwise hide the label. Just keeps things clean.
		count_label.hide()


## Special helper function that not only removes the child from the scene tree,
## but frees it from memory, too.
func destroy_blueprint() -> void:
	if blueprint:
		remove_child(blueprint)
		blueprint.queue_free()
		blueprint = null
		update_label()


## Setter for the blueprint entity. Whenever it changes we make sure it's the one
## in the scene tree so it's displayed on screen.
func _set_blueprint(value: BlueprintEntity) -> void:
	# If we already are holding a blueprint and its parent is this control...
	if blueprint and blueprint.get_parent() == self:
		# ...remove it from the scene tree. The panel will take care of cleaning it
		# up if it needs it.
		remove_child(blueprint)

	# Set the new blueprint
	blueprint = value

	# If it's not null, add it as a child of this control so it is displayed.
	if blueprint:
		add_child(blueprint)
		move_child(blueprint, 0)

	# Make sure its label is up to date with its stack size.
	update_label()
