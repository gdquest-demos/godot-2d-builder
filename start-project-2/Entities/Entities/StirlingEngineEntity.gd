extends Entity

const BOOTUP_TIME := 6
const SHUTDOWN_TIME := 3

onready var animation_player := $AnimationPlayer
onready var tween := $Tween
onready var shaft := $PistonShaft
onready var power := $PowerSource


func _ready() -> void:
	animation_player.play("Work")
	tween.interpolate_property(animation_player, "playback_speed", 0, 1, BOOTUP_TIME)
	tween.interpolate_property(shaft, "modulate", Color.white, Color(0.5, 1, 0.5), BOOTUP_TIME)
	tween.interpolate_property(power, "efficiency", 0, 1, BOOTUP_TIME)
	tween.start()
