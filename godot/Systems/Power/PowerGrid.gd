class_name PowerGrid
extends Reference


var entities := {}

var available_power := 0


func update_grid() -> void:
	available_power = 0
	for entity in entities.values():
		var components := _find_power_component_nodes(entity)
		
		for component in components:
			if component is PowerProducer:
				available_power += component.power_per_tick
			if component is PowerConsumer:
				available_power -= component.power_per_tick
	print(available_power)


func act(delta: float) -> void:
	for entity in entities.values():
		var components := _find_power_component_nodes(entity)
		
		for component in components:
			component.act(self, delta)


func _find_power_component_nodes(parent: Node) -> Array:
	var power_components := []
	
	var parent_stack := [parent]
	
	while not parent_stack.empty():
		var current: Node = parent_stack.pop_back()

		if current is PowerComponent:
			power_components.push_back(current)

		for child in current.get_children():
			parent_stack.push_back(child)
	
	return power_components
