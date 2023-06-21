extends "res://main.gd"

var player_ghost_actions = {}
var player_ghost_datas = {}
var player_ghost_extras = {}

var multiHustle_CharManager_res = preload("res://MultiHustle/CharManager.gd")
var multiHustle_CharManager
var multiHustle_UISelectors = preload("res://MultiHustle/ui/HUD/UISelectors.tscn")

func _ready():
	$"%P1ShowStyle".disconnect("toggled", self, "_on_show_style_toggled")
	$"%P2ShowStyle".disconnect("toggled", self, "_on_show_style_toggled")

func setup_game_deferred(singleplayer, data):
	game = preload("res://Game.tscn").instance()
	Network.ensure_script_override(game)
	#game.set_script(load("res://game.gd"))

	game_layer.add_child(game)

	multiHustle_CharManager = multiHustle_CharManager_res.new(self, game, $"%Afterimages")

	game.connect("simulation_continue", self, "_on_simulation_continue")
	game.connect("player_actionable", self, "_on_player_actionable")
	game.connect("playback_requested", self, "_on_playback_requested")
	game.connect("zoom_changed", self, "_on_zoom_changed")
	
	Network.game = game
	
	# This fallback will be removed next major game update
	var user_data
	var has_data = true
	if not data.has("user_data"):
		has_data = false
		user_data = {}
		data["user_data"] = user_data
	# This is the fallback
	if len(data["user_data"].keys()) <= 0:
		has_data = false
		user_data = data.user_data
	if not has_data:
		if Network.multiplayer_active:
			for index in data.selected_characters.keys():
				user_data["p"+str(index)] = Network.pid_to_username(index)
		else :
			for index in data.selected_characters.keys():
				# Removed the normal username use because... why?
				var name = data.selected_characters[index]["name"]
				# This is a handler for char_loader names
				var customPos = name.find("__")
				if customPos >= 0:
					name.erase(0, customPos+2)
				name = "P"+str(index)+": "+name
				user_data["p"+str(index)] = name
	
	if game.start_game(singleplayer, data) is bool:
		return 
	if data.has("turn_time"):
		if not Network.undo or (data.has("chess_timer") and not data.chess_timer):
			ui_layer.set_turn_time(data.turn_time, (data.has("chess_timer") and data.chess_timer))
		else :
			ui_layer.start_timers()
	ui_layer.init(game)
	hud_layer.init(game)
	MultiHustle_AddData()
	var p1 = game.get_player(1)
	var p2 = game.get_player(2)
	p1.debug_label = $"%DebugLabelP1"
	p2.debug_label = $"%DebugLabelP2"
	var p1_info_scene = p1.player_info_scene.instance()
	var p2_info_scene = p2.player_info_scene.instance()
	p1_info_scene.set_fighter(p1)
	p2_info_scene.set_fighter(p2)
	if $"%P1InfoContainer".get_child(0) is PlayerInfo:
		$"%P1InfoContainer".remove_child($"%P1InfoContainer".get_child(0))
	if $"%P2InfoContainer".get_child(0) is PlayerInfo:
		$"%P2InfoContainer".remove_child($"%P2InfoContainer".get_child(0))
	$"%P1InfoContainer".add_child(p1_info_scene)
	$"%P1InfoContainer".move_child(p1_info_scene, 0)
	$"%P2InfoContainer".add_child(p2_info_scene)
	$"%P2InfoContainer".move_child(p2_info_scene, 0)

func on_action_clicked(action, data, extra, player_id):
	player_ghost_actions[player_id] = action
	player_ghost_datas[player_id] = data
	player_ghost_extras[player_id] = extra
	match (player_id):
		1:
			p1_ghost_action = action
			p1_ghost_data = data
			p1_ghost_extra = extra
		2:
			p2_ghost_action = action
			p2_ghost_data = data
			p2_ghost_extra = extra
	start_ghost()
	$"%AdvantageLabel".text = ""
	pass

func _start_ghost():
	if is_instance_valid(ghost_game):
		_start_ghost_internal(ghost_game.needs_refresh)
	else:
		_start_ghost_internal()
	if is_instance_valid(ghost_game):
		ghost_game.needs_refresh = false

