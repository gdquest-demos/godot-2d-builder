class_name PowerComponent
extends Node


signal acted(grid, delta)


func act(grid, delta: float) -> void:
	emit_signal("acted", grid, delta)
