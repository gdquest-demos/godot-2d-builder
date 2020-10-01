class_name Recipes
extends Reference

const Fuels := {Lumber = 50.0, Coal = 100.0, Branches = 10.0}

const Smelting := {
	Ingot = {inputs = {"Ore": 1}, amount = 1, time = 5.0},
	Coal = {inputs = {"Lumber": 1}, amount = 1, time = 5.0}
}

const Crafting := {
	Pickaxe = {inputs = {"Branches": 2, "Ingot": 3}, amount = 1, time = 1.0},
	CrudePickaxe = {inputs = {"Branches": 2, "Stone": 8}, amount = 1, time = 1.0},
	Axe = {inputs = {"Branches": 2, "Ingot": 3}, amount = 1, time = 1.0},
	Branches = {inputs = {"Lumber": 1, "Axe": 0}, amount = 5, time = 1.0},
	Chest = {inputs = {"Lumber": 2, "Branches": 3, "Ingot": 1}, amount = 1, time = 1.0}
}

static func get_recipes_with_ingredient(ingredient: String, recipe: Dictionary) -> Array:
	var recipe_list := []
	for output in recipe:
		if recipe[output].inputs.has(ingredient):
			recipe_list.push_back(recipe[output])
	
	return recipe_list


static func get_outputs_with_ingredient(ingredient: String, recipe: Dictionary) -> Array:
	var output_list := []
	for output in recipe:
		if recipe[output].inputs.has(ingredient):
			output_list.push_back(output)
	return output_list
