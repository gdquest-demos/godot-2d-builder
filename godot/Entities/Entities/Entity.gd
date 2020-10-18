class_name Entity
extends Node2D

const OUTLINE_SIZE := 3.0
const OutlineMaterial := preload("res://Shared/outline_material.tres")

export var deconstruct_filter: String

var pickup_count := 1 setget , _get_pickup_count

var _sprites := []


func _ready() -> void:
	_find_sprite_children_of(self)


func toggle_outline(enabled: bool) -> void:
	for sprite in _sprites:
		if sprite.material:
			sprite.material.set_shader_param("line_thickness", OUTLINE_SIZE if enabled else 0.0)


func _setup(_blueprint: BlueprintEntity) -> void:
	pass


func _get_pickup_count() -> int:
	return 1


func _find_sprite_children_of(parent: Node) -> void:
	var outline_material := OutlineMaterial.duplicate()
	for child in parent.get_children():
		if child is Sprite:
			_sprites.push_back(child)
			child.material = outline_material
		_find_sprite_children_of(child)
