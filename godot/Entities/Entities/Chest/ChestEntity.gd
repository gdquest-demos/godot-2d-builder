extends Entity

onready var animation := $AnimationPlayer


func _on_GUIComponent_gui_opened() -> void:
	animation.play("Open")


func _on_GUIComponent_gui_closed() -> void:
	animation.play("Close")
