extends "res://ui/HUD/HudLayer.gd"

var p1index:int = 1
var p2index:int = 2

var mh_p1_healthbar: TextureProgress;
var mh_p2_healthbar: TextureProgress;
var mh_p1_health_bar_trail: TextureProgress;
var mh_p2_health_bar_trail: TextureProgress;
var mh_p1_ghost_health_bar: TextureProgress;
var mh_p2_ghost_health_bar: TextureProgress;
var mh_p1_ghost_health_bar_trail: TextureProgress;
var mh_p2_ghost_health_bar_trail: TextureProgress;

func _ready():
	$"%P1ShowStyle".connect("toggled", self, "_on_show_style_toggled", [1])
	$"%P2ShowStyle".connect("toggled", self, "_on_show_style_toggled", [2])
	
	mh_p1_healthbar = p1_healthbar.duplicate()
	mh_p1_healthbar.name = "MH_P1HealthBar"
	mh_p1_healthbar.rect_position.x = 0
	$"%P1HealthBar".add_child(mh_p1_healthbar)
	p1_healthbar.self_modulate.a = 0
	p1_health_bar_trail.modulate.a = 0
	p1_ghost_health_bar.modulate.a = 0
	mh_p1_health_bar_trail = mh_p1_healthbar.get_node("P1HealthBarTrail")
	mh_p1_ghost_health_bar = mh_p1_healthbar.get_node("P1GhostHealthBar")
	mh_p1_ghost_health_bar_trail = mh_p1_healthbar.get_node("P1GhostHealthBar/P1GhostHealthBarTrail")
	
	mh_p2_healthbar = p2_healthbar.duplicate()
	mh_p2_healthbar.name = "MH_P2HealthBar"
	mh_p2_healthbar.rect_position.x = 0
	$"%P2HealthBar".add_child(mh_p2_healthbar)
	p2_healthbar.self_modulate.a = 0
	p2_health_bar_trail.modulate.a = 0
	p2_ghost_health_bar.modulate.a = 0
	mh_p2_health_bar_trail = mh_p2_healthbar.get_node("P2HealthBarTrail")
	mh_p2_ghost_health_bar = mh_p2_healthbar.get_node("P2GhostHealthBar")
	mh_p2_ghost_health_bar_trail = mh_p2_healthbar.get_node("P2GhostHealthBar/P2GhostHealthBarTrail")

func init(game):
	.init(game)
	
	# Reset the portrait colors so that replaying doesnt show the incorrect thing
	$"%P1Portrait".modulate = game.MultiHustle_get_color_by_index(1)
	$"%P2Portrait".self_modulate = game.MultiHustle_get_color_by_index(2)

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
	$"%P1FeintDisplay".fighter = p1
	p1_healthbar.max_value = p1.MAX_HEALTH
	p1_health_bar_trail.max_value = p1.MAX_HEALTH
	p1_health_bar_trail.value = p1.MAX_HEALTH
	p1_ghost_health_bar_trail.max_value = p1.MAX_HEALTH
	p1_ghost_health_bar_trail.value = p1.MAX_HEALTH
	p1_ghost_health_bar.max_value = p1.MAX_HEALTH
	
	mh_p1_healthbar.max_value = p1.MAX_HEALTH
	mh_p1_health_bar_trail.max_value = p1.MAX_HEALTH
	mh_p1_health_bar_trail.value = p1.MAX_HEALTH
	mh_p1_ghost_health_bar_trail.max_value = p1.MAX_HEALTH
	mh_p1_ghost_health_bar_trail.value = p1.MAX_HEALTH
	mh_p1_ghost_health_bar.max_value = p1.MAX_HEALTH
	
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
	mh_p2_ghost_health_bar_trail.max_value = p2.MAX_HEALTH
	mh_p2_ghost_health_bar_trail.value = p2.MAX_HEALTH
	
	p2_ghost_health_bar.max_value = p2.MAX_HEALTH
	mh_p2_ghost_health_bar.max_value = p2.MAX_HEALTH
	
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

# Need to store HP trails here since values from UI are unreliable
var ghost_hp_trails = {}
var hp_trails = {}

func _physics_process(_delta):
	if is_instance_valid(game):
		# Process all HP trails here first
		for index in game.players.keys():
			var plr = game.players[index]
			var trail = 0 if not index in hp_trails else hp_trails[index]
			if plr.trail_hp < trail:
				hp_trails[index] -= TRAIL_DRAIN_RATE
				if hp_trails[index] < plr.trail_hp:
					hp_trails[index] = plr.trail_hp
			else:
				hp_trails[index] = plr.trail_hp
		
		mh_p1_healthbar.value = max(p1.hp, 0)
		mh_p2_healthbar.value = max(p2.hp, 0)
		mh_p1_health_bar_trail.value = hp_trails[p1index]
		mh_p2_health_bar_trail.value = hp_trails[p2index]
		
		if is_instance_valid(game.ghost_game):
			# Process all ghost HP trails here first
			for index in game.players.keys():
				var plr = game.ghost_game.players[index]
				if plr.trail_hp < ghost_hp_trails[index]:
					ghost_hp_trails[index] -= TRAIL_DRAIN_RATE
					if ghost_hp_trails[index] < plr.trail_hp:
						ghost_hp_trails[index] = plr.trail_hp
				else:
					ghost_hp_trails[index] = plr.trail_hp
			
			# Now update ghost HP hud accordingly
			var p1_ghost = game.ghost_game.players[p1index]
			var p2_ghost = game.ghost_game.players[p2index]
			mh_p1_ghost_health_bar.value = max(p1_ghost.hp, 0)
			mh_p2_ghost_health_bar.value = max(p2_ghost.hp, 0)
			mh_p1_ghost_health_bar_trail.value = ghost_hp_trails[p1index]
			mh_p2_ghost_health_bar_trail.value = ghost_hp_trails[p2index]
		else:
			for index in game.players.keys():
				ghost_hp_trails[index] = 0
			mh_p1_ghost_health_bar.value = 0
			mh_p2_ghost_health_bar.value = 0
			mh_p1_ghost_health_bar_trail.value = 0
			mh_p2_ghost_health_bar_trail.value = 0
		
		$"%P1SuperTexture".visible = game.player_supers[p1index]
		$"%P2SuperTexture".visible = game.player_supers[p2index]
