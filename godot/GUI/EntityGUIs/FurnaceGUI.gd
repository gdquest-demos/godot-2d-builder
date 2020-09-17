extends BaseMachineGUI


var ore: BlueprintEntity
var fuel: BlueprintEntity


func _setup(gui: Control) -> void:
	$HBoxContainer/VBoxContainer/OreBar.setup(gui)
	$HBoxContainer/VBoxContainer/FuelBar.setup(gui)
	$HBoxContainer/VBoxContainer3/Output.setup(gui)


func _on_OreBar_inventory_changed(panel, held_item) -> void:
	ore = held_item
	emit_signal("gui_status_changed")


func _on_FuelBar_inventory_changed(panel, held_item) -> void:
	fuel = held_item
	emit_signal("gui_status_changed")
