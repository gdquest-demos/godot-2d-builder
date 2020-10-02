class_name WorkSystem
extends Reference

var workers := {}


func _init() -> void:
	Log.log_error(Events.connect("entity_placed", self, "_on_entity_placed"), "Work System")
	Log.log_error(Events.connect("entity_removed", self, "_on_entity_removed"), "Work System")
	Log.log_error(Events.connect("systems_ticked", self, "_on_systems_ticked"), "Work System")


func _on_systems_ticked(delta: float) -> void:
	for worker in workers.keys():
		workers[worker].work(delta)


func _on_entity_placed(entity, cellv: Vector2) -> void:
	if entity.is_in_group(Types.WORKERS):
		workers[cellv] = _get_work_component_from(entity)


func _on_entity_removed(_entity, cellv: Vector2) -> void:
	var _erased := workers.erase(cellv)


func _get_work_component_from(entity) -> WorkComponent:
	for child in entity.get_children():
		if child is WorkComponent:
			return child

	return null
