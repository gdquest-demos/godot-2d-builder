# Provides print-to-file functions globally
extends Node

const ENABLED := true
const ERROR_MESSAGES := {
	1: "Failed",
	2: "Unavailable",
	3: "Unconfigured",
	4: "Unauthorized",
	5: "Parameter Range Error",
	6: "Out Of Memory",
	7: "File Not Found",
	8: "File Bad Drive",
	9: "File Bad Path",
	10: "File No Permission",
	11: "File Already In Use",
	12: "File Cant Open",
	13: "File Cant Write",
	14: "File Cant Read",
	15: "File Unrecognized",
	16: "File Corrupt",
	17: "File Missing Dependencies",
	18: "File Eof",
	19: "Cant Open",
	20: "Cant Create",
	21: "Query Failed",
	22: "Already In Use",
	23: "Locked",
	24: "Timeout",
	25: "Cant Connect",
	26: "Cant Resolve",
	27: "Connection Error",
	28: "Cant Acquire Resource",
	29: "Cant Fork",
	30: "Invalid Data",
	31: "Invalid Parameter",
	32: "Already Exists",
	33: "Does Not Exist",
	34: "Database Cant Read",
	35: "Database Cant Write",
	36: "Compilation Failed",
	37: "Method Not Found",
	38: "Link Failed",
	39: "Script Failed",
	40: "Cyclic Link",
	41: "Invalid Declaration",
	42: "Duplicate Symbol",
	43: "Parse Error",
	44: "Busy",
	45: "Skip",
	46: "Help",
	47: "Bug"
}

var file: File


func _ready() -> void:
	if ENABLED:
		file = File.new()
		var result := file.open("res://log.txt", File.WRITE_READ)

		if result == OK:
			file.seek_end()
			file.store_string("---------------\n")
		else:
			print_debug("Couldn't open log.txt file! %s" % [ERROR_MESSAGES[result]])

		var _error := connect("tree_exiting", self, "_on_tree_exiting")


func _notification(what: int) -> void:
	if what == NOTIFICATION_CRASH and file:
		file.store_string("*****GODOT CRASH*****\n")
		file.close()


func log_error(error: int, header := "") -> void:
	if ENABLED:
		if error != OK:
			var error_notification := "*****ERROR"
			if not header.empty():
				error_notification += " in %s" % header
			error_notification += "*****"

			var time := OS.get_datetime()
			file.store_string(
				(
					"%s (%s:%s:%s) %s : %s\n"
					% [
						error_notification,
						time.hour,
						time.minute,
						time.second,
						error,
						ERROR_MESSAGES[error]
					]
				)
			)


func _on_tree_exiting() -> void:
	if file:
		file.store_string("\n")
		file.close()
