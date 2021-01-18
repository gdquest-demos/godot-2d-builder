extends TileMap

## Distance from the player when the mouse stops being able to place/interact
const MAXIMUM_WORK_DISTANCE := 275.0

## When using world_to_map or map_to_world, TileMap reports values from the 
## top left corner of the tile. In isometric perspective, it's the top corner
## from the middle. Since we want our entities to be in the middle of the tile,
## we must add an offset to any world position that come from the map that is
## half the vertical height of our tiles.
const POSITION_OFFSET := Vector2(0,25)

## Base time in seconds it takes to deconstruct an item.
const DECONSTRUCT_TIME := 0.3

## TEMPORARY variable to hold the active blueprint.
## For testing/development purposes, we hold it here until we build the inventory.
var _blueprint: BlueprintEntity

## The simulation's tracker, so we don't put entities on top of other entities
var _tracker: EntityTracker

## The ground tiles. We can check the position we're trying to put an entity down on
## to see if there is ground to put an entity on.
var _ground: TileMap

## The player entity. We can use it to check distance from the mouse to prevent
## the player from interacting with things that are too far away.
var _player: KinematicBody2D

## Variable to keep track of the current deconstruction target. If the mouse moves
## and the cell it targets is different than this one, we know the user moved off
## the cell and we should abort.
var _current_deconstruct_location := Vector2.ZERO

var _flat_entities: YSort

## TEMPORARY variables to contain references to entities and blueprint scenes
## It is split in two: blueprints keyed by their names, and entities keyed by their blueprints
onready var Library := {
	"StirlingEngine": preload("res://Entities/Blueprints/StirlingEngineBlueprint.tscn").instance(),
	"Wire": preload("res://Entities/Blueprints/WireBlueprint.tscn").instance(),
	"Battery": preload("res://Entities/Blueprints/BatteryBlueprint.tscn").instance()
}

onready var _deconstruct_timer := $Timer


func _ready() -> void:
	# Use the existing blueprint to act as a key for the entity scene, so we can instance
	# entities using the blueprint.
	Library[Library.StirlingEngine] = preload("res://Entities/Entities/StirlingEngineEntity.tscn")
	Library[Library.Wire] = preload("res://Entities/Entities/WireEntity.tscn")
	Library[Library.Battery] = preload("res://Entities/Entities/BatteryEntity.tscn")


## Since we are temporarily instancing blueprints for the library until we have
## an inventory system, we must clean up the blueprints we add here.
func _exit_tree() -> void:
	Library.StirlingEngine.queue_free()
	Library.Wire.queue_free()
	Library.Battery.queue_free()


