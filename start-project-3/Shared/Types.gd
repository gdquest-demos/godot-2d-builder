class_name Types
extends Reference

## A bitwise operator to indicate possible directions up, down, left right.
## By combining them together, you can create directions combinations.
## I.E., 3 is right and down together
enum Direction { RIGHT = 1, DOWN = 2, LEFT = 4, UP = 8 }

## A dictionary of Vector2 directions to run through arrays and quickly check
## against neighboring tiles.
const NEIGHBORS := {
	Direction.RIGHT: Vector2.RIGHT,
	Direction.DOWN: Vector2.DOWN,
	Direction.LEFT: Vector2.LEFT,
	Direction.UP: Vector2.UP
}

## Group name constants
const POWER_MOVERS := "power_movers"
const POWER_RECEIVERS := "power_receivers"
const POWER_SOURCES := "power_sources"
