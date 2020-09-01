extends TileMap


enum Directions { N = 1, E = 2, S = 4, W = 8 }


export var StirlingEngine: PackedScene
export var Slab: PackedScene
export var Wire: PackedScene
export var Battery: PackedScene

var held_blueprint: Node2D

var wiring := false

onready var wires: TileMap = get_node("../../WireBlueprints")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		match event.scancode:
			KEY_1:
				_replace_blueprint(StirlingEngine)
			KEY_2:
				_replace_blueprint(Slab)
			KEY_3:
				_replace_blueprint(Wire)
			KEY_4:
				_replace_blueprint(Battery)
			KEY_Q:
				_clear_blueprint()
			
	if held_blueprint:
		if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
			var cellv := world_to_map(event.position)
			if not owner.is_cell_occupied(cellv):
				var new_position: Vector2 = event.position
				if wiring:
					place_wire(cellv, held_blueprint.get_direction_tile_id(get_powered_neighbors(cellv)))
				else:
					place_entity(cellv, StirlingEngine)
				replace_neighbor_wires(cellv)

		if event is InputEventMouseMotion:
			var cellv := world_to_map(event.position)
			if not owner.is_cell_occupied(cellv):
				held_blueprint.modulate = Color.white
			else:
				held_blueprint.modulate = Color.red
			held_blueprint.global_position = map_to_world(cellv)
			if wiring:
				held_blueprint.set_sprite_for_direction(get_powered_neighbors(cellv))


func get_powered_neighbors(cellv: Vector2) -> int:
	var neighbors := [
		{"direction": Directions.E, "cellv": cellv + Vector2(1, 0)},
		{"direction": Directions.S, "cellv": cellv + Vector2(0, 1)},
		{"direction": Directions.W, "cellv": cellv + Vector2(-1, 0)},
		{"direction": Directions.N, "cellv": cellv + Vector2(0, -1)}
	]
	
	var direction := 0
	
	for neighbor in neighbors:
		if wires.get_cellv(neighbor.cellv) != -1 or owner.is_cell_occupied(neighbor.cellv):
			direction |= neighbor.direction
	
	return direction


func replace_neighbor_wires(cellv: Vector2) -> void:
	var neighbors := [
		cellv + Vector2(1, 0),
		cellv + Vector2(0, 1),
		cellv + Vector2(-1, 0),
		cellv + Vector2(0, -1)
	]
	
	for neighbor in neighbors:
		if wires.get_cellv(neighbor) > -1:
			var tile_directions := get_powered_neighbors(neighbor)
			place_wire(neighbor, WireBlueprint.get_direction_tile_id(tile_directions))


func place_wire(cellv: Vector2, wire_tile: int) -> void:
	wires.set_cellv(cellv, wire_tile)
	owner.place_entity(wire_tile, cellv, Simulation.TYPE_WIRE)
	_clear_blueprint()


func place_entity(cellv: Vector2, entity: PackedScene) -> void:
	var new_entity: Node2D = held_blueprint.Entity.instance()
	add_child(new_entity)
	
	new_entity.global_position = map_to_world(cellv)
	
	owner.place_entity(new_entity, cellv, Simulation.TYPE_ACTOR)
	
	_clear_blueprint()


func _clear_blueprint() -> void:
	if held_blueprint:
		held_blueprint.queue_free()


func _set_blueprint(entity: PackedScene) -> void:
	held_blueprint = entity.instance()
	add_child(held_blueprint)
	
	var cellv := world_to_map(get_global_mouse_position())
	held_blueprint.global_position = map_to_world(cellv)
	
	wiring = entity == Wire
	if wiring:
		held_blueprint.set_sprite_for_direction(get_powered_neighbors(cellv))
	if not owner.is_cell_occupied(cellv):
		held_blueprint.modulate = Color.white
	else:
		held_blueprint.modulate = Color.red


func _replace_blueprint(entity: PackedScene) -> void:
	_clear_blueprint()
	_set_blueprint(entity)


func _snap_to_map(world_position: Vector2) -> Vector2:
	return map_to_world(world_to_map(world_position))
