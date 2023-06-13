extends "res://Network.gd"

# This is a global variable for a manager
var multihustle_action_button_manager

# I might need to make proper host code for this
#func rpc_(function_name:String, arg = null, type = "remotesync"):

func _ready():
	connect("player_list_changed", self, "dump_charloader_data_to_cache", [], CONNECT_DEFERRED)
	multihustle_action_button_manager = preload("res://MultiHustle/ActionButtonManager.gd").new()
	add_child(multihustle_action_button_manager)

func turn_ready(id):
	var desync = false
	for pair in get_all_pairs(ticks):
		if pair[0] != pair[1]:
			desync = true
	if desync:
		var ticks_distinct = {}
		for id in ticks.keys:
			var tick = ticks[id]
			if !ticks_distinct.has(tick):
				ticks_distinct[tick] = []
			ticks_distinct[tick].append(id)
		var printmessage = "desync? tick: ids\n"
		var separator = ", "
		var newline = "\n"
		for tick in ticks_distinct.keys():
			printmessage += str(tick)+": "
			for id in ticks_distinct[tick]:
				printmessage += str(id) + separator
			printmessage = printmessage.trim_suffix(separator) + newline
		printmessage.trim_suffix(newline)
		print_debug(printmessage)
		return false
	
	for tick in ticks.keys():
		if !tick:
			return false
	return true

func assign_players():
	print_debug("Normal assign players called for some reason")
	.assign_players()

func assign_players_lobby(players:Dictionary):
	print("assigning players")
	if steam:
		player_id = SteamLobby.PLAYER_SIDE
		network_ids.clear()
		for index in players.keys():
			network_ids[index] = players[index]
	Network.begin_game()

func begin_game():
	SteamLobby.REMATCHING_ID = 0
	rematch_menu = false
	if is_host():
		print("starting game")
		rematch_requested = {}
		for index in network_ids.keys():
			rematch_requested[index] = false
		rpc_("open_chara_select")
		open_chara_select()
	

func pid_to_username(player_id):
		if not is_instance_valid(game):
			return ""
		if SteamLobby.SPECTATING or not network_ids.has(player_id):
			return Global.current_game.match_data.user_data["p" + str(player_id)]
		if direct_connect:
			return players[network_ids[opponent_player_id(player_id)]]
		return players[network_ids[player_id]]

func reset_action_inputs():
	# I don't like double calling but this is for compatibility
	.reset_action_inputs()
	for index in players:
		if !action_inputs.has(index):
			action_inputs[index] = {}
		var action_input = action_inputs[index]
		action_input["action"] = null
		action_input["data"] = null
		action_input["extra"] = null
		turns_ready[index] = false

func is_modded():
	return true

# Character Loader Section

var player_hashes = {}
var player_hash_to_folders = {}
var player_chars = {}
var diffs = {}

var handled_player1 = false

# Steam ID Based
var steam_oppChars_all = {}
var char_loaded = {}

func _compare_checksum_all():
	for phash in player_hashes.values():
		phash.sort()
	
	for phash_pair in get_all_pairs(player_hashes.values()):
		if phash_pair[0] != phash_pair[1]:
			return false
	return true

func set_shared_characters():
	var all_chars = steam_oppChars_all.duplicate()
	all_chars.erase(SteamHustle.STEAM_ID)
	var shared_chars = {}
	for arr in all_chars.values():
		for chara in arr:
			shared_chars[chara] = null
	var to_remove = {}
	for chara in shared_chars.keys():
		for key in all_chars:
			var chars = all_chars[key]
			if !chars.has(chara):
				shared_chars.erase(chara)
	var shared_chars_real = shared_chars.keys()
	set("steam_oppChars", shared_chars_real)
	Network.player1_chars = Network.char_mods
	Network.player2_chars = shared_chars_real

func dump_charloader_data_to_cache():
	# I'm not comfortable overriding register_player due to mismatched signatures
	if !has_char_loader():
		return
	var player_id = -1
	for id in players:
		if !player_hashes.has(id):
			player_id = id
			break
	if player_id == -1:
		print("Failed to determine id")
		return
	if !handled_player1:
		player_hashes[player_id] = get("player1_hashes")
		player_hash_to_folders[player_id] = get("player1_hash_to_folder")
		player_chars[player_id] = get("player1_chars")
		handled_player1 = true
	else:
		player_hashes[player_id] = get("player2_hashes")
		player_hash_to_folders[player_id] = get("player2_hash_to_folder")
		player_chars[player_id] = get("player2_chars")
		diffs[player_id] = get("diff")

func do_button_activate():
	if multiplayer_host:
		for loaded in char_loaded.values():
			if !loaded:
				return
	.do_button_activate()

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

func has_char_loader()->bool:
	return has_method("character_list")

func ensure_script_override(object):
	#var property_list = object.get_property_list()
	#var properties = {}
	#for property in property_list:
	#	properties[property.name] = object.get(property.name)
	object.set_script(load(object.get_script().resource_path))
	#for property in properties.keys():
	#	object.set(property, properties[property])
