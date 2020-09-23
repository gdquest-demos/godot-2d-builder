extends MarginContainer


const CraftingItem := preload("CraftingRecipeItem.tscn")

export(Resource) var recipes: Resource

onready var items := $PanelContainer/HBoxContainer/CraftingLift/ScrollContainer/VBoxContainer


func update_recipes() -> void:
	for recipe in recipes.recipes:
		if not recipe.hand_craftable:
			continue

		var output: PackedScene = load(recipe.output)
		var temp: BlueprintEntity = output.instance()

		var item := CraftingItem.instance()
		items.add_child(item)
		var sprite: Sprite = temp.get_node("Sprite")
		item.setup(temp.id.capitalize(), sprite.texture, sprite.region_enabled, sprite.region_rect)

		temp.free()

