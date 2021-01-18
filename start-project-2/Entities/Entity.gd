class_name Entity
extends Node2D

## Specifies the object type that is able/allowed to deconstruct this entity
## I.E. the player must have an Axe to chop down a tree
export var deconstruct_filter: String

## Specifies how many entities to create when deconstructing the object
var pickup_count := 1 setget , _get_pickup_count


## Any initialization step occurs in this overridable function. Overriding it
## is optional.
func _setup(_blueprint) -> void:
	pass


## GDScript does not support overriding variables; use a getter to override
## the value it returns.
func _get_pickup_count() -> int:
	return 1
