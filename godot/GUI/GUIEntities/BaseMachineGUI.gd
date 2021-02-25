# Base class from which all entity GUIs are derived from. It emits signals on
# open/close and defines a signal that the GUI can emit when something changes.
class_name BaseMachineGUI
extends MarginContainer

# When something about the GUI changes, such as an item being put into an inventory slot.
#warning-ignore: unused_signal
signal gui_status_changed

# When the GUI window is opened or closed.
#warning-ignore: unused_signal
signal gui_opened
#warning-ignore: unused_signal
signal gui_closed


func _enter_tree() -> void:
	call_deferred("emit_signal", "gui_opened")


func _exit_tree() -> void:
	call_deferred("emit_signal", "gui_closed")


func setup(_gui: Control) -> void:
	pass
