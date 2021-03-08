class_name FurnaceEntity
extends Entity

var available_fuel := 0.0
var last_max_fuel := 0.0

onready var gui := $GUIComponent
onready var work := $WorkComponent
onready var animation := $AnimationPlayer


func _ready() -> void:
	_set_initial_speed()


func get_info() -> String:
	if work.is_enabled:
		return (
			"Smelting: %s into %s\nTime left: %ss"
			% [
				Library.get_entity_name_from(gui.gui.ore),
				Library.get_entity_name_from(work.current_output),
				stepify(work.available_work, 0.1)
			]
		)
	else:
		return ""


func _set_initial_speed() -> void:
	work.work_speed = 1.0


func _setup_work() -> void:
	if (gui.gui.fuel or available_fuel > 0.0) and gui.gui.ore and work.available_work <= 0.0:
		var ore_id: String = Library.get_entity_name_from(gui.gui.ore)

		if work.setup_work({ore_id: gui.gui.ore.stack_count}, Recipes.Smelting):
			work.is_enabled = (
				not gui.gui.output.held_item
				or (
					Library.get_entity_name_from(work.current_output)
					== Library.get_entity_name_from(gui.gui.output.held_item)
				)
			)
			gui.gui.work(work.current_recipe.time)
			if available_fuel <= 0.0:
				_consume_fuel(0.0)
	elif work.available_work > 0.0 and not gui.gui.ore:
		work.available_work = 0.0
		work.is_enabled = false
		gui.gui.abort()
	elif work.available_work <= 0.0:
		work.is_enabled = false


func _consume_fuel(amount: float) -> void:
	available_fuel -= amount
	if available_fuel <= 0.0 and gui.gui.fuel:
		last_max_fuel = Recipes.Fuels[Library.get_entity_name_from(gui.gui.fuel)]
		available_fuel += last_max_fuel

		gui.gui.fuel.stack_count -= 1
		if gui.gui.fuel.stack_count == 0:
			gui.gui.fuel.queue_free()
			gui.gui.fuel = null

		gui.gui.update_labels()
	work.is_enabled = available_fuel > 0.0
	gui.gui.set_fuel(available_fuel / last_max_fuel)


func _consume_ore() -> bool:
	if gui.gui.ore:
		var consumption_count: int = work.current_recipe.inputs[Library.get_entity_name_from(
			gui.gui.ore
		)]
		if gui.gui.ore.stack_count >= consumption_count:
			gui.gui.ore.stack_count -= consumption_count
			if gui.gui.ore.stack_count == 0:
				gui.gui.ore.queue_free()
				gui.gui.ore = null

			gui.gui.update_labels()
			return true
	else:
		gui.gui.abort()
	return false


func _on_GUIComponent_gui_status_changed() -> void:
	_setup_work()


func _on_WorkComponent_work_accomplished(amount: float) -> void:
	_consume_fuel(amount)
	Events.emit_signal("info_updated", self)


func _on_WorkComponent_work_done(output: BlueprintEntity) -> void:
	if _consume_ore():
		gui.gui.grab_output(output)
		_setup_work()
	else:
		output.queue_free()
		work.is_enabled = false
	Events.emit_signal("info_updated", self)


func _on_WorkComponent_work_enabled_changed(enabled) -> void:
	if enabled:
		animation.play("Work")
	else:
		animation.play("Shutdown")


func _on_GUIComponent_gui_opened() -> void:
	gui.gui.set_fuel(available_fuel / last_max_fuel if last_max_fuel else 0.0)
	if work.is_enabled:
		gui.gui.work(work.current_recipe.time)
		gui.gui.seek(work.current_recipe.time - work.available_work)
