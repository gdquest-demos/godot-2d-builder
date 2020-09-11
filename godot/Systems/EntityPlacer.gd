# TileMap that handles user input and places entities in the world.
class_name EntityPlacer
extends TileMap

# Temporary hard coded values, until inventory/quickbar system
export var StirlingEngine: PackedScene
export var Slab: PackedScene
export var Wire: PackedScene
export var Battery: PackedScene

var drag_preview: Control
var last_hovered: Node2D = null

var _simulation: Simulation
var _wires: Node2D

onready var _deconstruct_timer := $Timer
onready var _deconstruct_indicator := $TextureProgress
onready var _deconstruct_tween := $Tween


func _unhandled_input(event: InputEvent) -> void:
	# Abort deconstruction by stopping timer if the mouse moves/clicks/releases
	# TODO: Grace period/area? Check Factorio deconstruction
	if event is InputEventMouse:
		_abort_deconstruct()

	var has_placeable_blueprint: bool = drag_preview.blueprint and drag_preview.blueprint.placeable

	# Place entities that have a placeable blue print on left button, if there is space.
	if event.is_action_pressed("left_click") and has_placeable_blueprint:
		var cellv := world_to_map(event.position)
		if not _simulation.is_cell_occupied(cellv):
			if drag_preview.blueprint.id == "wire":
				_place_entity(cellv, _get_powered_neighbors(cellv))
			else:
				_place_entity(cellv)
			_update_neighboring_wires(cellv)
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
		if has_placeable_blueprint:
			move_blueprint_in_world(cellv)
		else:
			_update_hover(cellv)
	elif event.is_action_pressed("rotate_blueprint") and has_placeable_blueprint:
		drag_preview.blueprint.rotate_blueprint()


func setup(simulation: Simulation, wires: Node2D, blueprint_preview: Control) -> void:
	drag_preview = blueprint_preview
	_simulation = simulation
	_wires = wires


# Sets the sprite for a given wire
func replace_wire(wire: Node2D, directions: int) -> void:
	wire.sprite.region_rect = WireBlueprint.get_region_for_direction(directions)


func move_blueprint_in_world(cellv: Vector2) -> void:
	drag_preview.blueprint.make_world()
	drag_preview.blueprint.global_position = map_to_world(cellv)

	if not _simulation.is_cell_occupied(cellv):
		drag_preview.blueprint.modulate = Color.white
	else:
		drag_preview.blueprint.modulate = Color.red

	if drag_preview.blueprint.id == "wire":
		drag_preview.blueprint.set_sprite_for_direction(_get_powered_neighbors(cellv))


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
func _update_neighboring_wires(cellv: Vector2) -> void:
	for neighbor in Types.NEIGHBORS.keys():
		var key: Vector2 = cellv + Types.NEIGHBORS[neighbor]
		var object = _simulation.get_entity_at(key)

		if object and object is WireEntity:
			var tile_directions := _get_powered_neighbors(key)
			replace_wire(object, tile_directions)


# Places an entity or wire and informs the simulation
func _place_entity(cellv: Vector2, directions := 0) -> void:
	var new_entity: Node2D = drag_preview.blueprint.Entity.instance()

	if drag_preview.blueprint.id == "wire":
		_wires.add_child(new_entity)
		new_entity.sprite.region_rect = WireBlueprint.get_region_for_direction(directions)
	else:
		add_child(new_entity)

	new_entity.global_position = map_to_world(cellv)

	_simulation.place_entity(new_entity, cellv)
	new_entity._setup(drag_preview.blueprint)

	if drag_preview.blueprint.stack_count == 1:
		drag_preview.destroy_blueprint()
	else:
		drag_preview.blueprint.stack_count -= 1
		drag_preview.update_label()


func _deconstruct(event_position: Vector2, cellv: Vector2) -> void:
	_deconstruct_indicator.show()
	_deconstruct_indicator.rect_position = event_position

	_deconstruct_tween.interpolate_property(_deconstruct_indicator, "value", 0, 100, 0.2)
	_deconstruct_tween.start()

	_deconstruct_timer.start()
	_deconstruct_timer.connect("timeout", self, "_finish_deconstruct", [cellv])


func _finish_deconstruct(cellv: Vector2) -> void:
	_simulation.remove_entity(cellv)
	_update_neighboring_wires(cellv)
	_deconstruct_indicator.hide()


func _abort_deconstruct() -> void:
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
