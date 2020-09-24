class_name Quickbar
extends InventoryBar


func _make_panels() -> void:
	for i in slot_count:
		var panel := InventoryPanelScene.instance()
		add_child(panel)
		panels.append(panel.get_child(1))

		var index := wrapi(i + 1, 0, 10)
		panel.get_child(0).text = str(index)
