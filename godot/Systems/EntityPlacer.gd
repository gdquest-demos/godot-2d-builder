# Handles user input and places entities, controls blueprints, and controls how they react.
extends TileMap


const NEIGHBORS := [
	{"direction": Types.Direction.RIGHT, "cellv": Vector2(1, 0)},
	{"direction": Types.Direction.DOWN, "cellv": Vector2(0, 1)},
	{"direction": Types.Direction.LEFT, "cellv": Vector2(-1, 0)},
	{"direction": Types.Direction.UP, "cellv": Vector2(0, -1)}
]


# Temporary hard coded values, until inventory/quickbar system
export var StirlingEngine: PackedScene
export var Slab: PackedScene
export var Wire: PackedScene
export var Battery: PackedScene

var drag_preview: Control

var last_hovered: Node2D = null

onready var wires := get_node("../../Wires")
onready var deconstruct_timer := $Timer
onready var deconstruct_indicator := $TextureProgress
onready var deconstruct_tween := $Tween


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		deconstruct_timer.stop()
		deconstruct_indicator.hide()
	
	if event is InputEventMouseButton and event.pressed:
		var cellv := world_to_map(event.position)
		
		# Place blueprinted entities
		if drag_preview.blueprint and event.button_index == BUTTON_LEFT:
			if not owner.is_cell_occupied(cellv):
				if drag_preview.blueprint.id == "wire":
					place_entity(cellv, get_powered_neighbors(cellv))
				else:
					place_entity(cellv)
				replace_neighbor_wires(cellv)

		# Do hold-and-release entity removal
		elif not drag_preview.blueprint and event.button_index == BUTTON_RIGHT:
			if owner.is_cell_occupied(cellv):
				deconstruct_indicator.show()
				deconstruct_indicator.rect_position = event.position
				
				deconstruct_tween.interpolate_property(deconstruct_indicator, "value", 0, 100, 0.2)
				deconstruct_tween.start()
				deconstruct_timer.start()
				yield(deconstruct_timer, "timeout")
				
				owner.remove_entity(cellv)
				replace_neighbor_wires(cellv)
				deconstruct_indicator.hide()

	elif event is InputEventMouseMotion:
		var cellv := world_to_map(event.position)
		
		# Move blueprint
		if drag_preview.blueprint:
			drag_preview.blueprint.scale = Vector2.ONE

			if not owner.is_cell_occupied(cellv):
				drag_preview.blueprint.modulate = Color.white
			else:
				drag_preview.blueprint.modulate = Color.red
			drag_preview.blueprint.global_position = map_to_world(cellv)
			if drag_preview.blueprint.id == "wire":
				drag_preview.blueprint.set_sprite_for_direction(get_powered_neighbors(cellv))
		# Hover entities
		else:
			if owner.is_cell_occupied(cellv):
				if last_hovered:
					last_hovered.modulate = Color.white
				
				var entity: Node2D = owner.get_entity_at(cellv)
				entity.modulate = Color.green
				
				last_hovered = entity
			else:
				if last_hovered:
					last_hovered.modulate = Color.white


func setup(blueprint_preview: Control) -> void:
	drag_preview = blueprint_preview


# Gets neighbors that are in the power groups around the given cell
func get_powered_neighbors(cellv: Vector2) -> int:
	var direction := 0
	
	for neighbor in NEIGHBORS:
		var key: Vector2 = cellv + neighbor.cellv
		if owner.is_cell_occupied(key):
			var entity: Node = owner.get_entity_at(key)
			if (
				entity.is_in_group(Types.POWER_MOVERS) or
				entity.is_in_group(Types.POWER_RECEIVERS) or
				entity.is_in_group(Types.POWER_SOURCES)
			):
				direction |= neighbor.direction
	
	return direction


# Finds all wires and replaces them so they point towards powered entities
func replace_neighbor_wires(cellv: Vector2) -> void:
	for neighbor in NEIGHBORS:
		var key: Vector2 = cellv + neighbor.cellv
		var object = owner.get_entity_at(key)
		if object and object is WireEntity:
			var tile_directions := get_powered_neighbors(key)
			replace_wire(object, tile_directions)


# Sets the sprite for a given wire
func replace_wire(wire: Node2D, directions: int) -> void:
	wire.sprite.region_rect = WireBlueprint.get_region_for_direction(directions)


# Places an entity or wire and informs the simulation
func place_entity(cellv: Vector2, directions := 0) -> void:
	var new_entity: Node2D = drag_preview.blueprint.Entity.instance()
	if drag_preview.blueprint.id == "wire":
		wires.add_child(new_entity)
		new_entity.sprite.region_rect = WireBlueprint.get_region_for_direction(directions)
	else:
		add_child(new_entity)

	new_entity.global_position = map_to_world(cellv)
	
	owner.place_entity(new_entity, cellv, Types.TYPE_ACTOR)
	if drag_preview.blueprint.stack_count == 1:
		drag_preview.destroy_blueprint()
	else:
		drag_preview.blueprint.stack_count -= 1
		drag_preview.update_label()



func _snap_to_map(world_position: Vector2) -> Vector2:
	return map_to_world(world_to_map(world_position))
