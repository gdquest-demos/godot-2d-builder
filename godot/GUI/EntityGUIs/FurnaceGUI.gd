extends BaseMachineGUI


var ore: BlueprintEntity
var fuel: BlueprintEntity
var output: Panel

onready var ore_container := $HBoxContainer/VBoxContainer/OreBar
onready var fuel_container := $HBoxContainer/VBoxContainer/FuelBar
onready var output_container := $HBoxContainer/VBoxContainer3/Output


func _setup(gui: Control) -> void:
	ore_container.setup(gui)
	fuel_container.setup(gui)
	output_container.setup(gui)
	output = output_container.panels[0]


func grab_output(item: BlueprintEntity) -> void:
	if not output.held_item:
		output.held_item = item
	elif output.held_item.id == item.id:
		output.held_item.stack_count += item.stack_count
		item.queue_free()
	output_container.update_labels()


func _on_OreBar_inventory_changed(_panel, held_item) -> void:
	ore = held_item
	emit_signal("gui_status_changed")


func _on_FuelBar_inventory_changed(_panel, held_item) -> void:
	fuel = held_item
	emit_signal("gui_status_changed")


func update_labels() -> void:
	ore_container.update_labels()
	fuel_container.update_labels()
	output_container.update_labels()
