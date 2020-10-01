# The containers that hold the entity's GUI so that it can be grabbed and added
# to the inventory window with a centred layout.
extends CenterContainer

var gui_window: Control setget _set_window

onready var gui_container := $PanelContainer/MarginContainer


func setup(_gui: Control) -> void:
	gui_container.get_child(0)._setup(_gui)


func _set_window(value: Control) -> void:
	gui_window = value
	if not is_inside_tree():
		yield(self, "ready")
	gui_container.add_child(gui_window)
