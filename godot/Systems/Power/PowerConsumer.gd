class_name PowerConsumer
extends PowerComponent


export var power_per_tick := 0 setget , _get_power_per_tick

var is_working := false setget _set_is_working
var last_is_working := false



func _set_is_working(value: bool) -> void:
	is_working = value
	if is_working != last_is_working:
		Events.emit_signal("power_updated", owner.global_position)
		last_is_working = is_working


func _get_power_per_tick() -> int:
	return power_per_tick if is_working else 0
