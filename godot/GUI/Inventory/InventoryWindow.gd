# Class to hold and setup bars that are part of the inventory window.
extends Control

signal inventory_changed(panel, held_item)

var gui: Control

onready var inventory_path := $WindowBack/Window/Inventories
onready var inventories := inventory_path.get_children()


func setup(_gui: Control) -> void:
	gui = _gui
	for bar in inventories:
		bar.setup(gui)


func claim_quickbar(quickbar: Control) -> void:
	quickbar.get_parent().remove_child(quickbar)
	inventory_path.add_child(quickbar)


func update_label() -> void:
	if gui:
		gui.update_label()


func clear_held_item() -> void:
	if gui:
		gui.clear_blueprint()


func find_panels_with(item_id: String) -> Array:
	var output := []
	for inventory in inventories:
		if not inventory is Quickbar:
			output += inventory.find_panels_with(item_id)

	return output


func add_to_first_available_inventory(item: BlueprintEntity) -> bool:
	for inventory in inventories:
		if inventory.add_to_first_available_inventory(item):
			return true

	return false


func _set_held_item(value: BlueprintEntity) -> void:
	gui.blueprint = value


func _get_held_item() -> BlueprintEntity:
	if gui:
		return gui.blueprint
	else:
		return null


func _on_Inventory_inventory_changed(panel, held_item) -> void:
	emit_signal("inventory_changed", panel, held_item)
