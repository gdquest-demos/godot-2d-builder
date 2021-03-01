class_name FurnaceGUI
extends BaseMachineGUI

var ore: BlueprintEntity
var fuel: BlueprintEntity
var output: Panel

var ore_container: InventoryBar
var fuel_container: InventoryBar
var fuel_bar: ColorRect

onready var output_container := $HBoxContainer/Output
onready var tween := $Tween
onready var arrow := $HBoxContainer/GUISprite


func _ready() -> void:
	var scale: float = ProjectSettings.get_setting("game_gui/gui_scale")
	arrow.scale = Vector2(scale, scale)
	
	_find_nodes()


func work(time: float) -> void:
	if not is_inside_tree():
		return
	tween.interpolate_method(self, "_advance_work_time", 0, 1, time)
	tween.start()


func abort() -> void:
	tween.stop_all()
	tween.remove_all()
	arrow.material.set_shader_param("fill_amount", 0)


func set_fuel(amount: float) -> void:
	fuel_bar.material.set_shader_param("fill_amount", amount)


func seek(time: float) -> void:
	if tween.is_active():
		tween.seek(time)


func _advance_work_time(amount: float) -> void:
	arrow.material.set_shader_param("fill_amount", amount)


func setup(gui: Control) -> void:
	ore_container.setup(gui)
	fuel_container.setup(gui)
	output_container.setup(gui)
	output = output_container.panels[0]


func grab_output(item: BlueprintEntity) -> void:
	if not output.held_item:
		output.held_item = item
	else:
		var held_item_id := Library.get_entity_name_from(output.held_item)
		var item_id := Library.get_entity_name_from(item)
		if held_item_id == item_id:
			output.held_item.stack_count += item.stack_count

		item.queue_free()
	output_container.update_labels()


func _find_nodes() -> void:
	ore_container = $HBoxContainer/VBoxContainer/OreBar
	fuel_container = $HBoxContainer/VBoxContainer/HBoxContainer/FuelBar
	fuel_bar = $HBoxContainer/VBoxContainer/HBoxContainer/ColorRect


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
