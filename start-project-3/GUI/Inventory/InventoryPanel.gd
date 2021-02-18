## Represents a slot in which an item can be held. Inventory is kept track of 
## through being a child of the panel.
class_name InventoryPanel
extends Panel


## A signal that is emitted whenever the item on this panel changes. Is bubbled up
## to the GUI so it can make other systems react to inventory changes.
signal held_item_changed(panel, item)

## A reference to the entity currently held by the panel. It can be null if there is
## none.
var held_item: BlueprintEntity setget _set_held_item

## The main GUI node to access the mouse's inventory
var gui: Control

## Reference to the label for stack size
onready var count_label := $Label


func _ready() -> void:
	var panel_size: float = ProjectSettings.get_setting("game_gui/inventory_size")
	# Force the panel's size and min size to match the project setting, and apply
	# the same size to the label.
	rect_min_size = Vector2(panel_size, panel_size)
	rect_size = rect_min_size
	count_label.rect_min_size = rect_min_size
	count_label.rect_size = rect_min_size


## `_gui_input()` occurs after `_input()`, but only fires on events that affect this GUI.
func _gui_input(event: InputEvent) -> void:
	# Create easy to use conditional variables for mouse clicks.
	var left_click := event.is_action_pressed("left_click")
	var right_click := event.is_action_pressed("right_click")

	# If either event happened
	if left_click or right_click:
		# And the mouse is holding an item
		if gui.blueprint:
			# Get its name
			var blueprint_name := Library.get_entity_name_from(gui.blueprint)
			
			# If this panel is holding an item
			if held_item:
				# Get its name
				var held_item_name := Library.get_entity_name_from(held_item)

				var item_is_same_type: bool = held_item_name == blueprint_name
				var stack_has_space: bool = held_item.stack_count < held_item.stack_size

				# If the item types have the same name and there is space
				if item_is_same_type and stack_has_space:
					if left_click:
						# Merge the mouse's entire stack with this one
						_stack_items()
					elif right_click:
						# Merge half of the mouse's stack with this one
						_stack_items(true)

				# If the items are not the same name or there is no space
				else:
					if left_click:
						# Swap the two items, putting the panel's in the mouse and
						# the mouse's in the panel.
						_swap_items()
			# If this panel is empty
			else:
				if left_click:
					# Put the mouse's item in this panel
					_grab_item()

				elif right_click:
					if gui.blueprint.stack_count > 1:
						# Put half of the mouse's stack in this panel
						_grab_split_items()
					else:
						# Put the mouse's item in this panel
						_grab_item()

		# If the mouse is empty but there is an item in the panel
		elif held_item:
			if left_click:
				# Put the panel's item in the mouse's inventory
				_release_item()
			elif right_click:
				if held_item.stack_count == 1:
					# Put the panel's item in the mouse's inventory
					_release_item()
				else:
					# Put half the panel's stack into the mouse's inventory
					_split_items()


## Store a reference to the GUI so we can access the mouse's inventory.
func setup(_gui: Control) -> void:
	gui = _gui


## Sets the panel's currently held item, notifies anyone connected of it, and
## updates the stack counter.
func _set_held_item(value: BlueprintEntity) -> void:
	# If we already have an item, remove it. Holding a reference to the old object
	# is the responsibility of whoever is changing it.
	if held_item and held_item.get_parent() == self:
		remove_child(held_item)

	# Set the new item
	held_item = value

	# If it's not null, add it as a child and make sure that it's _below_ the label.
	if held_item:
		add_child(held_item)
		move_child(held_item, 0)
		held_item.display_as_inventory_icon()

	# Update the stack count label
	_update_label()
	
	# Notify any subscribers that we've changed what item is in this panel.
	emit_signal("held_item_changed", self, held_item)


## Updates the label with the stack's current amount. If it's only 1 or there is
## no item, we hide the label instead.
func _update_label() -> void:
	var can_be_stacked := held_item and held_item.stack_size > 1

	if can_be_stacked:
		count_label.text = str(held_item.stack_count)
		count_label.show()
	else:
		count_label.text = str(1)
		count_label.hide()


## Grab stacked items from the mouse and onto the held item
func _stack_items(split := false) -> void:
	# Get the smaller number between half the mouse's stack or the amount of space left
	# on the current stack. We don't want to go over or grab more than the mouse has
	# so it's the smaller number.
	var count: int = int(
		min(
			gui.blueprint.stack_count / (2 if split else 1),
			held_item.stack_size - held_item.stack_count
		)
	)

	# If we are splitting the mouse's stack, reduce its stack by count and update
	# its label.
	if split:
		gui.blueprint.stack_count -= count
		gui.update_label()
	else:
		# If we are grabbing as much of the stack as possible, reduce it by count
		# if we don't have enough space for all of it
		if count < gui.blueprint.stack_count:
			gui.blueprint.stack_count -= count
			gui.update_label()
		else:
			# Or if it is reduced to zero, destroy it outright and remove it
			# from the mouse.
			gui.destroy_blueprint()

	# Increase the held item's stack count by the calculated amount, and update
	# the label.
	held_item.stack_count += count
	_update_label()


## Takes the current held item's stack and swaps it with the mouse's
func _swap_items() -> void:
	var item: BlueprintEntity = gui.blueprint
	# We set the mouse's blueprint to null here. This calls its setter and ensures
	# that the blueprint's parent is removed, making it available for the panel
	# to add as a child.
	gui.blueprint = null

	# Store the current item temporarily in a variable. We're about to change
	# what `held_item` points to, but we still need the old one to give it to GUI.
	var current_item := held_item
	
	# Set the new item in place of the old. Note the use of `self`. This ensures we
	# call the setter as calling the property directly from the instance does _not_
	# call the setter.
	self.held_item = item
	
	# Set GUI's held item to the old item.
	gui.blueprint = current_item


## Grabs the item from the mouse and puts it into the panel's inventory.
func _grab_item() -> void:
	var item: BlueprintEntity = gui.blueprint
	
	# Make sure the blueprint has been released from the mouse so we can grab it.
	gui.blueprint = null
	self.held_item = item


## Release the item from the panel and put it into the mouse's inventory.
func _release_item() -> void:
	var item := held_item
	
	# Make sure the blueprint has been the released from the panel so the mouse
	# can grab it.
	self.held_item = null
	gui.blueprint = item


## Splits the current panel's inventory's stack and gives half to the mouse.
func _split_items() -> void:
	# Calculate half of the current stack.
	var count := int(held_item.stack_count / 2.0)

	# Create a brand new BlueprintEntity and set its size to what we've calculated.
	var new_stack := held_item.duplicate()
	new_stack.stack_count = count
	# And reduce the current one by that amount.
	held_item.stack_count -= count

	# Give the mouse the new stack
	gui.blueprint = new_stack
	_update_label()


## Splits the mouse's inventory stack and takes half of it into the panel inventory.
func _grab_split_items() -> void:
	# Calculate what half of the mouse's stack is
	var count := int(gui.blueprint.stack_count / 2.0)

	# Create a brand new BlueprintEntity and set its size to what we've calculated.
	var new_stack: BlueprintEntity = gui.blueprint.duplicate()
	new_stack.stack_count = count
	
	# Reduce the mouse's inventory by that amount
	gui.blueprint.stack_count -= count
	gui.update_label()
	
	# And set the panel's inventory to the new stack
	self.held_item = new_stack
