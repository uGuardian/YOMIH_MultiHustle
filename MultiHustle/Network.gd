extends "res://cl_port/Network.gd"

# This is a global variable for a manager
var multihustle_action_button_manager

func _ready():
	connect("player_list_changed", self, "dump_charloader_data_to_cache", [], CONNECT_DEFERRED)
	multihustle_action_button_manager = preload("res://MultiHustle/ActionButtonManager.gd").new()
	add_child(multihustle_action_button_manager)

# Util Functions

func get_all_pairs(list):
	var idx = 0
	var listEnd = len(list)
	var listEndMinus = listEnd - 1
	var result = []
	for p1 in list:
		for p2 in list.slice(idx+1, listEnd):
			result.append([p1, p2])
		idx = idx + 1
		if (idx == listEndMinus):
			break
	return result

# Deprecated, base game always has it now.
func has_char_loader()->bool:
	return true

func ensure_script_override(object):
	#var property_list = object.get_property_list()
	#var properties = {}
	#for property in property_list:
	#	properties[property.name] = object.get(property.name)
	object.set_script(load(object.get_script().resource_path))
	#for property in properties.keys():
	#	object.set(property, properties[property])
