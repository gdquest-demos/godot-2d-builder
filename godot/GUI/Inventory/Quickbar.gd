extends InventoryBar


func _find_panels() -> void:
	for container in get_children():
		panels.push_back(container.get_child(1))