func _unhandled_input(event: InputEvent) -> void:
	# If the user releases or clicks a button, they are no longer holding down
	# the right mouse button onto the target cell, so we can safely abort.
	if event is InputEventMouseButton:
		_abort_deconstruct()

	# Get the mouse position in world coordinates relative to world entities.
	# event.global_position and event.position return mouse positions relative
	# to the screen, but we have a camera that can move around the world.
	var global_mouse_position := get_global_mouse_position()
	
	# A conditional that indicates whether we have a blueprint in hand and that
	# the blueprint can be placed in the world.
	var has_placeable_blueprint: bool = _blueprint and _blueprint.placeable

	# Conditional to cmpare the position the mouse is pointing at to the player
	# and check the distance between the two as 'close' or not to the player.
	var is_close_to_player := (
		global_mouse_position.distance_to(_player.global_position)
		< MAXIMUM_WORK_DISTANCE
	)
	
	# The mouse positioned compared to integer map coordinates using the TileMap.
	var cellv := world_to_map(global_mouse_position)
	
	# Checks whether an entity exists at that map coordinate or not, to not
	# add entities on top of entities.
	var cell_is_occupied := _tracker.is_cell_occupied(cellv)
	
	# Checks whether there is a ground tile underneath the current map coordinate.
	# We don't want to place entities out in the air.
	var is_on_ground := _ground.get_cellv(cellv) == 0

	# When left clicking
	if event.is_action_pressed("left_click"):
		# And we have a blueprint we can place
		if has_placeable_blueprint:
			# And all conditions are valid
			if not cell_is_occupied and is_close_to_player and is_on_ground:
				# Place the entity at map coordinates for mouse
				_place_entity(cellv)
				_update_neighboring_flat_entities(cellv)

	# When right clicking
	elif event.is_action_pressed("right_click") and not has_placeable_blueprint:
		# Onto a tile within range that has an entity in it
		if cell_is_occupied and is_close_to_player:
			# Remove the resulting entity
			_deconstruct(global_mouse_position, cellv)

	# If the mouse moved and we have a blueprint in hand
	elif event is InputEventMouseMotion:
		# If the mouse moves and slips off the target tile, then we can safely abort
		# the deconstruction process.
		if cellv != _current_deconstruct_location:
			_abort_deconstruct()
		
		if has_placeable_blueprint:
			# Update the blueprint ghost so it follows the mouse cursor.
			_move_blueprint_in_world(cellv)

	# When the drop button is pressed and we are holding a blueprint, we normally
	# drop the entity as a dropable entity that the player can pick up.
	# For testing/development purposes, it clears the blueprint from the active slot.
	elif event.is_action_pressed("drop") and _blueprint:
		remove_child(_blueprint)
		_blueprint = null
	
	elif event.is_action_pressed("rotate_blueprint") and _blueprint:
		_blueprint.rotate_blueprint()
	
	# We put our quickbar actions for testing/development purposes and hardcode
	# them to specific entities. In the case of quickbar 1, that's the engine.
	elif event.is_action_pressed("quickbar_1"):
		if _blueprint:
			remove_child(_blueprint)
		_blueprint = Library.StirlingEngine
		add_child(_blueprint)
		_move_blueprint_in_world(cellv)
	elif event.is_action_pressed("quickbar_2"):
		if _blueprint:
			remove_child(_blueprint)
		_blueprint = Library.Wire
		add_child(_blueprint)
		_move_blueprint_in_world(cellv)
	elif event.is_action_pressed("quickbar_3"):
		if _blueprint:
			remove_child(_blueprint)
		_blueprint = Library.Battery
		add_child(_blueprint)
		_move_blueprint_in_world(cellv)


func _process(_delta: float) -> void:
	var has_placeable_blueprint: bool = _blueprint and _blueprint.placeable
	# If we have a blueprint in hand, keep it updated and snapped to the grid
	if has_placeable_blueprint:
		_move_blueprint_in_world(world_to_map(get_global_mouse_position()))


## Sets the placer up with requisite data that it needs to function, and adds any
## pre-placed entities to the tracker.
func setup(tracker: EntityTracker, ground: TileMap, flat_entities: YSort, player: KinematicBody2D) -> void:
	_tracker = tracker
	_ground = ground
	_player = player
	_flat_entities = flat_entities

	# For each child of EntityPlacer, if it extends Entity, add it to the tracker
	# and ensure its position is snapped to the isometric grid
	for child in get_children():
		if child is Entity:
			# Get the world position of the child into map coordinates. These are
			# integer coordinates, which makes them ideal for repeatable
			# Dictionary keys, instead of the more rounding-error prone
			# floating point numbers of world coordinates
			var map_position := world_to_map(child.global_position)
			
			# Report the entity to the tracker so it is added to the dictionary.
			_tracker.place_entity(child, map_position)


## Places the entity currently inside of _blueprint in the world at the specified
## location, and informs the tracker.
func _place_entity(cellv: Vector2) -> void:
	# Use the blueprint we prepared in _ready to instance a new entity.
	var new_entity: Node2D = Library[_blueprint].instance()

	# Add it to the tilemap as a child so it gets sorted properly
	if _blueprint is WireBlueprint:
		var directions := _get_powered_neighbors(cellv)
		_flat_entities.add_child(new_entity)
		WireBlueprint.set_sprite_for_direction(new_entity.sprite, directions)
	else:
		add_child(new_entity)

	# Snap its position to the map with the center from top-left corner offset
	new_entity.global_position = map_to_world(cellv) + POSITION_OFFSET

	# Call setup on the entity
	new_entity._setup(_blueprint)

	# Inform the tracker
	_tracker.place_entity(new_entity, cellv)


