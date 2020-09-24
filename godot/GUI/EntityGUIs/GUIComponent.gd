class_name GUIComponent
extends Node

#warning-ignore: unused_signal
signal gui_status_changed

const BaseWindow := preload("MachineGUI.tscn")

var gui: Control
var window: Control
export var GuiWindow: PackedScene


func _ready() -> void:
	assert(GuiWindow, "You must specify the GUIWindow property for a GUI Component")
	var base := BaseWindow.instance()
	window = GuiWindow.instance()

	var _error := window.connect("gui_status_changed", self, "emit_signal", ["gui_status_changed"])

	base.set_window(window)
	gui = base


func _exit_tree() -> void:
	if gui:
		gui.queue_free()
