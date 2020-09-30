class_name BaseMachineGUI
extends MarginContainer

#warning-ignore: unused_signal
signal gui_status_changed
#warning-ignore: unused_signal
signal gui_opened


func _enter_tree() -> void:
	call_deferred("emit_signal", "gui_opened")


func _setup(_gui: Control) -> void:
	pass
