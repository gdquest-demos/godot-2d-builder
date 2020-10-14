# Sub class of the simulation that keeps track of all entities and their location
# using dictionary keys. Emits signals when entities are placed or removed.
class_name EntityTracker
extends Reference

var entities := {}
var pipes := {}


func place_entity(entity, cellv: Vector2) -> void:
	if entities.has(cellv):
		return

	entities[cellv] = {"entity": entity}

	Events.emit_signal("entity_placed", entity, cellv)


func place_pipe(entity, cellv: Vector2) -> void:
	if pipes.has(cellv):
		return
	
	pipes[cellv] = {"entity": entity}
	
	Events.emit_signal("pipe_placed", cellv)


func remove_entity(cellv: Vector2) -> void:
	if entities.has(cellv):
		var entity = entities[cellv]
		var _result := entities.erase(cellv)
		Events.emit_signal("entity_removed", entity, cellv)
		entity.entity.queue_free()


func remove_pipe(cellv: Vector2) -> void:
	if pipes.has(cellv):
		var entity = pipes[cellv]
		var _result := pipes.erase(cellv)
		Events.emit_signal("pipe_removed", cellv)
		entity.entity.queue_free()


func is_cell_occupied(cellv: Vector2) -> bool:
	return entities.has(cellv)


func is_pipe_in(cellv: Vector2) -> bool:
	return pipes.has(cellv)
