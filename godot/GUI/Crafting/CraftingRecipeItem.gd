extends PanelContainer

signal recipe_activated(recipe, output)

const PATH_TO_CUSTOM_PANEL := "custom_styles/panel"

export var regular_style: StyleBoxFlat
export var highlight_style: StyleBoxFlat
export var bright_style: StyleBoxFlat

onready var sprite := $Control/BlueprintSprite
onready var recipe_name := $Control/RecipeName


func _ready() -> void:
	if regular_style:
		set(PATH_TO_CUSTOM_PANEL, regular_style)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var recipe_filename: String = recipe_name.recipe_name
		var recipe: Dictionary = Recipes.Crafting[recipe_filename]
		emit_signal("recipe_activated", recipe, recipe_filename)
		set(PATH_TO_CUSTOM_PANEL, bright_style)
	if event is InputEventMouseMotion:
		_on_CraftingRecipe_mouse_entered()


func setup(name: String, texture: Texture, uses_region_rect: bool, region_rect: Rect2) -> void:
	recipe_name.recipe_name = name
	sprite.texture = texture
	sprite.region_enabled = uses_region_rect
	sprite.region_rect = region_rect


func _on_CraftingRecipe_mouse_exited() -> void:
	set(PATH_TO_CUSTOM_PANEL, regular_style)
	Events.emit_signal("hovered_over_entity", null)


func _on_CraftingRecipe_mouse_entered() -> void:
	set(PATH_TO_CUSTOM_PANEL, highlight_style)
	var recipe_filename: String = recipe_name.recipe_name
	Events.emit_signal("hovered_over_recipe", recipe_filename, Recipes.Crafting[recipe_filename])
