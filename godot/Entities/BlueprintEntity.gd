class_name BlueprintEntity
extends Node2D


export var Entity: PackedScene
export var stack_size := 1
export var placeable := true
export var id := "entity"

var stack_count := 1


func make_inventory() -> void:
	position = Vector2(25, 25)
	scale = Vector2(0.5, 0.5)
	modulate = Color.white


func make_world() -> void:
	scale = Vector2.ONE
	position = Vector2.ONE
