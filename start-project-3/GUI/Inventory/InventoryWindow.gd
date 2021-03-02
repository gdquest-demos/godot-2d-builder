extends MarginContainer


signal inventory_changed(panel, held_item)

var gui: Control

onready var inventory_path := $PanelContainer/MarginContainer/Inventories

onready var inventories := inventory_path.get_children()


func setup(_gui: Control) -> void:
	gui = _gui
	for bar in inventories:
		bar.setup(gui)


func claim_quickbar(quickbar: Control) -> void:
	quickbar.get_parent().remove_child(quickbar)
	inventory_path.add_child(quickbar)


func add_to_first_available_inventory(item: BlueprintEntity) -> bool:
	for inventory in inventories:
		if inventory.add_to_first_available_inventory(item):
			return true

	return false


func find_panels_with(item_id: String) -> Array:
	var output := []
	for inventory in inventories:
		output += inventory.find_panels_with(item_id)

	return output


func _on_InventoryBar_inventory_changed(panel, held_item) -> void:
	emit_signal("inventory_changed", panel, held_item)
