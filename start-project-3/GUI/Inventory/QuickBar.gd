class_name QuickBar
extends InventoryBar


## Override _make_panels so we can also configure the label
func _make_panels() -> void:
	# For each slot we should have
	for i in slot_count:
		# Make a new quick-bar panel and add it as a child
		var panel := InventoryPanelScene.instance()
		add_child(panel)
		# Make sure we only add the InventoryPanel itself, as that's what
		# inventory bar expects.
		panels.append(panel.get_node("InventoryPanel"))

		# Get the current index. We use wrapi so that when it reaches 10, it becomes 0
		# as that's what the number is on the keyboard.
		var index := wrapi(i + 1, 0, 10)
		# Set the text.
		panel.get_node("Label").text = str(index)
