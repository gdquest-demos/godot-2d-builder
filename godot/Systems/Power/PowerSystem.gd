# Holds references to entities in the world, and a series of paths that go from power sources
# to power receivers. Every system tick, it sends power from the sources to the
# receivers in order.
class_name PowerSystem
extends Reference


const NEIGHBORS := {
	Types.Direction.RIGHT: Vector2.RIGHT,
	Types.Direction.DOWN: Vector2.DOWN,
	Types.Direction.LEFT: Vector2.LEFT,
	Types.Direction.UP: Vector2.UP
}


var power_sources := {}
var power_receivers := {}
var power_movers := {}

var paths := []

var power_left := 0.0
var cells_travelled := []

var receivers_provided := {}


func _init() -> void:
	var _result := Events.connect("entity_placed", self, "_on_entity_placed")
	_result = Events.connect("entity_removed", self, "_on_entity_removed")
	_result = Events.connect("systems_ticked", self, "_on_systems_ticked")


func _retrace_paths() -> void:
	paths.clear()
	
	for source in power_sources.keys():
		cells_travelled.clear()
		var path := _trace_path_from(source, [source])
		
		paths.push_back(path)


# Recursively trace a path from the source cell outwards, skipping already
# visited cells, only going through cells that has been recognized by the
# power system.
func _trace_path_from(cellv: Vector2, path: Array) -> Array:
	var new_path := path
	cells_travelled.push_back(cellv)
	
	var direction := 15
	
	if power_sources.has(cellv):
		direction = power_sources[cellv].output_direction
	
	var receivers := _find_neighbors_in(cellv, power_receivers, direction)
	for receiver in receivers:
		if not receiver in cells_travelled:
			direction = 0
			if receiver.x < cellv.x:
				direction |= Types.Direction.LEFT
			elif receiver.x > cellv.x:
				direction |= Types.Direction.RIGHT
			elif receiver.y < cellv.y:
				direction |= Types.Direction.UP
			elif receiver.y > cellv.y:
				direction |= Types.Direction.DOWN
			
			var power_receiver: PowerReceiver = power_receivers[receiver]
			if direction & Types.Direction.RIGHT != 0:
				if power_receiver.input_direction & Types.Direction.LEFT == 0:
					print(power_receiver.input_direction)
					continue
			elif direction & Types.Direction.DOWN != 0:
				if power_receiver.input_direction & Types.Direction.UP == 0:
					continue
			elif direction & Types.Direction.LEFT != 0:
				if power_receiver.input_direction & Types.Direction.RIGHT == 0:
					continue
			elif direction & Types.Direction.UP != 0:
				if power_receiver.input_direction & Types.Direction.DOWN == 0:
					continue
			new_path.push_back(receiver)
	
	var movers := _find_neighbors_in(cellv, power_movers)
	for mover in movers:
		if not mover in cells_travelled:
			new_path = _trace_path_from(mover, new_path)
	
	return new_path


func _find_neighbors_in(cellv: Vector2, collection: Dictionary, output_directions: int = 15) -> Array:
	var neighbors := []
	for neighbor in NEIGHBORS:
		if neighbor & output_directions != 0:
			var key: Vector2 = cellv + NEIGHBORS[neighbor]
			if collection.has(key):
				neighbors.push_back(key)
	
	return neighbors


func _on_systems_ticked(delta: float) -> void:
	receivers_provided.clear()
	
	for path in paths:
		var power_source: PowerSource = power_sources[path[0]]
		
		var available_power := power_source.get_effective_power()
		var power_draw := 0.0
		
		for cell in path:
			if cell == path[0]:
				continue
			
			if not power_receivers.has(cell):
				continue
			
			var power_receiver: PowerReceiver = power_receivers[cell]
			var required := power_receiver.get_effective_power()
			
			if receivers_provided.has(cell):
				var receiver_amount: float = receivers_provided[cell]
				if receiver_amount >= required:
					continue
				else:
					required -= receiver_amount
			
			power_draw += required
			
			power_receiver.emit_signal("received_power", min(available_power, required), delta)

			if not receivers_provided.has(cell):
				receivers_provided[cell] = min(available_power, required)
			else:
				receivers_provided[cell] += min(available_power, required)
			
			available_power -= required
		
		if power_draw > 0:
			power_source.emit_signal("power_updated", power_draw, delta)


func _get_power_source_from(entity: Node) -> PowerSource:
	for child in entity.get_children():
		if child is PowerSource:
			return child
	
	return null


func _get_power_receiver_from(entity: Node) -> PowerReceiver:
	for child in entity.get_children():
		if child is PowerReceiver:
			return child
	
	return null


func _on_entity_placed(entity, cellv: Vector2) -> void:
	if entity.is_in_group("power_sources"):
		power_sources[cellv] = _get_power_source_from(entity)
	if entity.is_in_group("power_receivers"):
		power_receivers[cellv] = _get_power_receiver_from(entity)
	if entity.is_in_group("power_movers"):
		power_movers[cellv] = entity
	_retrace_paths()


func _on_entity_removed(_entity, cellv: Vector2) -> void:
	var _result := power_sources.erase(cellv)
	_result = power_receivers.erase(cellv)
	_result = power_movers.erase(cellv)
	_retrace_paths()
