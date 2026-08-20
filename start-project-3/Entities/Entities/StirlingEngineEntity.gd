extends Entity

const BOOTUP_TIME := 6
const SHUTDOWN_TIME := 3

@onready var animation_player := $AnimationPlayer
@onready var shaft := $PistonShaft
@onready var power := $PowerSource


func _ready() -> void:
	animation_player.play("Work")
	var tween := create_tween()
	var tween_color := create_tween()
	var tween_power := create_tween()
	tween.tween_property(animation_player, "speed_scale", 1, BOOTUP_TIME).from(0)
	tween_color.tween_property(shaft, "modulate", Color(0.5, 1, 0.5), BOOTUP_TIME).from(Color.WHITE)
	tween_power.tween_property(power, "efficiency", 1, BOOTUP_TIME).from(0)
