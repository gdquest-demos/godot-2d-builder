extends FurnaceGUI



func update_speed(speed: float) -> void:
	if not is_inside_tree():
		yield(self, "ready")

	tween.playback_speed = speed


func setup(gui: Control) -> void:
	ore_container.setup(gui)
	output_container.setup(gui)
	output = output_container.panels[0]


func update_labels() -> void:
	ore_container.update_labels()
	output_container.update_labels()


func _find_nodes() -> void:
	ore_container = $HBoxContainer/OreBar
