extends Node


const ENABLED := true


var file: File


func _ready() -> void:
	if ENABLED:
		file = File.new()
		file.open("res://log.txt", File.WRITE)


func _exit_tree() -> void:
	if file:
		file.close()


func log_error(message: String) -> void:
	if ENABLED:
		var time := OS.get_datetime()
		file.store_line("*****ERROR***** (%s:%s:%s) %s" % [time.hour, time.minute, time.second, message])


func log_message(message: String) -> void:
	if ENABLED:
		var time := OS.get_datetime()
		file.store_line("(%s:%s:%s) %s" % [time.hour, time.minute, time.second, message])
