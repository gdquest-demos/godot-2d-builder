## Sub class of the simulation that keeps track of all entities and their location
## using dictionary keys. Emits signals when the player places or removes entities.
class_name EntityTracker
extends Reference

## A Dictionary of entities, keyed using Vector2 tile map coordinates
var entities := {}

## Adds an entity to the dictionary so we can prevent other entities from taking
## the same location.
func place_entity(entity, cellv: Vector2) -> void:
	# If the cell is already taken, refuse to add it again
	if entities.has(cellv):
		return

	# Add the entity keyed by its coordinates on the map
	entities[cellv] = entity
	# Emit the signal about the new entity
	Events.emit_signal("entity_placed", entity, cellv)


## Removes an entity from the dictionary so other entities can take its place
# in its location on the map.
func remove_entity(cellv: Vector2) -> void:
	# Refuse to function if the entity does not exist
	if not entities.has(cellv):
		return

	# Get the entity, erase it from memory next frame, and emit a signal about
	# its removal.
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
