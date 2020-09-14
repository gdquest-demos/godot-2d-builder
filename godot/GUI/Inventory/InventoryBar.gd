# Class that represents a bar of inventory slots. Transmits blueprint events up
# to the preview controller.
extends HBoxContainer


export var quickbar := false


var panels := []
var gui: Control


func _ready() -> void:
	for container in get_children():
		if container is InventoryPanel:
			panels.push_back(container)
		else:
			panels.push_back(container.get_child(1))


func setup(_gui: Control) -> void:
	gui = _gui
	for child in get_children():
		if quickbar:
			child.get_child(1).setup(gui)
		else:
			child.setup(gui)
