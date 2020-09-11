# Class to hold and setup bars that are part of the inventory window.
extends Control


onready var inventories := $MarginContainer/WindowBack/Window/Inventories
var held_item: BlueprintEntity setget _set_held_item, _get_held_item
var drag_preview: Control


func setup(_drag_preview: Control) -> void:
	drag_preview = _drag_preview
	for bar in inventories.get_children():
		bar.setup(drag_preview)


func claim_quickbar(quickbar: Control) -> void:
	quickbar.get_parent().remove_child(quickbar)
	inventories.add_child(quickbar)


func destroy_held_item() -> void:
	drag_preview.destroy_blueprint()


func update_label() -> void:
	if drag_preview:
		drag_preview.update_label()


func clear_held_item() -> void:
	if drag_preview:
		drag_preview.clear_blueprint()


func _set_held_item(value: BlueprintEntity) -> void:
	drag_preview.blueprint = value


func _get_held_item() -> BlueprintEntity:
	if drag_preview:
		return drag_preview.blueprint
	else:
		return null
