class_name PowerProducer
extends PowerComponent


export var power_per_tick := 0 setget , _get_power_per_tick

var efficiency := 0.0 setget _set_efficiency
var last_efficiency := 0.0


func _get_power_per_tick() -> int:
	return int(efficiency * power_per_tick)


func _set_efficiency(value: float) -> void:
	efficiency = value
	if not is_equal_approx(last_efficiency, efficiency):
		Events.emit_signal("power_updated", owner.global_position)
		last_efficiency = efficiency