func _start_ghost_internal(isRefresh = true):
	if not $"%GhostWaitTimer".is_stopped():
		yield ($"%GhostWaitTimer", "timeout")
		return 
	if not is_instance_valid(game) || not is_instance_valid(ghost_game):
		isRefresh = false
	if !isRefresh:
		stop_ghost()
		for child in $"%GhostViewport".get_children():
			child.queue_free()
		afterimages = []
		for afterImage in multiHustle_CharManager.afterImages.values():
			afterImage.texture = null
	if not $"%GhostButton".pressed:
		return 
	if ReplayManager.playback:
		return 
	if not is_instance_valid(game):
		return 
	if not game.prediction_enabled:
		return 
	
	if !isRefresh:
		ghost_game = preload("res://Game.tscn").instance()
		Network.ensure_script_override(ghost_game)
		#ghost_game.set_script(load("res://game.gd"))
		ghost_game.is_ghost = true
		$"%GhostViewport".add_child(ghost_game)
		
		ghost_game.multiHustle_CharManager = multiHustle_CharManager
		multiHustle_CharManager.Create_GhostActions()
		
		ghost_game.start_game(true, match_data)
		ghost_game.connect("ghost_finished", self, "ghost_finished")
		ghost_game.connect("make_afterimage", self, "make_afterimage", [], CONNECT_DEFERRED)
		ghost_game.connect("ghost_my_turn", self, "ghost_my_turn", [], CONNECT_DEFERRED)
	ghost_game.ghost_speed = $"%GhostSpeed".get_speed()
	ghost_game.ghost_freeze = $"%FreezeOnMyTurn".pressed
	game.call_deferred("copy_to", ghost_game)
	game.ghost_game = ghost_game

	for index in ghost_game.players.keys():
		var player = ghost_game.get_player(index)
		player.queued_action = player_ghost_actions.get(index, null)
		player.queued_data = player_ghost_datas.get(index, null)
		player.queued_extra = player_ghost_extras.get(index, null)
		if player.queued_extra:
			player.queued_extra["Opponent"] = game.get_player(index).opponent.id
		player.is_ghost = true

	call_deferred("fix_ghost_objects", ghost_game)

func make_afterimage():
	if not $"%AfterimageButton".pressed:
		return 
	var img = $"%GhostViewport".get_texture().get_data()
	
	var img_dest = Image.new()
	img_dest.create(img.get_width(), img.get_height(), false, img.get_format())
	img_dest.blit_rect(img, Rect2(Vector2(), Vector2(img.get_width(), img.get_height())), Vector2.ZERO)
	img_dest.flip_y()
	
	var tex = ImageTexture.new()
	tex.create_from_image(img_dest)
	
	var texture_rect
	for afterImage in multiHustle_CharManager.afterImages.values():
		if afterImage.texture == null:
			texture_rect = afterImage
			break
	if texture_rect:
		texture_rect.start_position = game.camera_snap_position
		texture_rect.texture = tex

func MultiHustle_AddData():
	var uiselectors = multiHustle_UISelectors.instance()
	ui_layer.add_child(uiselectors)
	ui_layer.multiHustle_UISelectors = uiselectors
	var button_manager = Network.multihustle_action_button_manager
	button_manager.main = self
	button_manager.owner = owner
	button_manager.action_buttons_left[1] = $"%P1ActionButtons"
	button_manager.action_buttons_right[2] = $"%P2ActionButtons"
	button_manager.bottombar = $"%BottomBar"
	var all_buttons = $"%ActionButtons"
	button_manager.vbox_container_left = all_buttons.get_child(0)
	button_manager.vbox_container_right = all_buttons.get_child(1)
	button_manager.init_actionbuttons()
	uiselectors.Init(self)

func fix_ghost_objects(ghost_game_):
	var to_remove = []
	for obj_name in ghost_game_.objs_map:
		var object = ghost_game_.objs_map[obj_name]
		if !is_instance_valid(object):
			to_remove.append(obj_name)
	for obj_name in to_remove:
		ghost_game_.objs_map.erase(obj_name)
	.fix_ghost_objects(ghost_game_)

func stop_ghost():
	.stop_ghost()
	if is_instance_valid(ghost_game):
		ghost_game.queue_free()

# Character Loader Overrides

func _on_loaded_replay(match_data):
	if !Network.has_char_loader():
		._on_loaded_replay(match_data)
		return
	load_replay_chars(match_data)
	match_data["replay"] = true
	_on_match_ready(match_data)

func _on_received_spectator_match_data(data):
	if !Network.has_char_loader():
		_on_received_spectator_match_data(data)
		return
	get_node("/root/SteamLobby/LoadingSpectator/Label").text = "Spectating...\n(Loading Characters, this may take a while)"
	load_replay_chars(data)
	data["spectating"] = true
	_on_match_ready(data)

func load_replay_chars(match_data):
	var char_names = []
	for index in match_data.selected_characters.keys():
		char_names.append(match_data.selected_characters[index]["name"])
	# The original gives match data... and does nothing with it
	Network.css_instance.net_loadReplayChars([char_names])
