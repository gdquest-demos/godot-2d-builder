extends MarginContainer

const CraftingItem := preload("CraftingRecipeItem.tscn")

var gui: Control

@onready var items := $PanelContainer/CraftingList/ScrollContainer/VBoxContainer


func setup(_gui: Control) -> void:
	gui = _gui
	var gui_scale: float = ProjectSettings.get_setting("game_gui/gui_scale")
	self.custom_minimum_size = Vector2(400, 0) * gui_scale



func update_recipes() -> void:
	# delete everything there was before
	for child in items.get_children():
		child.queue_free()


	for output in Recipes.Crafting.keys():
		var recipe: Dictionary = Recipes.Crafting[output]

		var can_craft := true
		for input in recipe.inputs.keys(): # get all the necessary types of recourses
			if not gui.is_in_inventory(input, recipe.inputs[input]): # type, requiredAmount
				can_craft = false
				break

		if not can_craft:
			continue

		var temp: BlueprintEntity = Library.blueprints[output].instantiate()

		var item := CraftingItem.instantiate()
		items.add_child(item)
		var sprite: Sprite2D = temp.get_node("Sprite2D")
		item.setup(
			Library.get_entity_name_from(temp),
			sprite.texture,
			sprite.region_enabled,
			sprite.region_rect
		)
		Log.log_error(item.recipe_activated.connect(_on_recipe_activated), "CraftingGUI")
		temp.free()


func _on_recipe_activated(recipe: Dictionary, output: String) -> void:
	for input in recipe.inputs.keys():
		var panels: Array = gui.find_panels_with(input)

		var count: int = recipe.inputs[input]
		for panel in panels:
			if panel.held_item.stack_count >= count:
				panel.held_item.stack_count -= count
				count = 0
			else:
				count -= panel.held_item.stack_count
				panel.held_item.stack_count = 0

			if panel.held_item.stack_count == 0:
				panel.held_item.queue_free()
				panel.held_item = null

			panel._update_label()

			if count == 0:
				break

	var item: BlueprintEntity = Library.blueprints[output].instantiate()
	item.stack_count = recipe.amount

	if not gui.add_to_inventory(item):
		pass
