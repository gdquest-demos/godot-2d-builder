extends Label

var recipe_name := "" setget _set_recipe_name


func _set_recipe_name(value: String) -> void:
	recipe_name = value
	text = recipe_name.capitalize()
