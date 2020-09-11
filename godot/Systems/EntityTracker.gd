# Sub class of the simulation that keeps track of all entities and their location
# using dictionary keys. Emits signals when entities are placed or removed.
class_name EntityTracker
extends Reference


var entities := {}


func place_entity(entity, cellv: Vector2) -> void:
	if entities.has(cellv):
		return
	
	entities[cellv] = {"entity": entity}
	
	Events.emit_signal("entity_placed", entity, cellv)


func remove_entity(cellv: Vector2) -> void:
	if entities.has(cellv):
		var entity = entities[cellv]
		var _result := entities.erase(cellv)
		Events.emit_signal("entity_removed", entity, cellv)
		entity.entity.queue_free()


func is_cell_occupied(cellv: Vector2) -> bool:
	return entities.has(cellv)
