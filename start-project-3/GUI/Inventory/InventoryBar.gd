class_name InventoryBar
extends HBoxContainer

## Signal to notify the inventory system that one of the panels changed its item.
## This is bubbled up from the panel itself.
signal inventory_changed(panel, held_item)

## A scene resource for the inventory panel that holds items.
export var InventoryPanelScene: PackedScene
## How many panels to create as children of the bar.
export var slot_count := 10

## An array of references to the panels we create so we can refer to them and
## check their contents later.
var panels := []


func _ready() -> void:
	# Create the bar's panels first thing.
	_make_panels()


## Sets up each of the inventory panels and connects to their signal for
## inventory changing
func setup(gui: Control) -> void:
	# For each panel we've created in `_ready()`, give them the gui and connect.
	for panel in panels:
		panel.setup(gui)
		panel.connect("held_item_changed", self, "_on_Panel_held_item_changed")


## Returns an array of inventory panels that have a held item that have a name that
## matches the item id provided.
func find_panels_with(item_id: String) -> Array:
	var output := []
	for panel in panels:
		# Check if there is an item and its name matches
		if panel.held_item and Library.get_entity_name_from(panel.held_item) == item_id:
			output.push_back(panel)

	return output


## Tries to add the provided item to the first available empty space. Returns
## true if it succeeds.
func add_to_first_available_inventory(item: BlueprintEntity) -> bool:
	var item_name := Library.get_entity_name_from(item)

	for panel in panels:
		# If the panel already has an item and its name matches that of the item
		# we are trying to put in it, _and_ there is space for it, merge the
		# stacks.
		if (
			panel.held_item
			and Library.get_entity_name_from(panel.held_item) == item_name
			and panel.held_item.stack_count < panel.held_item.stack_size
		):
			# Calculate the available space
			var available_space: int = panel.held_item.stack_size - panel.held_item.stack_count
			
			if item.stack_count > available_space:
				# If there is not enough space, reduce the item count by however
				# many we can fit onto it, then move on to the next panel.
				var transfer_count := item.stack_count - available_space
				panel.held_item.stack_count += transfer_count
				item.stack_count -= transfer_count
			else:
				# If there is enough space, increment the stack, destroy the item and 
				# report success.
				panel.held_item.stack_count += item.stack_count
				item.queue_free()
				return true

		# If the item is empty, then automatically put the item in it and report success.
		elif not panel.held_item:
			panel.held_item = item
			return true

	# There is no more available space in this inventory bar or it cannot pick up
	# the item. Report as much.
	return false


## Creates a number of inventory panel instances as a child of this horizontal bar.
## Adds them to the `panels` object variable.
func _make_panels() -> void:
	# For each slot
	for _i in slot_count:
		# Instance a panel, add it as a child, and add it to the `panels` array.
		var panel := InventoryPanelScene.instance()
		add_child(panel)
		panels.append(panel)


## Bubbles up the signal from the inventory bar up to the inventory window
func _on_Panel_held_item_changed(panel: Control, held_item: BlueprintEntity) -> void:
	emit_signal("inventory_changed", panel, held_item)
