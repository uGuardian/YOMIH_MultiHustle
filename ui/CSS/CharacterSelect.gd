extends "res://ui/CSS/CharacterSelect.gd"

var current_player_real = current_player

func _on_network_character_selected(player_id, character, style = null):
	selected_characters[player_id] = character
	selected_styles[player_id] = style
	if Network.is_host() and player_id == Network.player_id:
		$"%GameSettingsPanelContainer".hide()
	for chara in selected_characters.values():
		if chara == null:
			return
	if Network.is_host():
		var match_data = get_match_data()
		Network.rpc_("send_match_data", match_data)
		if Network.steam:
			Network.send_match_data(match_data)

func init(singleplayer = true):
	.init(singleplayer)
	if singleplayer:
		return
	for key in Network.network_ids.keys():
		selected_characters[key] = null
		hovered_characters[key] = null
		selected_styles[key] = null

func _on_button_pressed(button):
	if singleplayer:
		._on_button_pressed(button)
		if !Network.has_char_loader():
			current_player_real = current_player_real + 1
			post_button_edit()
	else:
		._on_button_pressed(button)

func buffer_select(button):
	.buffer_select(button)
	current_player_real = current_player_real + 1
	post_button_edit()

func post_button_edit():
	if singleplayer:
		current_player = current_player_real
		$"%SelectingLabel".text = "P"+str(current_player)+" SELECT YOUR CHARACTER"
		for button in buttons:
			button.disabled = false
	if not singleplayer:
		# TODO
		#Network.select_character(data, $"%P1Display".selected_style if current_player == 1 else $"%P2Display".selected_style)
		pass

func get_match_data():
	if singleplayer:
		for index in selected_characters.keys():
			match(index):
				1:
					selected_styles[1] = $"%P1Display".selected_style
				2:
					selected_styles[2] = $"%P2Display".selected_style
				_:
					selected_styles[index] = null
	var data = {
		"singleplayer":singleplayer, 
		"selected_characters":selected_characters, 
		"selected_styles":selected_styles, 
	}
	if singleplayer or Network.is_host():
		randomize()
		data.merge({"seed":randi()})
	if SteamLobby.LOBBY_ID != 0 and SteamLobby.MATCH_SETTINGS:
		data.merge(SteamLobby.MATCH_SETTINGS)
	else :
		data.merge($"%GameSettingsPanelContainer".get_data())
	return data

onready var mhVersion = ModLoader._readMetadata("res://MultiHustle/_metadata")["version"]

func _process(delta):
	# new version code thing, handled this way because of char_loader
	var clVersion = get("clVersion")
	if clVersion != null:
		if not clVersion.match("*MH-*"):
			set("clVersion", clVersion + " MH-" + mhVersion)
	elif not Global.VERSION.match("*MH-*"):
		Global.VERSION = Global.VERSION.split("Modded")[0] + "MH-" + mhVersion

# Character Loader Overrides

func net_loadReplayChars(_replayChars):
	var second = false
	var pair = []
	var idx = 0
	var name_to_index = get("name_to_index")
	for rc in _replayChars:
		if rc != []:
			if (isCustomChar(rc[idx])):
				loadListChar(name_to_index[retro_charName(rc[idx])])
		idx += 1

func isCustomChar(_name):
	return .isCustomChar(_name)

func loadListChar(index, hideName = false):
	return .loadListChar(index, hideName)

func retro_charName(_name):
	return .retro_charName(_name)
