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
	# Begin the search through the filesystem to find all blueprints and entities.
	_find_entities_in(BASE_PATH)


## Find out what the name of a given node is for the purpose of looking it up in
## the blueprints or entities dictionary. Returns a blank string for nodes that are
## null or do not have an associated scene.
func get_entity_name_from(node: Node) -> String:
	# If the provided node is not null
	if node:
		# First, check if it already has a provided name with an overriden function
		# `get_entity_name()`. This allows something like a TreeEntity to still drop
		# lumber even if it's called TreeEntity.
		if node.has_method("get_entity_name"):
			return node.get_entity_name()

		# If it does not have an overriden name, then take its actual scene filename,
		# which comes in the format `res://...scene.tscn`, and get only the name.
		# We find the latest `/` and get everything after that, and then remove
		# `Blueprint.tscn` and `Entity.tscn` so we get a name like our Dictionaries
		# expet.
		var filename := node.filename.substr(node.filename.rfind("/") + 1)
		filename = filename.replace(BLUEPRINT, "").replace(ENTITY, "")

		return filename
	return ""


## Recursively searches the provided dictionary and finds all files that end with
## `BLUEPRINT` or `ENTITY` and populates the `blueprints` and `entities` dictionaries
## with them.
func _find_entities_in(path: String) -> void:
	# Open a Directory object to the provided path. The Directory object lets us
	# analyze filenames.
	var directory := Directory.new()
	var error := directory.open(path)

	# If we encounter an error, it's likely because the directory does not exist.
	if error != OK:
		print("Library Error: %s" % error)
		return

	# `list_dir_begin()` prepares the directory for scanning files one at a time.
	error = directory.list_dir_begin(true, true)

	# If we encounter an error, there might be something wrong with the directory.
	if error != OK:
		print("Library Error: %s" % error)
		return

	# Get the first filename in the list
	var filename := directory.get_next()

	# `get_next()` returns an empty string when it's finished scanning. We can use
	# that to keep our loop going until we have no more files to scan.
	while not filename.empty():
		# If the current object in directory is a directory, then recursively call
		# this function to find all the files in _that_ directory.
		if directory.current_is_dir():
			_find_entities_in("%s/%s" % [directory.get_current_dir(), filename])
		else:
			# If the file ends with `Blueprint.tscn`
			if filename.ends_with(BLUEPRINT):
				# Take the entire filename (I.E. StirlingEngineBlueprint.tscn)
				# and create a string that only contains the name (StirlingEngine).
				# We use that name as the key for an entry in the dictionary.
				# The value is a PackedScene resource we load so we can instance it
				# later.
				blueprints[filename.replace(BLUEPRINT, "")] = load(
					"%s/%s" % [directory.get_current_dir(), filename]
				)
			# Do the same if the file ends with `Entity.tscn`
			if filename.ends_with(ENTITY):
				entities[filename.replace(ENTITY, "")] = load(
					"%s/%s" % [directory.get_current_dir(), filename]
				)
		# Get the next filename for Directory and repeat.
		filename = directory.get_next()
