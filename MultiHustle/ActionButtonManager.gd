extends Node

onready var action_buttons_scene = preload("res://ui/ActionSelector/ActionButtons.tscn")
var main
var bottombar

var vbox_container_left
var vbox_container_right
var custom_data_left:Dictionary
var custom_data_right:Dictionary
var action_buttons_left:Dictionary = {}
var action_buttons_right:Dictionary = {}
var active_buttons_left
var active_buttons_left_index:int
var active_buttons_right
var active_buttons_right_index:int

var last_active = {}

func init_actionbuttons()->void:
	var has_exclusions = Network.multiplayer_active
	var left_buttons
	var right_buttons
	if action_buttons_left.has(1) && is_instance_valid(action_buttons_left[1]):
		left_buttons = action_buttons_left[1]
	else:
		left_buttons = main.ui_layer.p1_action_buttons
		action_buttons_left[1] = left_buttons
	if action_buttons_right.has(2) && is_instance_valid(action_buttons_right[2]):
		right_buttons = action_buttons_right[2]
	else:
		right_buttons = main.ui_layer.p2_action_buttons
		action_buttons_right[2] = right_buttons
	custom_data_left = get_custom_data(left_buttons)
	custom_data_right = get_custom_data(right_buttons)

	reset_buttons(false, has_exclusions)
	reset_buttons(true, has_exclusions)

	var game = Global.current_game
	for id in game.players.keys():
		if !has_exclusions:
			setup_buttons(id, false)
		setup_buttons(id, true)
		if !last_active.has(id) or !is_instance_valid(last_active[id]):
			last_active[id] = action_buttons_right[id]

	set_active_buttons(1, false)
	set_active_buttons(2, true)
	# TODO - Replace this with some real logic
	for buttons in action_buttons_left.values():
		buttons.opposite_buttons = active_buttons_right
	for buttons in action_buttons_right.values():
		buttons.opposite_buttons = active_buttons_left

func setup_buttons(id:int, is_right:bool):
	var action_buttons
	var group
	if !is_right:
		group = action_buttons_left
	else:
		group = action_buttons_right

	if !group.has(id):
		action_buttons = action_buttons_scene.instance()
		if !is_right:
			var new_owner = set_custom_data(action_buttons, custom_data_left)
			vbox_container_left.add_child(action_buttons)
			action_buttons.owner = new_owner
		else:
			var new_owner = set_custom_data(action_buttons, custom_data_right)
			vbox_container_right.add_child(action_buttons)
			action_buttons.owner = new_owner
		action_buttons.connect("visibility_changed", bottombar, "_on_action_buttons_visibility_changed")
		action_buttons.connect("action_clicked", main, "on_action_clicked", [id])
		group[id] = action_buttons
	else:
		action_buttons = group[id]

	action_buttons.init(Global.current_game, id)
	action_buttons.hide()
	return action_buttons

func reset_buttons(is_right:bool, has_exclusions:bool)->void:
	var group
	if !is_right:
		group = action_buttons_left
	else:
		group = action_buttons_right
	for index in group.keys():
		var action_buttons = group[index]
		if !is_instance_valid(action_buttons):
			group.erase(index)
			continue
		elif !is_instance_valid(action_buttons.fighter):
			group.erase(index)
			action_buttons.queue_free()
			continue

		if has_exclusions:
			if check_index_match(index, 1, is_right):
				action_buttons.reset()
			else:
				group.erase(index)
				action_buttons.queue_free()
		else:
			action_buttons.reset()

func check_index_match(index:int, check:int, is_exclude:bool)->bool:
	if !is_exclude:
		return index == check
	else:
		return index != check

func set_active_buttons(id:int, is_right:bool):
	var old_buttons
	var active_buttons
	var old_valid
	if !is_right:
		old_buttons = active_buttons_left
		active_buttons = action_buttons_left[id]
		if active_buttons == old_buttons:
			return
		old_valid = is_instance_valid(old_buttons)

		if old_valid: old_buttons.name = "P1ActionButtons"+str(active_buttons_left_index)

		active_buttons = action_buttons_left[id]
		active_buttons_left_index = id
		main.ui_layer.p1_action_buttons = active_buttons
		active_buttons.name = "P1ActionButtons"
		active_buttons.unique_name_in_owner = true
		# Appears to be redundant
		#active_buttons.connect("action_clicked", main, "on_action_clicked", [1])
		active_buttons_left = active_buttons
		active_buttons.show()

		if old_valid: old_buttons.hide()
	else:
		old_buttons = active_buttons_right
		active_buttons = action_buttons_right[id]
		if active_buttons == old_buttons:
			return
		old_valid = is_instance_valid(old_buttons)

		if old_valid: old_buttons.name = "P2ActionButtons"+str(active_buttons_right_index)

		active_buttons = action_buttons_right[id]
		active_buttons_right_index = id
		main.ui_layer.p2_action_buttons = active_buttons
		active_buttons.name = "P2ActionButtons"
		active_buttons.unique_name_in_owner = true
		# Appears to be redundant
		#active_buttons.connect("action_clicked", main, "on_action_clicked", [2])
		active_buttons_right = active_buttons
		active_buttons.show()

		if old_valid: old_buttons.hide()
	last_active[id] = active_buttons
	return active_buttons

func get_custom_data(obj)->Dictionary:
	return {
		"owner":obj.owner,
		"player_id":obj.player_id,
		"anchor_right":obj.anchor_right,
		"anchor_bottom":obj.anchor_bottom,
		"margin_top":obj.margin_top,
		"margin_right":obj.margin_right,
		"margin_bottom":obj.margin_bottom,
		"rect_position":obj.rect_position,
		"rect_size":obj.rect_size,
		"rect_min_size":obj.rect_min_size,
		"size_flags_horizontal":obj.size_flags_horizontal
	}

func set_custom_data(obj, dic:Dictionary):
	obj.owner = dic["owner"]
	obj.player_id = dic["player_id"]
	obj.anchor_right = dic["anchor_right"]
	obj.anchor_bottom = dic["anchor_bottom"]
	obj.margin_top = dic["margin_top"]
	obj.margin_right = dic["margin_right"]
	obj.margin_bottom = dic["margin_bottom"]
	obj.rect_position = dic["rect_position"]
	obj.rect_size = dic["rect_size"]
	obj.rect_min_size = dic["rect_min_size"]
	obj.size_flags_horizontal = dic["size_flags_horizontal"]
	return dic["owner"]
