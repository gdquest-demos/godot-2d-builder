extends TileMapLayer

const MAXIMUM_WORK_DISTANCE := 275.0

const DECONSTRUCT_TIME := 0.3

var GroundEntityScene := preload("res://Entities/GroundItem.tscn")

var _tracker: EntityTracker

var _ground: TileMapLayer

var _player: CharacterBody2D

var _current_deconstruct_location := Vector2i.ZERO

var _flat_entities: Node2D

var _gui: Control

@onready var _deconstruct_timer := $Timer


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		_abort_deconstruct()

	var global_mouse_position := get_global_mouse_position()

	var has_placeable_blueprint: bool = _gui.blueprint and _gui.blueprint.placeable

	var is_close_to_player := (
		global_mouse_position.distance_to(_player.global_position)
		< MAXIMUM_WORK_DISTANCE
	)

	var mouses_cell_position:Vector2i = local_to_map(get_local_mouse_position())

	var cell_is_occupied := _tracker.is_cell_occupied(mouses_cell_position)

	var is_on_ground := _ground.get_cell_source_id(mouses_cell_position) == 0


	if event.is_action_pressed("left_click"):
		if has_placeable_blueprint:
			if not cell_is_occupied and is_close_to_player and is_on_ground:
				_place_entity(mouses_cell_position)
				_update_neighboring_flat_entities(mouses_cell_position)

	elif event.is_action_pressed("right_click") and not has_placeable_blueprint:
		if cell_is_occupied and is_close_to_player:
			_deconstruct(global_mouse_position, mouses_cell_position)

	elif event is InputEventMouseMotion:
		if mouses_cell_position != _current_deconstruct_location:
			_abort_deconstruct()

		if has_placeable_blueprint:
			_move_blueprint_in_world(mouses_cell_position)

	elif event.is_action_pressed("drop") and _gui.blueprint:
		if is_on_ground:
			_drop_entity(_gui.blueprint, global_mouse_position)
			_gui.blueprint = null

	elif event.is_action_pressed("rotate_blueprint") and _gui.blueprint:
		_gui.blueprint.rotate_blueprint()


func _process(_delta: float) -> void:
	var has_placeable_blueprint: bool = _gui.blueprint and _gui.blueprint.placeable
	if has_placeable_blueprint and not _gui.mouse_in_gui:
		_move_blueprint_in_world(local_to_map(get_global_mouse_position()))


func setup(
	gui: Control,
	tracker: EntityTracker,
	ground: TileMapLayer,
	flat_entities: Node2D,
	player: CharacterBody2D
) -> void:
	_gui = gui
	_tracker = tracker
	_ground = ground
	_player = player
	_flat_entities = flat_entities

	for child in get_children():
		if child is Entity:
			var map_position := local_to_map(child.position)

			_tracker.place_entity(child, map_position)


func _place_entity(cellv: Vector2) -> void:
	var entity_name := Library.get_entity_name_from(_gui.blueprint)
	var new_entity: Node2D = Library.entities[entity_name].instantiate()

	if _gui.blueprint is WireBlueprint:
		var directions := _get_powered_neighbors(cellv)
		_flat_entities.add_child(new_entity)
		WireBlueprint.set_sprite_for_direction(new_entity.sprite, directions)
	else:
		add_child(new_entity)

	new_entity.global_position = map_to_local(cellv)

	new_entity._setup(_gui.blueprint)

	_tracker.place_entity(new_entity, cellv)

	if _gui.blueprint.stack_count == 1:
		_gui.destroy_blueprint()
	else:
		_gui.blueprint.stack_count -= 1
		_gui.update_label()


func _move_blueprint_in_world(cell_source: Vector2) -> void:
	_gui.blueprint.display_as_world_entity()

	_gui.blueprint.global_position = get_viewport_transform() * map_to_local(cell_source)

	var is_close_to_player := (
		get_global_mouse_position().distance_to(_player.global_position)
		< MAXIMUM_WORK_DISTANCE
	)

	var is_on_ground: bool = _ground.get_cell_source_id(cell_source) == 0
	var cell_is_occupied := _tracker.is_cell_occupied(cell_source)

	if not cell_is_occupied and is_close_to_player and is_on_ground:
		_gui.blueprint.modulate = Color.WHITE
	else:
		_gui.blueprint.modulate = Color.RED

	if _gui.blueprint is WireBlueprint:
		WireBlueprint.set_sprite_for_direction(_gui.blueprint.get_node("Sprite2D"), _get_powered_neighbors(cell_source))


func _deconstruct(_event_position: Vector2, cell_source: Vector2) -> void:
	_deconstruct_timer.timeout.connect(_finish_deconstruct.bind(cell_source), CONNECT_ONE_SHOT)

	_deconstruct_timer.start(DECONSTRUCT_TIME)
	_current_deconstruct_location = cell_source


func _finish_deconstruct(cell_source: Vector2) -> void:
	var entity := _tracker.get_entity_at(cell_source)

	var entity_name := Library.get_entity_name_from(entity)
	var location := map_to_local(cell_source)
	if Library.blueprints.has(entity_name):
		var Blueprint: PackedScene = Library.blueprints[entity_name]


		_drop_entity(Blueprint.instantiate(), location)

	_tracker.remove_entity(cell_source)
	_update_neighboring_flat_entities(cell_source)


func _drop_entity(entity: BlueprintEntity, location: Vector2) -> void:
	var ground_entity := GroundEntityScene.instantiate()
	add_child(ground_entity)
	ground_entity.setup(entity, location)


func _abort_deconstruct() -> void:
	if _deconstruct_timer.timeout.is_connected(_finish_deconstruct):
		_deconstruct_timer.timeout.disconnect(_finish_deconstruct)
	_deconstruct_timer.stop()


func _get_powered_neighbors(cellv: Vector2) -> int:
	var direction := 0

	for neighbor in Types.NEIGHBORS.keys():
		var key: Vector2 = cellv + Types.NEIGHBORS[neighbor]

		if _tracker.is_cell_occupied(key):
			var entity: Node = _tracker.get_entity_at(key)

			if (
				entity.is_in_group(Types.POWER_MOVERS)
				or entity.is_in_group(Types.POWER_RECEIVERS)
				or entity.is_in_group(Types.POWER_SOURCES)
			):
				direction |= neighbor

	return direction


func _update_neighboring_flat_entities(cellv: Vector2) -> void:
	for neighbor in Types.NEIGHBORS.keys():
		var key: Vector2 = cellv + Types.NEIGHBORS[neighbor]
		var object = _tracker.get_entity_at(key)

		if object and object is WireEntity:
			var tile_directions := _get_powered_neighbors(key)
			WireBlueprint.set_sprite_for_direction(object.sprite, tile_directions)
