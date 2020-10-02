# TileMap that handles placing, hovering over, and activating entities in the world.
class_name EntityPlacer
extends TileMap

const MAXIMUM_WORK_DISTANCE := 275.0
const POSITION_OFFSET := Vector2(0, 25)
const DECONSTRUCT_TIME := 0.3

export var GroundEntityScene: PackedScene

var _gui: Control
var _last_hovered: Node2D = null
var _simulation: Simulation
var _player: KinematicBody2D
var _flat_entities: Node2D
var _current_deconstruct_location := Vector2.ZERO
var _ground: TileMap

onready var _deconstruct_timer := $Timer
onready var _deconstruct_tween := $Tween


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_abort_deconstruct()

	var global_mouse_position := get_global_mouse_position()
	var has_placeable_blueprint: bool = _gui.blueprint and _gui.blueprint.placeable
	
	var is_close_to_player := (
		global_mouse_position.distance_to(_player.global_position) < MAXIMUM_WORK_DISTANCE
	)
	
	var cellv := world_to_map(global_mouse_position)
	var cell_is_occupied := _simulation.is_cell_occupied(cellv)
	var is_on_ground := _ground.get_cellv(cellv) == 0

	if event.is_action_pressed("left_click"):
		if has_placeable_blueprint:
			if not cell_is_occupied and is_close_to_player and is_on_ground:
				_place_entity(cellv)
				_update_neighboring_flat_entities(cellv)

		elif cell_is_occupied and is_close_to_player:
			var entity := _simulation.get_entity_at(cellv)
			if entity.is_in_group(Types.GUI_ENTITIES):
				_gui.open_entity_gui(entity)
				_clear_hover_entity()

	elif event.is_action_pressed("right_click") and not has_placeable_blueprint:
		if cell_is_occupied and is_close_to_player:
			_deconstruct(global_mouse_position, cellv)

	elif event is InputEventMouseMotion:
		if cellv != _current_deconstruct_location:
			_abort_deconstruct()

		if has_placeable_blueprint:
			_move_blueprint_in_world(cellv)
		else:
			_update_hover(cellv)

	elif event.is_action_pressed("rotate_blueprint") and has_placeable_blueprint:
		_gui.blueprint.rotate_blueprint()

	elif event.is_action_pressed("drop") and _gui.blueprint and is_close_to_player:
		if is_on_ground:
			_drop_entity(_gui.blueprint, global_mouse_position)
			_gui.blueprint = null

	elif event.is_action_pressed("sample") and not _gui.blueprint:
		_sample_entity_at(world_to_map(global_mouse_position))


func _process(_delta: float) -> void:
	var has_placeable_blueprint: bool = _gui.blueprint and _gui.blueprint.placeable
	if (
		has_placeable_blueprint
		and (
			Input.is_action_pressed("left")
			or Input.is_action_pressed("right")
			or Input.is_action_pressed("down")
			or Input.is_action_pressed("up")
		)
	):
		_move_blueprint_in_world(world_to_map(get_global_mouse_position()))


func setup(simulation: Simulation, flat_entities: Node2D, gui: Control, ground: TileMap, player: KinematicBody2D) -> void:
	_gui = gui
	_simulation = simulation
	_flat_entities = flat_entities
	_ground = ground
	_player = player

	var existing_entities := flat_entities.get_children()
	for child in get_children():
		if child is Entity:
			existing_entities.push_back(child)

	for entity in existing_entities:
		_simulation.place_entity(entity, world_to_map(entity.global_position))


# Sets the sprite for a given wire
func _replace_wire(wire: Node2D, directions: int) -> void:
	wire.sprite.region_rect = WireBlueprint.get_region_for_direction(directions)


func _move_blueprint_in_world(cellv: Vector2) -> void:
	_gui.blueprint.make_world()
	_gui.blueprint.global_position = get_viewport_transform().xform(
		map_to_world(cellv) + POSITION_OFFSET
	)
	
	var is_close_to_player := (
		get_global_mouse_position().distance_to(_player.global_position) < MAXIMUM_WORK_DISTANCE
	)
	
	var is_on_ground: bool = _ground.get_cellv(cellv) == 0

	if not _simulation.is_cell_occupied(cellv) and is_close_to_player and is_on_ground:
		_gui.blueprint.modulate = Color.white
	else:
		_gui.blueprint.modulate = Color.red

	if Library.get_filename_from(_gui.blueprint) == "Wire":
		_gui.blueprint.set_sprite_for_direction(_get_powered_neighbors(cellv))


# Gets neighbors that are in the power groups around the given cell
func _get_powered_neighbors(cellv: Vector2) -> int:
	var direction := 0

	for neighbor in Types.NEIGHBORS.keys():
		var key: Vector2 = cellv + Types.NEIGHBORS[neighbor]

		if _simulation.is_cell_occupied(key):
			var entity: Node = _simulation.get_entity_at(key)

			if (
				entity.is_in_group(Types.POWER_MOVERS)
				or entity.is_in_group(Types.POWER_RECEIVERS)
				or entity.is_in_group(Types.POWER_SOURCES)
			):
				direction |= neighbor

	return direction


