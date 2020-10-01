extends Entity

var available_fuel := 0.0
var last_max_fuel := 0.0

onready var gui := $GUIComponent
onready var work := $WorkComponent
onready var animation := $AnimationPlayer


func _ready() -> void:
	work.work_speed = 1.0


func get_info() -> String:
	if work.is_enabled:
		return (
			"Smelting: %s into %s\nTime left: %ss"
			% [
				Library.get_filename_from(gui.window.ore),
				Library.get_filename_from(work.current_output),
				stepify(work.available_work, 0.1)
			]
		)
	else:
		return ""


func _setup_work() -> void:
	if (gui.window.fuel or available_fuel > 0.0) and gui.window.ore and work.available_work <= 0.0:
		var ore_id: String = Library.get_filename_from(gui.window.ore)

		if work.setup_work({ore_id: gui.window.ore.stack_count}, Recipes.Smelting):
			work.is_enabled = (
				not gui.window.output.held_item
				or (
					Library.get_filename_from(work.current_output)
					== Library.get_filename_from(gui.window.output.held_item)
				)
			)
			gui.window.work(work.current_recipe.time)
			if available_fuel <= 0.0:
				_consume_fuel(0.0)
	elif work.available_work > 0.0 and not gui.window.ore:
		work.available_work = 0.0
		work.is_enabled = false
		gui.window.abort()
	elif work.available_work <= 0.0:
		work.is_enabled = false


func _consume_fuel(amount: float) -> void:
	available_fuel -= amount
	if available_fuel <= 0.0 and gui.window.fuel:
		last_max_fuel = Recipes.Fuels[Library.get_filename_from(gui.window.fuel)]
		available_fuel += last_max_fuel

		gui.window.fuel.stack_count -= 1
		if gui.window.fuel.stack_count == 0:
			gui.window.fuel.queue_free()
			gui.window.fuel = null
		else:
			gui.window.update_labels()
	work.is_enabled = available_fuel > 0.0
	gui.window.set_fuel(available_fuel / last_max_fuel)


func _consume_ore() -> bool:
	if gui.window.ore:
		var consumption_count: int = work.current_recipe.inputs[Library.get_filename_from(
			gui.window.ore
		)]
		if gui.window.ore.stack_count >= consumption_count:
			gui.window.ore.stack_count -= consumption_count
			if gui.window.ore.stack_count == 0:
				gui.window.ore.queue_free()
				gui.window.ore = null
			else:
				gui.window.update_labels()
			return true
	else:
		gui.window.abort()
	return false


func _on_GUIComponent_gui_status_changed() -> void:
	_setup_work()


func _on_WorkComponent_work_accomplished(amount: float) -> void:
	_consume_fuel(amount)
	Events.emit_signal("info_updated", self)


func _on_WorkComponent_work_done(output: BlueprintEntity) -> void:
	if _consume_ore():
		gui.window.grab_output(output)
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
	gui.window.set_fuel(available_fuel / last_max_fuel if last_max_fuel else 0.0)
	if work.is_enabled:
		gui.window.work(work.current_recipe.time)
		gui.window.seek(work.current_recipe.time - work.available_work)
