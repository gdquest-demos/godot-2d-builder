extends VBoxContainer


## Forwards the call to `setup()` to the inventory panel
func setup(gui: Control) -> void:
	$InventoryPanel.setup(gui)
