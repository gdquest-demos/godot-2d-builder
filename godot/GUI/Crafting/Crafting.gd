extends MarginContainer

const CraftingItem := preload("CraftingRecipeItem.tscn")

var gui: Control

onready var items := $PanelContainer/HBoxContainer/CraftingLift/ScrollContainer/VBoxContainer


func setup(_gui: Control) -> void:
	gui = _gui


func update_recipes() -> void:
#	assert(recipes, "Must provide a Recipes resource to CraftingGUI.")
#
#	for child in items.get_children():
#		child.queue_free()
#
#	for recipe in recipes.recipes:
#		if not recipe.hand_craftable:
#			continue
#
#		var can_craft := true
#		for input in recipe.inputs.keys():
#			if not gui.is_in_inventory(input, recipe.inputs[input]):
#				can_craft = false
#				break
#
#		if not can_craft:
#			continue
#
#		var temp: BlueprintEntity = Library.blueprints[recipe.output].instance()
#
#		var item := CraftingItem.instance()
#		items.add_child(item)
#		var sprite: Sprite = temp.get_node("Sprite")
#		item.setup(
#			Library.get_filename_from(temp).capitalize(),
#			sprite.texture,
#			sprite.region_enabled,
#			sprite.region_rect
#		)
#
#		temp.free()
	pass
