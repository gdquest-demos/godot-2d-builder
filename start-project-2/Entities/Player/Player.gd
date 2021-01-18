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
