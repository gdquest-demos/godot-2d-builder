extends StaticBody2D


export var max_storage := 1000.0

var stored_power := 0.0 setget _set_stored_power
var last_stored_power := 0.0

onready var producer := $PowerProducer
onready var consumer := $PowerConsumer
onready var indicator := $Indicator


func _set_stored_power(value: float) -> void:
	stored_power = min(value, max_storage)

	if stored_power > 0:
		producer.efficiency = 1.0

	consumer.is_working = stored_power < max_storage
	
	indicator.material.set_shader_param("amount", stored_power / max_storage)
	indicator.modulate = Color.red if stored_power < max_storage else Color.green

	if not is_equal_approx(last_stored_power, stored_power):
		Events.emit_signal("power_updated", global_position)
		last_stored_power = stored_power


func _on_PowerConsumer_acted(grid, delta: float) -> void:
	if grid.available_power < 0:
		self.stored_power = stored_power + grid.available_power * delta


func _on_PowerProducer_acted(grid, delta: float) -> void:
	if grid.available_power > 0:
		self.stored_power = stored_power + grid.available_power * delta
