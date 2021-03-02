class_name PowerSource
extends Node

signal power_updated(power_draw, delta)

export var power_amount := 10.0

export (Types.Direction, FLAGS) var output_direction := 15

var efficiency := 0.0


func get_effective_power() -> float:
	return power_amount * efficiency
