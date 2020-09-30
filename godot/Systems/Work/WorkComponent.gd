class_name WorkComponent
extends Node

signal work_accomplished(amount)
signal work_done(output)
signal work_enabled_changed(enabled)

var current_recipe: Dictionary
var current_output: BlueprintEntity
var available_work := 0.0
var work_speed := 0.0
var is_enabled := false setget _set_is_enabled


func setup_work(inputs: Dictionary, recipe_map: Dictionary) -> bool:
	for output in recipe_map.keys():
		if not Library.blueprints.has(output):
			continue

		var can_craft := true
		var recipe_inputs: Array = recipe_map[output].inputs.keys()

		for input in inputs.keys():
			if not input in recipe_inputs or inputs[input] < recipe_map[output].inputs[input]:
				can_craft = false
				break

		if can_craft:
			current_recipe = recipe_map[output]
			current_output = Library.blueprints[output].instance()
			current_output.stack_count = current_recipe.amount
			available_work = current_recipe.time
			return true

	return false


func work(delta: float) -> void:
	if is_enabled and available_work > 0.0:
		var work_done := delta * work_speed
		available_work -= work_done
		emit_signal("work_accomplished", work_done)
		if available_work <= 0.0:
			emit_signal("work_done", current_output)


func _set_is_enabled(value: bool) -> void:
	if is_enabled != value:
		emit_signal("work_enabled_changed", value)
	is_enabled = value