# Finds all wires and replaces them so they point towards powered entities
func _update_neighboring_flat_entities(cellv: Vector2) -> void:
	for neighbor in Types.NEIGHBORS.keys():
		var key: Vector2 = cellv + Types.NEIGHBORS[neighbor]
		var object = _simulation.get_entity_at(key)

		if object and object is WireEntity:
			var tile_directions := _get_powered_neighbors(key)
			_replace_wire(object, tile_directions)


# Places an entity or wire and informs the simulation
func _place_entity(cellv: Vector2) -> void:
	var blueprint: BlueprintEntity = _gui.blueprint
	
	var new_entity: Node2D = Library.entities[Library.get_filename_from(blueprint)].instance()

	if Library.get_filename_from(blueprint) == "Wire":
		var directions := _get_powered_neighbors(cellv)
		_flat_entities.add_child(new_entity)
		new_entity.sprite.region_rect = WireBlueprint.get_region_for_direction(directions)
	else:
		add_child(new_entity)

	new_entity.global_position = map_to_world(cellv) + POSITION_OFFSET

	_simulation.place_entity(new_entity, cellv)
	new_entity._setup(blueprint)

	if blueprint.stack_count == 1:
		_gui.destroy_blueprint()
	else:
		blueprint.stack_count -= 1
		_gui.update_label()


func _drop_entity(entity: BlueprintEntity, location: Vector2) -> void:
	if entity.get_parent():
		entity.get_parent().remove_child(entity)

	var ground_entity := GroundEntityScene.instance()
	add_child(ground_entity)
	ground_entity.setup(entity, location)


func _deconstruct(event_position: Vector2, cellv: Vector2) -> void:
	var entity := _simulation.get_entity_at(cellv)
	var blueprint: BlueprintEntity = _gui.blueprint

	if (
		not entity.deconstruct_filter.empty()
		and (
			not blueprint
			or not Library.get_filename_from(blueprint) in entity.deconstruct_filter
		)
	):
		return

	var deconstruct_bar: TextureProgress = _gui.deconstruct_bar

	deconstruct_bar.rect_global_position = get_viewport_transform().xform(event_position) + POSITION_OFFSET
	deconstruct_bar.show()

	var modifier := 1.0
	if Library.get_filename_from(blueprint).find("Crude") != -1:
		modifier = 10.0

	_deconstruct_tween.interpolate_property(deconstruct_bar, "value", 0, 100, DECONSTRUCT_TIME * modifier)
	_deconstruct_tween.start()

	Log.log_error(_deconstruct_timer.connect("timeout", self, "_finish_deconstruct", [cellv], CONNECT_ONESHOT), "Entity Placer")
	_deconstruct_timer.start(DECONSTRUCT_TIME * modifier)
	_current_deconstruct_location = cellv


func _finish_deconstruct(cellv: Vector2) -> void:
	var entity := _simulation.get_entity_at(cellv)
	var entity_name := Library.get_filename_from(entity)
	var location := map_to_world(cellv)

	if Library.blueprints.has(entity_name):
		var Blueprint: PackedScene = Library.blueprints[entity_name]

		for _i in entity.pickup_count:
			_drop_entity(Blueprint.instance(), location)

	if entity.is_in_group(Types.GUI_ENTITIES):
		var inventories: Array = _gui.find_inventory_bars_in(_gui.get_gui_component_from(entity))

		var inventory_items := []
		for inventory in inventories:
			inventory_items += inventory.get_inventory()

		for item in inventory_items:
			_drop_entity(item, location)

	_simulation.remove_entity(cellv)
	_update_neighboring_flat_entities(cellv)
	_gui.deconstruct_bar.hide()
	Events.emit_signal("hovered_over_entity", null)


func _abort_deconstruct() -> void:
	if _deconstruct_timer.is_connected("timeout", self, "_finish_deconstruct"):
		_deconstruct_timer.disconnect("timeout", self, "_finish_deconstruct")
	_deconstruct_timer.stop()
	_gui.deconstruct_bar.hide()


func _update_hover(cellv: Vector2) -> void:
	var is_close_to_player := (
		get_global_mouse_position().distance_to(_simulation.player.global_position)
		< MAXIMUM_WORK_DISTANCE
	)

	if _simulation.is_cell_occupied(cellv) and is_close_to_player:
		_hover_entity(cellv)
	else:
		_clear_hover_entity()


func _hover_entity(cellv: Vector2) -> void:
	_clear_hover_entity()
	var entity: Node2D = _simulation.get_entity_at(cellv)
	entity.toggle_outline(true)
	_last_hovered = entity
	Events.emit_signal("hovered_over_entity", entity)


func _clear_hover_entity() -> void:
	if _last_hovered:
		_last_hovered.toggle_outline(false)
		_last_hovered = null
		Events.emit_signal("hovered_over_entity", null)


func _sample_entity_at(cellv: Vector2) -> void:
	var entity: Node = _simulation.get_entity_at(cellv)
	if not entity:
		return

	var inventories_with: Array = _gui.find_panels_with(Library.get_filename_from(entity))
	if inventories_with.empty():
		return

	var input := InputEventMouseButton.new()
	input.button_index = BUTTON_LEFT
	input.pressed = true
	inventories_with.front()._gui_input(input)