## Moves the currently active blueprint in the world according to mouse movement,
## and tints the blueprint based on whether it is on a valid or invalid tile.
func _move_blueprint_in_world(cellv: Vector2) -> void:
	# Snap the blueprint's position to the mouse with an offset
	_blueprint.global_position = map_to_world(cellv) + POSITION_OFFSET

	# Determine each of the placeable conditions
	var is_close_to_player := (
		get_global_mouse_position().distance_to(_player.global_position)
		< MAXIMUM_WORK_DISTANCE
	)

	var is_on_ground: bool = _ground.get_cellv(cellv) == 0
	var cell_is_occupied := _tracker.is_cell_occupied(cellv)

	# Tint according to whether the current tile is valid or not.
	if not cell_is_occupied and is_close_to_player and is_on_ground:
		_blueprint.modulate = Color.white
	else:
		_blueprint.modulate = Color.red
	
	if _blueprint is WireBlueprint:
		WireBlueprint.set_sprite_for_direction(_blueprint.sprite, _get_powered_neighbors(cellv))


## Begin the deconstruction process at the current cell
func _deconstruct(event_position: Vector2, cellv: Vector2) -> void:
	## Connect to the timer's timeout signal. Pass in the targeted tile as a
	## mandatory argument, and make sure that the signal does not stay connected
	## using the CONNECT_ONESHOT flag. This is because each connection to this
	## signal should be unique, as we pass in the targeted tile in as an argument.
	_deconstruct_timer.connect(
		"timeout", self, "_finish_deconstruct", [cellv], CONNECT_ONESHOT
	)
	## Begin the deconstruction timer
	_deconstruct_timer.start(DECONSTRUCT_TIME)
	## Store the current targeted cell to check for when the player aborts
	_current_deconstruct_location = cellv


## Finish the deconstruction and delete the entity from the game world.
## This is the function that will drop the deconstructed entity as a pickup item,
## but for testing/development purposes, we delete the entity.
func _finish_deconstruct(cellv: Vector2) -> void:
	var entity := _tracker.get_entity_at(cellv)
	_tracker.remove_entity(cellv)
	_update_neighboring_flat_entities(cellv)


## Disconnect from the timer if connected, and stop it from continuing, to prevent
## deconstruction from continuing.
func _abort_deconstruct() -> void:
	if _deconstruct_timer.is_connected("timeout", self, "_finish_deconstruct"):
		_deconstruct_timer.disconnect("timeout", self, "_finish_deconstruct")
	_deconstruct_timer.stop()


## Returns a bit wise integer based on whether the nearby objects can carry power
func _get_powered_neighbors(cellv: Vector2) -> int:
	# Begin with a blank direction of 0
	var direction := 0

	# For each neighboring direction from the bitwise enum for neighbors
	for neighbor in Types.NEIGHBORS.keys():
		var key: Vector2 = cellv + Types.NEIGHBORS[neighbor]

		# Get the entity in that cell, if there is one.
		if _tracker.is_cell_occupied(key):
			var entity: Node = _tracker.get_entity_at(key)

			# If it's part of any of the power groups
			if (
				entity.is_in_group(Types.POWER_MOVERS)
				or entity.is_in_group(Types.POWER_RECEIVERS)
				or entity.is_in_group(Types.POWER_SOURCES)
			):
				# Combine the number with a OR operator in binary format.
				# It's the equivalent of doing +=, but | will prevent the same number
				# being added twice
				# Types.Direction.UP + Types.Direction.UP results in DOWN, which is wrong
				# Types.Direction.UP | Types.Direction.UP results in UP, which is correct.
				direction |= neighbor

	return direction


## Look at each of the neighboring tiles and updates each of them to use the
## correct graphics based on their own neighbors.
func _update_neighboring_flat_entities(cellv: Vector2) -> void:
	# For each neighboring tile
	for neighbor in Types.NEIGHBORS.keys():
		# Get the entity, if there is one
		var key: Vector2 = cellv + Types.NEIGHBORS[neighbor]
		var object = _tracker.get_entity_at(key)

		# If it is a wire, have that wire update its graphics to connect to the new
		# entity.
		if object and object is WireEntity:
			var tile_directions := _get_powered_neighbors(key)
			WireBlueprint.set_sprite_for_direction(object.sprite, tile_directions)
