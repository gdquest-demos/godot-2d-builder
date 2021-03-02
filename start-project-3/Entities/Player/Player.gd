extends KinematicBody2D

export var movement_speed := 200.0


func _physics_process(_delta: float) -> void:
	var direction := _get_direction()

	var _result := move_and_slide(direction * movement_speed)


func _get_direction() -> Vector2:
	return Vector2(
		(Input.get_action_strength("right") - Input.get_action_strength("left")) * 2.0,
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()


func _on_PickupRadius_area_entered(area: Area2D) -> void:
	var parent: GroundItem = area.get_parent()
	if parent:
		Events.emit_signal("entered_pickup_area", parent, self)
