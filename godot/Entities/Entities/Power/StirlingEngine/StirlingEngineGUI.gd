extends BaseMachineGUI

var fuel: BlueprintEntity
var output: Panel

onready var fuel_container := $HBoxContainer/FuelBar
onready var fuel_bar := $HBoxContainer/ColorRect


func set_fuel(amount: float) -> void:
	if fuel_bar:
		fuel_bar.material.set_shader_param("fill_amount", amount)


func setup(gui: Control) -> void:
	fuel_container.setup(gui)


func _on_FuelBar_inventory_changed(_panel, held_item) -> void:
	fuel = held_item
	emit_signal("gui_status_changed")


func update_labels() -> void:
	fuel_container.update_labels()
