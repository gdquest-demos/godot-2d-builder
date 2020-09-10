extends Panel


signal held_item_changed


var held_item: BlueprintEntity setget _set_held_item
var silent := false

onready var count_label := $Label


func _ready() -> void:
	if get_child_count() > 1:
		held_item = get_child(0)
		if held_item.name == "WireBlueprint":
			held_item.stack_count = 64
		_update_label()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if owner.held_item:
			if held_item:
				if held_item.id == owner.held_item.id and held_item.stack_count < held_item.stack_size:
					if event.button_index == BUTTON_LEFT:
						_stack_items()
					elif event.button_index == BUTTON_RIGHT:
						_stack_split_items()
				else:
					if event.button_index == BUTTON_LEFT:
						_swap_items()
			else:
				if event.button_index == BUTTON_LEFT:
					_grab_item()
				elif event.button_index == BUTTON_RIGHT:
					if owner.held_item.stack_count > 1:
						_grab_split_items()
					else:
						_grab_item()
		elif held_item:
			if event.button_index == BUTTON_LEFT:
				_release_item()
			elif event.button_index == BUTTON_RIGHT:
				if held_item.stack_count == 1:
					_release_item()
				else:
					_split_items()


func begin_silence() -> void:
	silent = true


func end_silence() -> void:
	silent = false


func _set_held_item(value: BlueprintEntity) -> void:
	if held_item:
		remove_child(held_item)
	held_item = value
	if held_item:
		add_child(held_item)
		move_child(held_item, 0)
		held_item.position = rect_size / 2
		held_item.scale = Vector2.ONE * 0.5
	_update_label()
	if not silent:
		emit_signal("held_item_changed")


func _update_label() -> void:
	if held_item and held_item.stack_size > 1:
		count_label.text = str(held_item.stack_count)
		count_label.show()
	else:
		count_label.text = str(1)
		count_label.hide()


func _stack_items() -> void:
	var count: int = owner.held_item.stack_count
	owner.destroy_held_item()
	held_item.stack_count += count
	_update_label()
	if not silent:
		emit_signal("held_item_changed")


func _stack_split_items() -> void:
	var count: int = owner.held_item.stack_count/2
	held_item.stack_count += count
	owner.held_item.stack_count -= count
	owner._update_label()
	_update_label()
	if not silent:
		emit_signal("held_item_changed")


func _swap_items() -> void:
	var item: BlueprintEntity = owner.held_item
	owner.held_item = null

	var current_item := held_item
	self.held_item = item
	owner.held_item = current_item


func _grab_item() -> void:
	var item: BlueprintEntity = owner.held_item
	owner.held_item = null
	self.held_item = item


func _release_item() -> void:
	var item := held_item
	self.held_item = null
	owner.held_item = item


func _split_items() -> void:
	var count := int(held_item.stack_count/2.0)
	var new_stack := held_item.duplicate()
	new_stack.stack_count = count
	held_item.stack_count -= count
	owner.held_item = new_stack
	_update_label()
	if not silent:
		emit_signal("held_item_changed")


func _grab_split_items() -> void:
	var count: int = owner.held_item.stack_count/2
	var new_stack: BlueprintEntity = owner.held_item.duplicate()
	new_stack.stack_count = count
	owner.held_item.stack_count -= count
	self.held_item = new_stack
	_update_label()
