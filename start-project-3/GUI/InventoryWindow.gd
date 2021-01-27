extends MarginContainer


## Signal to notify the GUI system that the inventory has changed.
signal inventory_changed(panel, held_item)

## The main GUI node so we can use it to transmit messages and function calls.
var gui: Control

## Get the control that holds the inventory bars. We get this node because we can
## assign the quickbar to it later.
onready var inventory_path := $PanelContainer/MarginContainer/Inventories

## Get each of the inventory bars in an array so we can iterate over them.
onready var inventories := inventory_path.get_children()


## Forwards the setup call to the inventory bars, so they can setup their panels.
func setup(_gui: Control) -> void:
	gui = _gui
	for bar in inventories:
		bar.setup(gui)


## Removes the provided quickbar from its current parent and makes it a sibling
## of the other inventory bars.
func claim_quickbar(quickbar: Control) -> void:
	quickbar.get_parent().remove_child(quickbar)
	inventory_path.add_child(quickbar)


## Adds the provided item to the first available spaces it can find in the
## inventory bars. Returns true if it succeeds.
func add_to_first_available_inventory(item: BlueprintEntity) -> bool:
	for inventory in inventories:
		if inventory.add_to_first_available_inventory(item):
			return true

	return false


## Returns an array of inventory panels that has a held item with a name matching
## the item id from the inventory bars.
func find_panels_with(item_id: String) -> Array:
	var output := []
	for inventory in inventories:
		output += inventory.find_panels_with(item_id)

	return output


## Bubble up the inventory changed signal from the inventory bars.
func _on_InventoryBar_inventory_changed(panel, held_item) -> void:
	emit_signal("inventory_changed", panel, held_item)
