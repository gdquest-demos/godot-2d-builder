class_name GUIComponent
extends Node


@warning_ignore("unused_signal")
signal gui_status_changed
@warning_ignore("unused_signal")
signal gui_opened
@warning_ignore("unused_signal")
signal gui_closed

var gui: Control
@export var GuiWindow: PackedScene


func _ready() -> void:
	assert(GuiWindow, "You must specify the GUIWindow property for a GUI Component")
	gui = GuiWindow.instantiate()
	Log.log_error(gui.gui_status_changed.connect(emit_signal.bind("gui_status_changed")), "GUI Component")
	Log.log_error(gui.gui_opened.connect(emit_signal.bind("gui_opened")), "GUI Component")
	Log.log_error(gui.gui_closed.connect(emit_signal.bind("gui_closed")), "GUI Component")


func get_inventory_bars() -> Array:
	var output := []
	var parent_stack := [gui]

	while not parent_stack.is_empty():
		var current: Node = parent_stack.pop_back()

		if current is InventoryBar:
			output.push_back(current)

		parent_stack += current.get_children()

	return output


func _exit_tree() -> void:
	if gui:
		gui.queue_free()
