extends "res://SteamLobby.gd"

var OPPONENT_IDS = {}

var is_syncing = false
var sync_confirms = {}

func _setup_game_vs(steam_id):
	print_debug("Normal game setup got called for some reason")
	host_game_vs_all()

func host_game_vs_all():
	if SteamHustle.STEAM_ID != LOBBY_OWNER:
		print("Only host can setup")
		return
	print("registering players")
	REMATCHING_ID = 0
	OPPONENT_IDS.clear()
	OPPONENT_IDS[1] = SteamHustle.STEAM_ID
	var idx = 1
	for member in LOBBY_MEMBERS:
		var steam_id = member.steam_id
		var status = Steam.getLobbyMemberData(LOBBY_ID, steam_id, "status")
		#if status == "ready":
		if status == "idle":
			OPPONENT_IDS[idx] = steam_id
			idx += idx + 1
		else:
			# I should probably tweak this, but for now it does this
			Steam.closeP2PSessionWithUser(steam_id)
	Network.steam_isHost = true
	#PLAYER_SIDE = 1
	#multihustle_send_start()
	# DEBUG Stuff
	multihustle_send_start()
	if len(LOBBY_MEMBERS) <= 1:
		var debug_array = Network.char_mods.duplicate()
		debug_array.remove(5)
		multihustle_receive_sync(SteamHustle.STEAM_ID, debug_array)

func _setup_game_vs_group(OPPONENT_IDS):
	if Network.has_char_loader():
		Network.set_shared_characters()
	print("starting match")
	SETTINGS_LOCKED = true
	self.OPPONENT_IDS = OPPONENT_IDS
	Network.char_loaded.clear()
	for steam_id in OPPONENT_IDS.values():
		Network.register_player_steam(steam_id)
		if steam_id == SteamHustle.STEAM_ID:
			if Network.has_char_loader():
				Network.player_chars[steam_id] = Network.steam_oppChars
		else:
			Network.char_loaded[steam_id] = false
	for index in OPPONENT_IDS.keys():
		Network.char_loaded[index] = false
		var steam_id = OPPONENT_IDS[index]
		if steam_id == SteamHustle.STEAM_ID:
			PLAYER_SIDE = index
			Steam.setLobbyMemberData(SteamLobby.LOBBY_ID, "player_id", str(index))
			break
	Network.assign_players_lobby(OPPONENT_IDS)
	Steam.setLobbyMemberData(LOBBY_ID, "status", "fighting")
	Steam.setLobbyMemberData(LOBBY_ID, "opponent_id", str(OPPONENT_ID))

# All RPCs go to everyone
func rpc_(function_name, arg):
	if OPPONENT_ID != 0:
		var data = {
			"rpc_data":{
				"func":function_name, 
				"arg":arg
			}
		}
		print("sending rpc through steam...")
		_send_P2P_Packet(0, data)

func _read_P2P_Packet_custom(readable):
	var sender = p2p_packet_sender
	if readable.has("_packetName"):
		match readable._packetName:
			"go_button_activate":
				Network.char_loaded[sender] = true
	._read_P2P_Packet_custom(readable)
	if readable.has("multihustle_start"):
		multihustle_send_sync(readable.multihustle_start)
	if readable.has("character_list"):
		multihustle_receive_sync(sender, readable.character_list)

func multihustle_send_start():
	OPPONENT_ID = LOBBY_OWNER
	var data = {
		"multihustle_start":OPPONENT_IDS,
	}
	_send_P2P_Packet(0, data)
	multihustle_send_sync(OPPONENT_IDS)

func multihustle_send_sync(OPPONENT_IDS):
	OPPONENT_ID = LOBBY_OWNER
	self.OPPONENT_IDS = OPPONENT_IDS
	for steam_id in sync_confirms.keys():
		if !OPPONENT_IDS.values().has(steam_id):
			sync_confirms.erase(steam_id)
	for steam_id in OPPONENT_IDS.values():
		if !sync_confirms.has(steam_id):
			sync_confirms[steam_id] = false
	sync_confirms[SteamHustle.STEAM_ID] = true
	is_syncing = true
	var data = {
		"steam_id":SteamHustle.STEAM_ID,
		#"char_loader_data":null
		"character_list":null
	}
	if Network.has_char_loader():
		#data["char_loader_data"] = [Network.normal_mods, Network.char_mods, Network.hash_to_folder]
		data["character_list"] = Network.char_mods
	_send_P2P_Packet(0, data)

func multihustle_receive_sync(sender, character_list):
	Network.steam_oppChars_all[sender] = character_list
	sync_confirms[sender] = true
	if is_syncing:
		for confirmation in sync_confirms.values():
			if !confirmation:
				return
		is_syncing = false
		sync_confirms.clear()
		_setup_game_vs_group(OPPONENT_IDS)
