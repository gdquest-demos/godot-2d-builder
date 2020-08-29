class_name EntityTracker
extends Reference


enum Types { ACTOR, WIRE }

var entities := {}


func place_entity(entity, cellv: Vector2, role: int) -> void:
	if entities.has(cellv):
		return
	
	entities[cellv] = {"entity": entity, "type": role}
	
	Events.emit_signal("entity_placed", entity, cellv)


func remove_entity(cellv: Vector2) -> void:
	if entities.has(cellv):
		var entity = entities[cellv]
		entities.erase(cellv)
		Events.emit_signal("entity_removed", entity, cellv)


func is_cell_occupied(cellv: Vector2) -> bool:
	return entities.has(cellv)
