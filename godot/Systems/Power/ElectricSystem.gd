class_name ElectricSystem
extends Node


const POWER_MOVER_FLAG: int = (
	PowerComponent.PowerRole.POWER_MOVER |
	PowerComponent.PowerRole.POWER_STORER |
	PowerComponent.PowerRole.POWER_PROVIDER
)

var available_power := 0
var powered_cells := {}


func add_new_cell(cellv: Vector2, entity: PowerComponent) -> int:
	if powered_cells.has(cellv):
		return ERR_ALREADY_IN_USE
	
	powered_cells[cellv] = entity
	entity.connect("state_changed", self, "_update_network")
	_update_network()
	return OK


func remove_cell(cellv: Vector2) -> bool:
	var result := powered_cells.erase(cellv)
	_update_network()
	return result


func find_powered_neighbors(cellv: Vector2) -> Array:
	var neighboring_cells := [
		cellv + Vector2(1, 0),
		cellv + Vector2(0, 1),
		cellv + Vector2(-1, 0),
		cellv + Vector2(0, -1)
	]
	
	var powered_neighbors := []
	
	for cell in neighboring_cells:
		var powered_neighbor = powered_cells.get(cell)
		if powered_neighbor:
			powered_neighbors.push_back(powered_neighbor)
	
	return powered_neighbors


func _update_network() -> void:
	available_power = 0
	var consumers := []
	
	for cellv in powered_cells.keys():
		var entity: PowerComponent = powered_cells[cellv]
		
		if entity.power_role & PowerComponent.PowerRole.POWER_PROVIDER:
			available_power += entity.current_power_amount

		if entity.power_role & PowerComponent.PowerRole.POWER_CONSUMER:
			available_power -= entity.current_power_amount
			consumers.push_back(entity)
		
		var neighbors := find_powered_neighbors(cellv)
		
		for neighbor in neighbors:
			if neighbor.power_role & POWER_MOVER_FLAG:
				entity.is_powered = true
				break
	
	if available_power < 0:
		for consumer in consumers:
			consumer.is_powered = false
