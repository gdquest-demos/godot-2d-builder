# Class to hold and setup bars that are part of the inventory window.
extends Control


var gui: Control

onready var inventories := $MarginContainer/WindowBack/Window/Inventories


func setup(_gui: Control) -> void:
	gui = _gui
	for bar in inventories.get_children():
		bar.setup(gui)


func claim_quickbar(quickbar: Control) -> void:
	quickbar.get_parent().remove_child(quickbar)
	inventories.add_child(quickbar)


func update_label() -> void:
	if gui:
		gui.update_label()


func clear_held_item() -> void:
	if gui:
		gui.clear_blueprint()


func _set_held_item(value: BlueprintEntity) -> void:
	gui.blueprint = value


func _get_held_item() -> BlueprintEntity:
	if gui:
		return gui.blueprint
	else:
		return null
