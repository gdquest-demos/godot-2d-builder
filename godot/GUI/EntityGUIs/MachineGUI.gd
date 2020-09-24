extends CenterContainer

var gui_window: Control


func setup(_gui: Control) -> void:
	gui_window.get_child(0)._setup(_gui)


func set_window(window: Control) -> void:
	if not gui_window:
		gui_window = $MarginContainer/PanelContainer

	gui_window.add_child(window)
