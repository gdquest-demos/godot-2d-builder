# Represents a slot in which an item can be held. Inventory is kept track of 
# through being a child of the panel.
class_name InventoryPanel
extends Panel

signal held_item_changed(panel, item)

var held_item: BlueprintEntity setget _set_held_item
var silent := false
var gui: Control
var _filter := ""

onready var count_label := $Label


func _gui_input(event: InputEvent) -> void:
	var left_click := event.is_action_pressed("left_click")
	var right_click := event.is_action_pressed("right_click")

	if left_click or right_click:
		if gui.blueprint:
			var blueprint_name := Library.get_filename_from(gui.blueprint)
			if held_item:
				var held_item_name := Library.get_filename_from(held_item)

				var item_is_same_type: bool = held_item_name == blueprint_name
				var stack_has_space: bool = held_item.stack_count < held_item.stack_size

				if item_is_same_type and stack_has_space:
					if left_click:
						_stack_items()
					elif right_click:
						_stack_items(true)

				else:
					if left_click and _is_valid_filter(held_item_name):
						_swap_items()
			else:
				if left_click and _is_valid_filter(blueprint_name):
					_grab_item()

				elif right_click and _is_valid_filter(blueprint_name):
					if gui.blueprint.stack_count > 1:
						_grab_split_items()
					else:
						_grab_item()

		elif held_item:
			if left_click:
				_release_item()
			elif right_click:
				if held_item.stack_count == 1:
					_release_item()
				else:
					_split_items()
	elif event is InputEventMouseMotion and held_item:
		Events.emit_signal("hovered_over_entity", held_item)


func setup(_gui: Control, filter := "") -> void:
	gui = _gui
	if not filter.empty():
		_filter = filter


func _set_held_item(value: BlueprintEntity) -> void:
	if held_item:
		remove_child(held_item)
	held_item = value

	if held_item:
		add_child(held_item)
		move_child(held_item, 0)
		held_item.make_inventory()
	_update_label()
	emit_signal("held_item_changed", self, held_item)


func _update_label() -> void:
	var can_be_stacked := held_item and held_item.stack_size > 1

	if can_be_stacked:
		count_label.text = str(held_item.stack_count)
		count_label.show()
	else:
		count_label.text = str(1)
		count_label.hide()


func _stack_items(split := false) -> void:
	var count: int = gui.blueprint.stack_count / (2 if split else 1)

	if split:
		gui.blueprint.stack_count -= count
		gui.update_label()
	else:
		gui.destroy_blueprint()

	held_item.stack_count += count
	_update_label()


func _swap_items() -> void:
	var item: BlueprintEntity = gui.blueprint
	gui.blueprint = null

	var current_item := held_item
	self.held_item = item
	gui.blueprint = current_item


func _grab_item() -> void:
	var item: BlueprintEntity = gui.blueprint
	gui.blueprint = null
	self.held_item = item


func _release_item() -> void:
	var item := held_item
	self.held_item = null
	gui.blueprint = item


func _split_items() -> void:
	var count := int(held_item.stack_count / 2.0)

	var new_stack := held_item.duplicate()
	new_stack.stack_count = count
	held_item.stack_count -= count

	gui.blueprint = new_stack
	_update_label()


func _grab_split_items() -> void:
	var count: int = gui.blueprint.stack_count / 2

	var new_stack: BlueprintEntity = gui.blueprint.duplicate()
	new_stack.stack_count = count
	gui.blueprint.stack_count -= count
	self.held_item = new_stack

	_update_label()


func _is_valid_filter(types: String) -> bool:
	if _filter.empty() or _filter.find(types) != -1:
		return true

	if _filter.find("Fuels") != -1 and Recipes.Fuels.has(types):
		return true

	return false


func _on_InventoryPanel_mouse_exited() -> void:
	Events.emit_signal("hovered_over_entity", null)
