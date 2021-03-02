## Sub class of the simulation that keeps track of all entities and their location
## using dictionary keys. Emits signals when the player places or removes entities.
class_name EntityTracker
extends Reference

## A Dictionary of entities, keyed using Vector2 tile map coordinates
var entities := {}

func place_entity(entity, cellv: Vector2) -> void:
	if entities.has(cellv):
		return

	entities[cellv] = entity
	Events.emit_signal("entity_placed", entity, cellv)


func remove_entity(cellv: Vector2) -> void:
	if not entities.has(cellv):
		return

	var entity = entities[cellv]
	var _result := entities.erase(cellv)
	Events.emit_signal("entity_removed", entity, cellv)
	entity.queue_free()


## Returns true if there is an entity at the given location
func is_cell_occupied(cellv: Vector2) -> bool:
	return entities.has(cellv)


## Returns the entity at the given location, if it exists, or null otherwise.
func get_entity_at(cellv: Vector2) -> Node2D:
	if entities.has(cellv):
		return entities[cellv]
	else:
		return null
