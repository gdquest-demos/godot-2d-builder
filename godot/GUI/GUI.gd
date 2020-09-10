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


onready var player_inventory := $InventoryWindow
onready var drag_preview := $DragPreview
onready var quickbar := $MarginContainer/Quickbar


func _ready() -> void:
	player_inventory.setup(drag_preview)
	quickbar.setup(drag_preview, player_inventory.quickbar)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		player_inventory.visible = not player_inventory.visible
		quickbar.visible = not player_inventory.visible
	
	for quick_action in QUICKBAR_ACTIONS:
		if InputMap.event_is_action(event, quick_action) and event.is_pressed():
			var index: int = str2var(quick_action.split("quickbar_")[1])-1
			_simulate_input(quickbar.panels[index])
			break


func _simulate_input(panel: Panel) -> void:
	var input := InputEventMouseButton.new()
	input.button_index = BUTTON_LEFT
	input.pressed = true
	panel._gui_input(input)
