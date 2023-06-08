extends "res://ui/HUD/HudLayer.gd"

var p1index:int = 1
var p2index:int = 2

func _ready():
	$"%P1ShowStyle".connect("toggled", self, "_on_show_style_toggled", [1])
	$"%P2ShowStyle".connect("toggled", self, "_on_show_style_toggled", [2])

func _on_show_style_toggled(on, pidx):
	var player_id = self["p%dindex" % pidx]
	if is_instance_valid(game):
		var player = game.get_player(player_id)
		if on:
			player.reapply_style()
		else :
			player.reset_style()
			player.sprite.get_material().set_shader_param("color", game.MultiHustle_get_color_by_index(player_id))

func initp1(p1index):
	self.p1index = p1index
	p1 = game.players[p1index]
	p1_air_option_display.fighter = p1
	$"%P1Portrait".texture = p1.character_portrait
	if is_instance_valid(game):
		$"%P1Portrait".modulate = game.MultiHustle_get_color_by_index(p1index)
	p1_healthbar.max_value = p1.MAX_HEALTH
	p1_health_bar_trail.max_value = p1.MAX_HEALTH
	p1_health_bar_trail.value = p1.MAX_HEALTH
	$"%P1FeintDisplay".fighter = p1
	p1_ghost_health_bar_trail.max_value = p1.MAX_HEALTH
	p1_ghost_health_bar_trail.value = p1.MAX_HEALTH
	
	p1_ghost_health_bar.max_value = p1.MAX_HEALTH
	
	p1_super_meter.max_value = p1.MAX_SUPER_METER
	p1_burst_meter.fighter = p1

	if Network.multiplayer_active and not SteamLobby.SPECTATING and p1index == 1:
		$"%P1Username".text = Network.pid_to_username(1)
	elif game.match_data.has("user_data"):
		if game.match_data.user_data.has("p"+str(p1index)):
			$"%P1Username".text = game.match_data.user_data["p"+str(p1index)]
	
	$"%P1ShowStyle".set_pressed_no_signal(p1.is_style_active == true)

func initp2(p2index):
	self.p2index = p2index
	p2 = game.players[p2index]
	p2_air_option_display.fighter = p2
	$"%P2Portrait".texture = p2.character_portrait
	if is_instance_valid(game):
		$"%P2Portrait".self_modulate = game.MultiHustle_get_color_by_index(p2index)
	p2_healthbar.max_value = p2.MAX_HEALTH
	p2_health_bar_trail.max_value = p2.MAX_HEALTH
	p2_health_bar_trail.value = p2.MAX_HEALTH
	$"%P2FeintDisplay".fighter = p2
	p2_ghost_health_bar_trail.max_value = p2.MAX_HEALTH
	p2_ghost_health_bar_trail.value = p2.MAX_HEALTH
	
	p2_ghost_health_bar.max_value = p2.MAX_HEALTH
	
	p2_super_meter.max_value = p2.MAX_SUPER_METER
	p2_burst_meter.fighter = p2

	if Network.multiplayer_active and not SteamLobby.SPECTATING and p2index == 1:
		$"%P2Username".text = Network.pid_to_username(1)
	elif game.match_data.has("user_data"):
		if game.match_data.user_data.has("p"+str(p2index)):
			$"%P2Username".text = game.match_data.user_data["p"+str(p2index)]
	
	$"%P2ShowStyle".set_pressed_no_signal(p2.is_style_active == true)

func reinit(p1index:int, p2index:int):
	initp1(p1index)
	initp2(p2index)

func _physics_process(_delta):
	if is_instance_valid(game):
		$"%P1SuperTexture".visible = game.player_supers[p1index]
		$"%P2SuperTexture".visible = game.player_supers[p2index]
