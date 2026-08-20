# Power source. Consumes fuel and acts as a power source.
extends Entity

const BOOTUP_TIME := 6
const SHUTDOWN_TIME := 3

var available_fuel := 0.0
var last_max_fuel := 0.0

@onready var animation_player := $AnimationPlayer
@onready var shaft := $PistonShaft
@onready var power := $PowerSource
@onready var gui := $GUIComponent


func get_info() -> String:
	return "%.1f j/s" % power.get_effective_power()


func _setup_work() -> void:
	if not animation_player.is_playing() and (gui.gui.fuel or available_fuel > 0.0):
		
		
		animation_player.play("Work")
		var tween := create_tween()
		var tween_method := create_tween()
		var tween_color := create_tween()
		tween.tween_property(animation_player, "speed_scale", 1, BOOTUP_TIME).from(0)
		tween_method.tween_method(_update_efficiency, 0.0, 1.0, BOOTUP_TIME)
		tween_color.tween_property(shaft, "modulate",  Color(0.5, 1.0, 0.5), BOOTUP_TIME).from(Color.WHITE)
		_consume_fuel(0.0)
	elif (
		animation_player.is_playing()
		and animation_player.current_animation == "Work"
		and not (gui.gui.fuel or available_fuel > 0.0)
	):
		var work_animation: Animation = animation_player.get_animation(
			animation_player.current_animation
		)
		work_animation.loop_mode = Animation.LOOP_NONE
		await animation_player.animation_finished
		work_animation.loop_mode = Animation.LOOP_LINEAR

		animation_player.play("Shutdown")
		animation_player.speed_scale = 1.0
		
		var tween_method := create_tween()
		var tween_color := create_tween()
		tween_method.tween_property(shaft, "modulate", Color(1, 1, 1), SHUTDOWN_TIME).from(shaft.modulate)
		tween_color.tween_method(_update_efficiency, 1, 0, SHUTDOWN_TIME)


func _update_efficiency(value: float) -> void:
	power.efficiency = value
	Events.emit_signal("info_updated", self)


func _consume_fuel(amount: float) -> void:
	available_fuel = max(available_fuel - amount, 0.0)
	if available_fuel <= 0.0 and gui.gui.fuel:
		last_max_fuel = Recipes.Fuels[Library.get_entity_name_from(gui.gui.fuel)]
		available_fuel += last_max_fuel

		gui.gui.fuel.stack_count -= 1
		if gui.gui.fuel.stack_count == 0:
			gui.gui.fuel.queue_free()
			gui.gui.fuel = null
		else:
			gui.gui.update_labels()
	else:
		_setup_work()
	gui.gui.set_fuel((available_fuel / last_max_fuel) if last_max_fuel > 0.0 else 0.0)


func _on_GUIComponent_gui_status_changed() -> void:
	_setup_work()


func _on_PowerSource_power_updated(_power_draw, delta) -> void:
	_consume_fuel(delta)
