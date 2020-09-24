extends MarginContainer


const CraftingItem := preload("CraftingRecipeItem.tscn")

export(Resource) var recipes: Resource

var gui: Control

onready var items := $PanelContainer/HBoxContainer/CraftingLift/ScrollContainer/VBoxContainer


func setup(_gui: Control) -> void:
	gui = _gui


func update_recipes() -> void:
	assert(recipes, "Must provide a Recipes resource to CraftingGUI.")

	for recipe in recipes.recipes:
		if not recipe.hand_craftable:
			continue

		var inputs: Array = recipe.inputs
		var input_amounts: Array = recipe.input_amounts

		var can_craft := true
		for i in inputs.size():
			if not gui.is_interactable_in_inventory(inputs[i], input_amounts[i]):
				can_craft = false
				break
		
		if not can_craft:
			continue

		var output: PackedScene = load(recipe.output)
		var temp: BlueprintEntity = output.instance()

		var item := CraftingItem.instance()
		items.add_child(item)
		var sprite: Sprite = temp.get_node("Sprite")
		item.setup(temp.id.capitalize(), sprite.texture, sprite.region_enabled, sprite.region_rect)

		temp.free()
