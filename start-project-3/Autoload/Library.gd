## Autoloaded class that associates blueprints to entities based on their filenames.
extends Node

## The path in which all entity and blueprint classes live.
const BASE_PATH := "res://Entities"

## The way the filename for a given blueprint entity ends.
## I.E. StirlingEngineBlueprint.tscn
const BLUEPRINT := "Blueprint.tscn"

## The way the filename for a given entity ends.
## I.E. StirlingEngineEntity.tscn
const ENTITY := "Entity.tscn"

## The dictionary that holds the entities keyed to their names.
var entities := {}

## The dictionary that holds blueprints keyed to their names.
var blueprints := {}


func _ready() -> void:
	_find_entities_in(BASE_PATH)


func get_entity_name_from(node: Node) -> String:
	if node:
		if node.has_method("get_entity_name"):
			return node.get_entity_name()

		var filename := node.filename.substr(node.filename.rfind("/") + 1)
		filename = filename.replace(BLUEPRINT, "").replace(ENTITY, "")

		return filename
	return ""


func _find_entities_in(path: String) -> void:
	var directory := Directory.new()
	var error := directory.open(path)

	if error != OK:
		print("Library Error: %s" % error)
		return

	error = directory.list_dir_begin(true, true)

	if error != OK:
		print("Library Error: %s" % error)
		return

	var filename := directory.get_next()

	while not filename.empty():
		if directory.current_is_dir():
			_find_entities_in("%s/%s" % [directory.get_current_dir(), filename])
		else:
			if filename.ends_with(BLUEPRINT):
				blueprints[filename.replace(BLUEPRINT, "")] = load(
					"%s/%s" % [directory.get_current_dir(), filename]
				)
			if filename.ends_with(ENTITY):
				entities[filename.replace(ENTITY, "")] = load(
					"%s/%s" % [directory.get_current_dir(), filename]
				)
		filename = directory.get_next()
