class_name PowerReceiver
extends Node

signal received_power(amount, delta)

export var power_required := 10.0

export (Types.Direction, FLAGS) var input_direction := 15

var efficiency := 0.0


func get_effective_power() -> float:
	return power_required * efficiency
