# Sub class of the simulation that keeps track of all entities and where they are, 
# and raises notifications when they change.
class_name EntityTracker
extends Reference


var entities := {}


func place_entity(entity, cellv: Vector2, role: int) -> void:
	if entities.has(cellv):
		return
	
	if role == Types.TYPE_ACTOR:
		entities[cellv] = {"entity": entity, "type": role}
	
	Events.emit_signal("entity_placed", entity, cellv)


func remove_entity(cellv: Vector2) -> void:
	if entities.has(cellv):
		var entity = entities[cellv]
		var _result := entities.erase(cellv)
		Events.emit_signal("entity_removed", entity, cellv)
		entity.entity.queue_free()


func is_cell_occupied(cellv: Vector2) -> bool:
	return entities.has(cellv)
