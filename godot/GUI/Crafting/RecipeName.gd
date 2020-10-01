extends Label

var recipe_name := "" setget _set_recipe_name, _get_recipe_name


func _get_recipe_name() -> String:
	return recipe_name.replace(" ", "")


func _set_recipe_name(value: String) -> void:
	recipe_name = value.capitalize()
	text = recipe_name
