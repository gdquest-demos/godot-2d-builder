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

onready var player_inventory := $InventoryWindow
onready var quickbar_container := $MarginContainer/MarginContainer
onready var quickbar := $MarginContainer/MarginContainer/Quickbar
onready var _drag_preview := $DragPreview


func _ready() -> void:
	player_inventory.setup(self)
	quickbar.setup(self)
	
	# ----- Temp Debug system -----
	# TODO: Make proper debug system
	var index := 0
	for item in debug_items.keys():
		var item_instance: Node = item.instance()
		var panel: Panel = player_inventory.inventories.get_child(0).panels[index]
		panel.held_item = item_instance
		item_instance.stack_count = min(item_instance.stack_size, debug_items[item])
		panel._update_label()
		index += 1


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		player_inventory.visible = not player_inventory.visible

		if player_inventory.visible:
			player_inventory.claim_quickbar(quickbar)
		else:
			_claim_quickbar()
	
	for i in QUICKBAR_ACTIONS.size():
		var quick_action: String = QUICKBAR_ACTIONS[i]
		if InputMap.event_is_action(event, quick_action) and event.is_pressed():
			_simulate_input(quickbar.panels[i])
			break


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


func destroy_blueprint() -> void:
	_drag_preview.destroy_blueprint()


func update_label() -> void:
	_drag_preview.update_label()
