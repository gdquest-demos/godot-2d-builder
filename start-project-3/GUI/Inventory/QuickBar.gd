class_name QuickBar
extends InventoryBar


func _make_panels() -> void:
	for i in slot_count:
		var panel := InventoryPanelScene.instance()
		add_child(panel)
		panels.append(panel.get_node("InventoryPanel"))

		var index := wrapi(i + 1, 0, 10)
		panel.get_node("Label").text = str(index)
