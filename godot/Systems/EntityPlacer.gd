# TileMap that handles user input and places entities in the world.
class_name EntityPlacer
extends TileMap

const POSITION_OFFSET := Vector2(0, 25)

export var GroundEntityScene: PackedScene

var gui: Control
var last_hovered: Node2D = null

var _simulation: Simulation
var _flat_entities: Node2D
var _current_deconstruct_location := Vector2(INF, INF)

onready var _deconstruct_timer := $Timer
onready var _deconstruct_indicator := $TextureProgress
onready var _deconstruct_tween := $Tween


func _unhandled_input(event: InputEvent) -> void:
	# Abort deconstruction by stopping timer if the mouse moves/clicks/releases
	# TODO: Grace period/area? Check Factorio deconstruction
	if event is InputEventMouseButton:
		_abort_deconstruct()

	var has_placeable_blueprint: bool = gui.blueprint and gui.blueprint.placeable

	# Place entities that have a placeable blue print on left button, if there is space.
	if event.is_action_pressed("left_click"):
		var cellv := world_to_map(event.position)
		if has_placeable_blueprint:
			if not _simulation.is_cell_occupied(cellv):
				if Library.get_filename_from(gui.blueprint) == "wire":
					_place_entity(cellv, _get_powered_neighbors(cellv))
				else:
					_place_entity(cellv)
				_update_neighboring_flat_entities(cellv)
		elif _simulation.is_cell_occupied(cellv):
			var entity := _simulation.get_entity_at(cellv)
			if entity.is_in_group("gui_entities"):
				gui.open_entity_gui(entity)
	# Do hold-and-release entity removal using a yielded timer. If interrupted by
	# another event, stop the timer.
	# TODO: Put removed items in inventory instead of just erasing it from existence
	elif event.is_action_pressed("right_click") and not has_placeable_blueprint:
		var cellv := world_to_map(event.position)
		if _simulation.is_cell_occupied(cellv):
			_deconstruct(event.position, cellv)
	# Move or highlight devices and blueprints.
	elif event is InputEventMouseMotion:
		var cellv := world_to_map(event.position)
		if cellv != _current_deconstruct_location:
			_abort_deconstruct()

		if has_placeable_blueprint:
			move_blueprint_in_world(cellv)
		else:
			_update_hover(cellv)
	elif event.is_action_pressed("rotate_blueprint") and has_placeable_blueprint:
		gui.blueprint.rotate_blueprint()
	elif event.is_action_pressed("drop") and gui.blueprint:
		_drop_entity(gui.blueprint, get_global_mouse_position())
		gui.blueprint = null


func setup(simulation: Simulation, flat_entities: Node2D, _gui: Control) -> void:
	gui = _gui
	_simulation = simulation
	_flat_entities = flat_entities

	var existing_entities := (
		flat_entities.get_children()
		+ get_children().slice(3, get_child_count())
	)

	for entity in existing_entities:
		_simulation.place_entity(entity, world_to_map(entity.global_position))


# Sets the sprite for a given wire
func replace_wire(wire: Node2D, directions: int) -> void:
	wire.sprite.region_rect = WireBlueprint.get_region_for_direction(directions)


func move_blueprint_in_world(cellv: Vector2) -> void:
	gui.blueprint.make_world()
	gui.blueprint.global_position = map_to_world(cellv) + POSITION_OFFSET

	if not _simulation.is_cell_occupied(cellv):
		gui.blueprint.modulate = Color.white
	else:
		gui.blueprint.modulate = Color.red

	if Library.get_filename_from(gui.blueprint) == "wire":
		gui.blueprint.set_sprite_for_direction(_get_powered_neighbors(cellv))


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
			replace_wire(object, tile_directions)


# Places an entity or wire and informs the simulation
func _place_entity(cellv: Vector2, directions := 0) -> void:
	var new_entity: Node2D = Library.entities[Library.get_filename_from(gui.blueprint)].instance()

	if Library.get_filename_from(gui.blueprint) == "wire":
		_flat_entities.add_child(new_entity)
		new_entity.sprite.region_rect = WireBlueprint.get_region_for_direction(directions)
	else:
		add_child(new_entity)

	new_entity.global_position = map_to_world(cellv) + POSITION_OFFSET

	_simulation.place_entity(new_entity, cellv)
	new_entity._setup(gui.blueprint)

	if gui.blueprint.stack_count == 1:
		gui.destroy_blueprint()
	else:
		gui.blueprint.stack_count -= 1
		gui.update_label()


func _drop_entity(entity: BlueprintEntity, location: Vector2) -> void:
	if entity.get_parent():
		entity.get_parent().remove_child(entity)
	var ground_entity := GroundEntityScene.instance()
	add_child(ground_entity)
	ground_entity.setup(entity, location)


func _deconstruct(event_position: Vector2, cellv: Vector2) -> void:
	var entity := _simulation.get_entity_at(cellv)
	if not entity.deconstruct_filter.empty() and (not gui.blueprint or not Library.get_filename_from(gui.blueprint) in entity.deconstruct_filter):
		return
	
	_deconstruct_indicator.show()
	_deconstruct_indicator.rect_position = event_position

	_deconstruct_tween.interpolate_property(_deconstruct_indicator, "value", 0, 100, 0.2)
	_deconstruct_tween.start()

	var _error := _deconstruct_timer.connect(
		"timeout", self, "_finish_deconstruct", [cellv], CONNECT_ONESHOT
	)
	_deconstruct_timer.start()
	_current_deconstruct_location = cellv


func _finish_deconstruct(cellv: Vector2) -> void:
	var entity := _simulation.get_entity_at(cellv)
	var entity_name := Library.get_filename_from(entity)

	var location := map_to_world(cellv)

	if entity and Library.blueprints.has(entity_name):
		var Blueprint: PackedScene = Library.blueprints[entity_name]

		for _i in entity.pickup_count:
			_drop_entity(Blueprint.instance(), location)

	if entity.is_in_group("gui_entities"):
		var inventories: Array = gui.find_inventory_bars_in(gui.get_gui_component_from(entity))
		var inventory_items := []
		for inventory in inventories:
			inventory_items += inventory.get_inventory()
	
		for item in inventory_items:
			_drop_entity(item, location)

	_simulation.remove_entity(cellv)
	_update_neighboring_flat_entities(cellv)
	_deconstruct_indicator.hide()


func _abort_deconstruct() -> void:
	if _deconstruct_timer.is_connected("timeout", self, "_finish_deconstruct"):
		_deconstruct_timer.disconnect("timeout", self, "_finish_deconstruct")
	_deconstruct_timer.stop()
	_deconstruct_indicator.hide()


func _update_hover(cellv: Vector2) -> void:
	if _simulation.is_cell_occupied(cellv):
		_hover_entity(cellv)
	else:
		_clear_hover_entity()


func _hover_entity(cellv: Vector2) -> void:
	_clear_hover_entity()
	var entity: Node2D = _simulation.get_entity_at(cellv)
	entity.modulate = Color.green
	last_hovered = entity


func _clear_hover_entity() -> void:
	if last_hovered:
		last_hovered.modulate = Color.white
		last_hovered = null
