extends "res://characters/BaseChar.gd"

func tick_before():
	if ReplayManager.playback:
		var input = get_playback_input()
		if input:
			queued_extra = input["extra"]
	if queued_extra and "Opponent" in queued_extra:
		var index = queued_extra["Opponent"]
		if index != null:
			var current_parent = get_parent()
			while not (current_parent is Game):
				current_parent = current_parent.get_parent()
			opponent = current_parent.get_player(index)
	.tick_before()

func hitbox_from_name(hitbox_name):
	var hitbox_props = hitbox_name.split("_")
	var obj_name = hitbox_props[0]
	var hitbox_id = int(hitbox_props[ - 1])
	var obj
	if objs_map.has(obj_name):
		obj = objs_map[obj_name]
	else:
		print_debug("obj missing from objs_map")
		return
	if obj:
		return objs_map[obj_name].hitboxes[hitbox_id]
