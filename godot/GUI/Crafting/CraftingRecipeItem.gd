extends PanelContainer

signal recipe_activated(recipe, output)

const DEFAULT_SIZE := Vector2(400.0, 100.0)

const PATH_TO_CUSTOM_PANEL := "custom_styles/panel"

export var regular_style: StyleBoxFlat
export var highlight_style: StyleBoxFlat
export var bright_style: StyleBoxFlat

onready var sprite := $MarginContainer/HBoxContainer/GUISprite
onready var recipe_name := $MarginContainer/HBoxContainer/RecipeName


func _ready() -> void:
	var gui_scale: float = ProjectSettings.get_setting("game_gui/gui_scale")
	sprite.scale = Vector2(gui_scale, gui_scale)
	rect_min_size = Vector2(400, 0) * gui_scale

	if regular_style:
		set(PATH_TO_CUSTOM_PANEL, regular_style)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var recipe_filename: String = recipe_name.recipe_name
		var recipe: Dictionary = Recipes.Crafting[recipe_filename]
		emit_signal("recipe_activated", recipe, recipe_filename)
		set(PATH_TO_CUSTOM_PANEL, bright_style)


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
