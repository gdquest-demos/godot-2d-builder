extends CenterContainer

const QUICKBAR_ACTIONS := [
	"quickbar_1",
	"quickbar_2",
	"quickbar_3",
	"quickbar_4",
	"quickbar_5",
	"quickbar_6",
	"quickbar_7",
	"quickbar_8",
	"quickbar_9",
	"quickbar_0"
]

export var debug_items := {}

var blueprint: BlueprintEntity setget _set_blueprint, _get_blueprint
var is_open := false
var _open_gui: Control
var mouse_in_gui := false

onready var player_inventory := $HBoxContainer/InventoryWindow
onready var crafting_window := $HBoxContainer/CraftingGUI
onready var quickbar_container := $MarginContainer/MarginContainer
onready var quickbar := $MarginContainer/MarginContainer/Quickbar
onready var _drag_preview := $DragPreview
onready var info_gui := $InfoGUI
onready var deconstruct_bar := $DeconstructProgressBar
onready var _gui_rect := $HBoxContainer


func _ready() -> void:
	player_inventory.setup(self)
	quickbar.setup(self)
	crafting_window.setup(self)
	Log.log_error(
		Events.connect("entered_pickup_area", self, "_on_Player_entered_pickup_area"), "GUI"
	)

	# ----- Temp Debug system -----
	# TODO: Make proper debug system
	for item in debug_items.keys():
		if not Library.blueprints.has(item):
			continue

		var item_instance: Node = Library.blueprints[item].instance()
		item_instance.stack_count = min(item_instance.stack_size, debug_items[item])
		if not add_to_inventory(item_instance):
			item_instance.queue_free()
			return


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		if is_open:
			_close_inventories()
			info_gui.hide()
		else:
			_open_inventories(true)
	else:
		for i in QUICKBAR_ACTIONS.size():
			var quick_action: String = QUICKBAR_ACTIONS[i]
			if InputMap.event_is_action(event, quick_action) and event.is_pressed():
				_simulate_input(quickbar.panels[i])
				break


func _process(delta: float) -> void:
	var mouse_position := get_global_mouse_position()
	mouse_in_gui = is_open and _gui_rect.get_rect().has_point(mouse_position)


func add_to_inventory(item: BlueprintEntity) -> bool:
	if item.get_parent() != null:
		item.get_parent().remove_child(item)

	if quickbar.add_to_first_available_inventory(item):
		return true

	return player_inventory.add_to_first_available_inventory(item)


func find_panels_with(item_id: String) -> Array:
	var existing_stacks: Array = (
		quickbar.find_panels_with(item_id)
		+ player_inventory.find_panels_with(item_id)
	)

	return existing_stacks


func find_inventory_bars_in(component: GUIComponent) -> Array:
	var output := []
	var parent_stack := [component.gui]

	while not parent_stack.empty():
		var current: Node = parent_stack.pop_back()

		if current is InventoryBar:
			output.push_back(current)

		parent_stack += current.get_children()

	return output


func is_in_inventory(item_id: String, amount: int) -> bool:
	var existing_stacks := find_panels_with(item_id)
	if existing_stacks.empty():
		return false

	var total := 0

	for stack in existing_stacks:
		total += stack.held_item.stack_count

	return total >= amount


func destroy_blueprint() -> void:
	_drag_preview.destroy_blueprint()


func update_label() -> void:
	_drag_preview.update_label()


func open_entity_gui(entity: Entity) -> void:
	var component := get_gui_component_from(entity)
	if not component:
		return
	
	if is_open:
		_close_inventories()

	_open_gui = component.gui
	if not _open_gui.get_parent() == player_inventory.inventory_path:
		player_inventory.inventory_path.add_child(_open_gui)
		player_inventory.inventory_path.move_child(_open_gui, 0)
	_open_gui.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_open_gui.setup(self)
	_open_inventories(false)


func get_gui_component_from(entity: Node) -> GUIComponent:
	for child in entity.get_children():
		if child is GUIComponent:
			return child

	return null


func _open_inventories(open_crafting: bool) -> void:
	is_open = true
	player_inventory.visible = true
	player_inventory.claim_quickbar(quickbar)
	if open_crafting:
		crafting_window.update_recipes()
		crafting_window.visible = true


func _close_inventories() -> void:
	is_open = false
	player_inventory.visible = false
	crafting_window.visible = false
	_claim_quickbar()
	if _open_gui:
		player_inventory.inventory_path.remove_child(_open_gui)
		_open_gui = null


func _simulate_input(panel: InventoryPanel) -> void:
	var input := InputEventMouseButton.new()
	input.button_index = BUTTON_LEFT
	input.pressed = true
	panel._gui_input(input)


func _claim_quickbar() -> void:
	quickbar.get_parent().remove_child(quickbar)
	quickbar_container.add_child(quickbar)


func _set_blueprint(value: BlueprintEntity) -> void:
	if not is_inside_tree():
		yield(self, "ready")
	_drag_preview.blueprint = value


func _get_blueprint() -> BlueprintEntity:
	return _drag_preview.blueprint


func _on_Player_entered_pickup_area(entity: GroundEntity, player: KinematicBody2D) -> void:
	if entity and entity.blueprint:
		var amount := entity.blueprint.stack_count
		if add_to_inventory(entity.blueprint):
			entity.do_pickup(player)
		else:
			if entity.blueprint.stack_count < amount:
				var new_entity := entity.duplicate()
				entity.get_parent().call_deferred("add_child", new_entity)
				new_entity.call_deferred("setup", entity.blueprint)
				new_entity.call_deferred("do_pickup", player)


func _on_inventory_changed(_panel: Panel, _held_item: BlueprintEntity) -> void:
	crafting_window.update_recipes()
