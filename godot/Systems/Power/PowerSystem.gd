class_name PowerSystem
extends Reference


const NEIGHBORING_MODS := [
	Vector2(1, 0),
	Vector2(0, 1),
	Vector2(-1, 0),
	Vector2(0, -1)
]


var power_grids := []
var _simulation


func _init(simulation) -> void:
	_simulation = simulation
	Events.connect("entity_placed", self, "_on_entity_placed")
	Events.connect("entity_removed", self, "_on_entity_removed")
	Events.connect("power_updated", self, "_on_power_updated")
	Events.connect("systems_ticked", self, "_on_systems_ticked")


func _add_new_grid(entity, cellv: Vector2) -> void:
	var new_grid := PowerGrid.new()
	power_grids.push_back(new_grid)
	_add_to_grid(entity, cellv, new_grid)


func _add_to_grid(entity, cellv: Vector2, grid: PowerGrid) -> void:
	grid.entities[cellv] = entity
	grid.update_grid()


func _merge_grids(grids: Array) -> PowerGrid:
	var main_grid: PowerGrid = grids[0]
	for i in range(1, power_grids.size()):
		var grid: PowerGrid = grids[i]

		for cell in grid.entities.keys():
			main_grid.entities[cell] = grid.entities[cell]

		power_grids.erase(grid)
	
	return main_grid


func _get_neighboring_grids(cellv: Vector2) -> Array:
	var neighboring_grids := {}
	for grid in power_grids:
		for mod in NEIGHBORING_MODS:
			if grid.entities.has(cellv + mod):
				neighboring_grids[grid] = grid
	
	return neighboring_grids.values()


func _on_entity_placed(entity, cellv: Vector2) -> void:
	var neighboring_grids := _get_neighboring_grids(cellv)
	
	if neighboring_grids.empty():
		_add_new_grid(entity, cellv)
	elif neighboring_grids.size() == 1:
		_add_to_grid(entity, cellv, neighboring_grids[0])
	else:
		var main_grid := _merge_grids(neighboring_grids)
		_add_to_grid(entity, cellv, main_grid)


func _on_entity_removed(entity, cellv: Vector2) -> void:
	pass


func _on_power_updated(world_position: Vector2) -> void:
	var cellv: Vector2 = _simulation.convert_to_cell(world_position)
	for grid in power_grids:
		if grid.entities.has(cellv):
			grid.update_grid()


func _on_systems_ticked(delta: float) -> void:
	for grid in power_grids:
		grid.act(delta)
