# Class that represents a bar of inventory slots. Transmits blueprint events up
# to the preview controller.
class_name InventoryBar
extends HBoxContainer


var panels := []


func _ready() -> void:
	_find_panels()


func setup(gui: Control) -> void:
	for panel in panels:
		panel.setup(gui)


func _find_panels() -> void:
	for container in get_children():
		if container is InventoryPanel:
			panels.push_back(container)
