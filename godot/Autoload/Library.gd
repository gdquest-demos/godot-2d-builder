extends Node

const BLUEPRINTS_PATH := "res://Entities/Blueprints/"
const BLUEPRINT := "Blueprint.tscn"
const ENTITIES_PATH := "res://Entities/Entities/"
const ENTITY := "Entity.tscn"

var entities := {}
var blueprints := {}


func _ready() -> void:
	_find_entities_in("res://Entities")


func get_entity_name_from(node: Node) -> String:
	if node:
		if node.has_method("get_entity_name"):
			return node.get_entity_name()
		var filename := node.filename.substr(node.filename.rfind("/") + 1).replace(BLUEPRINT, "").replace(
			ENTITY, ""
		)

		return filename
	return ""


func is_valid_filter(filters: Array, types: String) -> bool:
	if filters.empty() or types in filters:
		return true

	if filters.has("Fuels") and Recipes.Fuels.has(types):
		return true

	return false


func _find_entities_in(path: String) -> void:
	var directory := Directory.new()
	var error := directory.open(path)

	if error != OK:
		Log.log_error(error, "Library")
		return

	error = directory.list_dir_begin(true, true)
	if error != OK:
		Log.log_error(error, "Library")
		return

	var filename := directory.get_next()
	while not filename.empty():
		if directory.current_is_dir():
			_find_entities_in("%s/%s" % [directory.get_current_dir(), filename])
		else:
			if filename.rfind(BLUEPRINT) != -1:
				blueprints[filename.substr(0, filename.rfind(BLUEPRINT))] = load(
					"%s/%s" % [directory.get_current_dir(), filename]
				)
			if filename.rfind(ENTITY) != -1:
				entities[filename.substr(0, filename.rfind(ENTITY))] = load(
					"%s/%s" % [directory.get_current_dir(), filename]
				)
		filename = directory.get_next()
