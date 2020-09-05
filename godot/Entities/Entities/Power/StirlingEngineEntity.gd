# TODO: Give inventory, require fuel
extends StaticBody2D


onready var animation_player := $AnimationPlayer
onready var tween := $Tween
onready var shaft := $PistonShaft


func _ready() -> void:
	animation_player.play("Work")
	tween.interpolate_property(animation_player, "playback_speed", 0, 1, 6)
	tween.interpolate_property($PowerSource, "efficiency", 0, 1, 6)
	tween.interpolate_property(shaft, "modulate", shaft.modulate, Color(0.5, 1, 0.5), 6)
	tween.start()
	yield(tween, "tween_all_completed")
	$Particles2D.emitting = true
