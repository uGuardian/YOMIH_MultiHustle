extends "res://ui/CSS/CharacterSelect.gd"

var current_player_real = current_player
var viewing_character = 1
var real_selected_styles = {}
var selected_display_data = {}
var prev_char_button
var next_char_button

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

func _ready():
	$"%P1Display".connect("style_selected", self, "_on_style_selected", [1])
	$"%P2Display".connect("style_selected", self, "_on_style_selected", [2])
	
	var btn_height = 160 if Network.has_char_loader() else 240
	
	prev_char_button = Button.new()
	prev_char_button.text = "<"
	prev_char_button.rect_position = Vector2(60, btn_height)
	prev_char_button.rect_size = Vector2(40, 12)
	prev_char_button.connect("pressed", self, "_update_viewing_char", [-1])
	add_child(prev_char_button)
	prev_char_button.hide()
	
	next_char_button = Button.new()
	next_char_button.text = ">"
	next_char_button.rect_position = Vector2(111, btn_height)
	next_char_button.rect_size = Vector2(40, 12)
	next_char_button.connect("pressed", self, "_update_viewing_char", [1])
	add_child(next_char_button)
	next_char_button.hide()

func _update_viewing_char(by):
	if current_player_real < 3: return
	viewing_character = wrapi(viewing_character + by, 1, current_player_real)
	$"%P1Display".get_node("PlayerLabel").text = "P%d" % viewing_character
	var style = null if not real_selected_styles.has(viewing_character) else real_selected_styles[viewing_character]
	var data = selected_display_data[viewing_character]
	$"%P1Display"._on_style_selected(style)
	$"%P1Display".load_character_data(data)

func _on_style_selected(style, pidx):
	if pidx == 1:
		real_selected_styles[viewing_character] = style
	else:
		real_selected_styles[current_player_real] = style

func _on_button_pressed(button):
	if singleplayer:
		._on_button_pressed(button)
		if !Network.has_char_loader():
			current_player_real = current_player_real + 1
			post_button_edit(button)
	else:
		._on_button_pressed(button)

func buffer_select(button):
	.buffer_select(button)
	current_player_real = current_player_real + 1
	post_button_edit(button)

func post_button_edit(button):
	if singleplayer:
		current_player = current_player_real
		selected_display_data[current_player - 1] = get_display_data(button)
		$"%SelectingLabel".text = "P%d SELECT YOUR CHARACTER" % current_player
		if current_player > 2:
			$"%P2Display".get_node("PlayerLabel").text = "P%d" % current_player
			prev_char_button.show()
			next_char_button.show()
			if Network.has_char_loader():
				$"%P1Display".rect_position.y = -30
		for button in buttons:
			button.disabled = false
	if not singleplayer:
		# TODO
		#Network.select_character(data, $"%P1Display".selected_style if current_player == 1 else $"%P2Display".selected_style)
		pass

func get_match_data():
	if singleplayer:
		for index in selected_characters.keys():
			var style = null if not real_selected_styles.has(index) else real_selected_styles[index]
			selected_styles[index] = style
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
