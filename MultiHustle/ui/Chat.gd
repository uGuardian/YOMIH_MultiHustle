extends "res://ui/Chat/Chat.gd"

func process_command(message:String):
	var a = .process_command(message)
	if a: return a
	if not(Network.multiplayer_active and not SteamLobby.SPECTATING):
		if is_instance_valid(Global.current_game):
			# Technically checks player 1 and 2 twice, but I'll leave it just in case
			for v in Global.current_game.players.keys():
				if message.begins_with("/em" + str(v) + " "):
					var player = Global.current_game.get_player(v)
					if player:
						player.emote(message.split("/em" + str(v) + " ")[ - 1])
						return true
	return a
