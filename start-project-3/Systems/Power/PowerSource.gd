## Class name is used for comparison purposes
class_name PowerSource
extends Node

## Signal for the entity to react to it for when the source should emit an amount of
## power each system tick. Passes in the amount of power the system demanded
## and the delta for the tick.
signal power_updated(power_draw, delta)

## The possible amount of power for the machine to provide in units per tick.
export var power_amount := 10.0

## The possible directions for power to come _out_ of, if not omni-directional.
## The FLAGS keyword makes it a multiple choice answer in the inspector.
export (Types.Direction, FLAGS) var output_direction := 15

## How efficient the machine is at present. For instance, a machine that has no work
## to do has an efficiency of 0 where one that has a job has an efficiency of 1.
## Affects the final power demand.
var efficiency := 0.0


## Returns a float indicating the possible power multiplied by the current efficiency.
func get_effective_power() -> float:
	return power_amount * efficiency
