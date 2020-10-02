extends Entity

onready var gui := $GUIComponent
onready var work := $WorkComponent
onready var power := $PowerReceiver
onready var animation := $AnimationPlayer


func get_info() -> String:
	if work.is_enabled:
		return (
			"Smelting: %s into %s\nTime left: %ss"
			% [
				Library.get_filename_from(gui.window.ore),
				Library.get_filename_from(work.current_output),
				(
					"%.1f" % [work.available_work / work.work_speed]
					if work.work_speed != 0.0
					else "INF"
				)
			]
		)
	else:
		return ""


func _setup_work() -> void:
	if work.available_work > 0.0 and gui.window.ore:
		if gui.window.output.held_item:
			var held_item_id := Library.get_filename_from(gui.window.output.held_item)
			var output_id: String = Recipes.get_outputs_with_ingredient(Library.get_filename_from(gui.window.ore), Recipes.Smelting).front()

			if held_item_id == output_id:
				return
			else:
				_stop_all_work()
		elif not work.is_enabled:
			work.is_enabled = true
			power.efficiency = 1.0
			gui.window.work(work.current_recipe.time, work.work_speed)
		else:
			return

	if gui.window.ore and work.available_work <= 0.0:
		var ore_id: String = Library.get_filename_from(gui.window.ore)

		if work.setup_work({ore_id: gui.window.ore.stack_count}, Recipes.Smelting):
			work.is_enabled = (
				not gui.window.output.held_item
				or (
					Library.get_filename_from(work.current_output)
					== Library.get_filename_from(gui.window.output.held_item)
				)
			)
			if work.is_enabled:
				gui.window.work(work.current_recipe.time, work.work_speed)
				power.efficiency = 1.0
			else:
				power.efficiency = 0.0
	elif not gui.window.ore:
		_stop_all_work()


func _consume_ore() -> bool:
	if gui.window.ore:
		var ore_filename := Library.get_filename_from(gui.window.ore)
		if work.current_recipe.inputs.has(ore_filename):
			var consumption_count: int = work.current_recipe.inputs[ore_filename]
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


func _stop_all_work() -> void:
	work.available_work = 0.0
	gui.window.abort()
	power.efficiency = 0.0
	work.is_enabled = false


func _on_GUIComponent_gui_status_changed() -> void:
	_setup_work()


func _on_WorkComponent_work_accomplished(_amount: float) -> void:
	Events.emit_signal("info_updated", self)


func _on_WorkComponent_work_done(output: BlueprintEntity) -> void:
	if _consume_ore():
		gui.window.grab_output(output)
		_setup_work()
	else:
		output.queue_free()
		work.is_enabled = false
	Events.emit_signal("info_updated", self)


func _on_WorkComponent_work_enabled_changed(enabled: bool) -> void:
	if enabled:
		animation.play("Work")
	else:
		animation.play("Shutdown")


func _on_PowerReceiver_received_power(amount: float, _delta: float) -> void:
	var new_work_speed: float = amount / power.power_required
	if not is_zero_approx(abs(new_work_speed - work.work_speed)):
		gui.window.update_speed(new_work_speed)
		work.is_enabled = new_work_speed > 0.0
	work.work_speed = amount / power.power_required


func _on_GUIComponent_gui_opened() -> void:
	if work.is_enabled and work.work_speed > 0.0:
		gui.window.work(work.current_recipe.time, work.work_speed)
		gui.window.seek(work.current_recipe.time - work.available_work)
