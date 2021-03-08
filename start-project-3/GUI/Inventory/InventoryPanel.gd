class_name InventoryPanel
extends Panel


signal held_item_changed(panel, item)

var held_item: BlueprintEntity setget _set_held_item

var gui: Control

onready var count_label := $Label


func _ready() -> void:
	var panel_size: float = ProjectSettings.get_setting("game_gui/inventory_size")
	rect_min_size = Vector2(panel_size, panel_size)
	rect_size = rect_min_size
	count_label.rect_min_size = rect_min_size
	count_label.rect_size = rect_min_size


func _gui_input(event: InputEvent) -> void:
	var left_click := event.is_action_pressed("left_click")
	var right_click := event.is_action_pressed("right_click")

	if left_click or right_click:
		if gui.blueprint:
			var blueprint_name := Library.get_entity_name_from(gui.blueprint)
			
			if is_instance_valid(held_item):
				var held_item_name := Library.get_entity_name_from(held_item)

				var item_is_same_type: bool = held_item_name == blueprint_name
				var stack_has_space: bool = held_item.stack_count < held_item.stack_size

				if item_is_same_type and stack_has_space:
					if left_click:
						_stack_items()
					elif right_click:
						_stack_items(true)

				else:
					if left_click:
						_swap_items()
			else:
				if left_click:
					_grab_item()

				elif right_click:
					if gui.blueprint.stack_count > 1:
						_grab_split_items()
					else:
						_grab_item()

		elif is_instance_valid(held_item):
			if left_click:
				_release_item()
			elif right_click:
				if held_item.stack_count == 1:
					_release_item()
				else:
					_split_items()


func setup(_gui: Control) -> void:
	gui = _gui


func _set_held_item(value: BlueprintEntity) -> void:
	if is_instance_valid(held_item) and held_item.get_parent() == self:
		remove_child(held_item)

	held_item = value

	if is_instance_valid(held_item):
		add_child(held_item)
		move_child(held_item, 0)
		held_item.display_as_inventory_icon()

	_update_label()
	
	emit_signal("held_item_changed", self, held_item)


func _update_label() -> void:
	var can_be_stacked := is_instance_valid(held_item) and held_item.stack_count > 1

	if can_be_stacked:
		count_label.text = str(held_item.stack_count)
		count_label.show()
	else:
		count_label.text = str(1)
		count_label.hide()


func _stack_items(split := false) -> void:
	var count: int = int(
		min(
			gui.blueprint.stack_count / (2 if split else 1),
			held_item.stack_size - held_item.stack_count
		)
	)

	if split:
		gui.blueprint.stack_count -= count
		gui.update_label()
	else:
		if count < gui.blueprint.stack_count:
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
	var count := int(gui.blueprint.stack_count / 2.0)

	var new_stack: BlueprintEntity = gui.blueprint.duplicate()
	new_stack.stack_count = count
	
	gui.blueprint.stack_count -= count
	gui.update_label()
	
	self.held_item = new_stack
