class_name WorkComponent
extends Node

signal work_accomplished(amount)
signal work_done(output)
signal work_enabled_changed(enabled)

var current_output: BlueprintEntity
var available_work := 0.0
var is_enabled := false setget _set_is_enabled


func setup_work(inputs: Array) -> bool:
#	for recipe in recipes.recipes:
#		var can_craft := true
#		for input in inputs:
#			if not input in recipe.inputs:
#				can_craft = false
#				break
#
#		if can_craft:
#			var Blueprint: PackedScene = load(recipe.output)
#			if Blueprint:
#				current_output = Blueprint.instance()
#				current_output.stack_count = recipe.amount_produced
#				available_work = recipe.time_per_produce
#				return true
#
	return false


func work(delta: float) -> void:
	if is_enabled and available_work > 0.0:
		var work_done := min(available_work, delta)
		available_work -= work_done
		emit_signal("work_accomplished", work_done)
		if available_work <= 0.0:
			emit_signal("work_done", current_output)


func _set_is_enabled(value: bool) -> void:
	if is_enabled != value:
		emit_signal("work_enabled_changed", value)
	is_enabled = value
