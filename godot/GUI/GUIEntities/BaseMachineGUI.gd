class_name BaseMachineGUI
extends MarginContainer

#warning-ignore: unused_signal
signal gui_status_changed
#warning-ignore: unused_signal
signal gui_opened
#warning-ignore: unused_signal
signal gui_closed


func _enter_tree() -> void:
	call_deferred("emit_signal", "gui_opened")


func _exit_tree() -> void:
	call_deferred("emit_signal", "gui_closed")


func _setup(_gui: Control) -> void:
	pass
