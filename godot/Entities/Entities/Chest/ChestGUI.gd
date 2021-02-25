extends BaseMachineGUI


func setup(_gui: Control) -> void:
	for inventory in $VBoxContainer.get_children():
		inventory.setup(_gui)
