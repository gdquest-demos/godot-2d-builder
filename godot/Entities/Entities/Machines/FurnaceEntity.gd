extends Entity


onready var gui := $GUIComponent
onready var work := $WorkComponent

var available_fuel := 0.0

onready var animation := $AnimationPlayer


func _setup_work() -> void:
	if (gui.window.fuel or available_fuel > 0.0) and gui.window.ore and work.available_work <= 0.0:
		var fuel_interactivity: String = gui.window.fuel.interactivity_id if gui.window.fuel else "fuel"
		work.setup_work([fuel_interactivity, gui.window.ore.interactivity_id])
		if work.current_output:
			work.is_enabled = not gui.window.output.held_item or work.current_output.id == gui.window.output.held_item.id
			if available_fuel <= 0.0:
				_consume_fuel(0.0)


func _on_GUIComponent_gui_status_changed() -> void:
	_setup_work()


func _on_WorkComponent_work_accomplished(amount: float) -> void:
	_consume_fuel(amount)


func _consume_fuel(amount: float) -> void:
	available_fuel -= amount
	if available_fuel <= 0.0 and gui.window.fuel:
		available_fuel += 10.0
		gui.window.fuel.stack_count -= 1
		if gui.window.fuel.stack_count == 0:
			gui.window.fuel.queue_free()
			gui.window.fuel = null
		else:
			gui.window.update_labels()
	work.is_enabled = available_fuel > 0.0


func _consume_ore() -> void:
	gui.window.ore.stack_count -= 1
	if gui.window.ore.stack_count == 0:
		gui.window.ore.queue_free()
		gui.window.ore = null
	else:
		gui.window.update_labels()


func _on_WorkComponent_work_done(output: BlueprintEntity) -> void:
	_consume_ore()
	gui.window.grab_output(output)
	_setup_work()


func _on_WorkComponent_work_enabled_changed(enabled) -> void:
	if enabled:
		animation.play("Work")
	else:
		animation.play("Shutdown")
