## Class name is used for comparison purposes
class_name PowerReceiver
extends Node

## Signal for the entity to react to it for when the receiver gets an amount of
## power each system tick. Passes in the amount of power and the delta for the tick.
@warning_ignore("unused_signal") # DEBUG
signal received_power(amount, delta)

## The required amount of power for the machine to optimally function in units per tick.
## Anything less may mean the machine does not work, or that it works slower.
@export var power_required := 10.0

## The possible directions for power to come _in_ from, if not omni-directional.
@export var input_direction := 15 # (Types.Direction, FLAGS)

## How efficient the machine is at present. For instance, a furnace that has no work
## to do has an efficiency of 0.
var efficiency := 0.0


func get_effective_power() -> float:
	return power_required * efficiency
