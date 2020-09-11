extends Control


signal quickbar_changed


var held_item: BlueprintEntity setget _set_held_item, _get_held_item
var drag_preview: Control

onready var quickbar := $MarginContainer/WindowBack/Window/Inventories/Quickbar


func setup(_drag_preview: Control) -> void:
	drag_preview = _drag_preview
	quickbar.setup(drag_preview)
	$MarginContainer/WindowBack/Window/Inventories/Inventory1.setup(drag_preview)
	$MarginContainer/WindowBack/Window/Inventories/Inventory2.setup(drag_preview)
	$MarginContainer/WindowBack/Window/Inventories/Inventory3.setup(drag_preview)


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


func _on_Quickbar_quickbar_changed() -> void:
	emit_signal("quickbar_changed")
