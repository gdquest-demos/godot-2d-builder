extends PanelContainer

signal recipe_activated(recipe, output)

export var regular_style: StyleBoxFlat
export var highlight_style: StyleBoxFlat
export var bright_style: StyleBoxFlat

onready var sprite := $Control/Sprite
onready var label := $Control/Label


func _ready() -> void:
	if regular_style:
		set("custom_styles/panel", regular_style)


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		var recipe_filename: String = label.text.replace(" ", "")
		var recipe: Dictionary = Recipes.Crafting[recipe_filename]
		emit_signal("recipe_activated", recipe, recipe_filename)
		set("custom_styles/panel", bright_style)
	if event is InputEventMouseMotion:
		_on_CraftingRecipe_mouse_entered()


func setup(name: String, texture: Texture, uses_region_rect: bool, region_rect: Rect2) -> void:
	label.text = name
	sprite.texture = texture
	sprite.region_enabled = uses_region_rect
	sprite.region_rect = region_rect


func _on_CraftingRecipe_mouse_exited() -> void:
	set("custom_styles/panel", regular_style)
	Events.emit_signal("hovered_over_entity", null)


func _on_CraftingRecipe_mouse_entered() -> void:
	set("custom_styles/panel", highlight_style)
	var recipe_filename: String = label.text.replace(" ", "")
	Events.emit_signal("hovered_over_recipe", recipe_filename, Recipes.Crafting[recipe_filename])
