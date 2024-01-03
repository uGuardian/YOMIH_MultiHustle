extends "res://ui/SteamLobby/SteamLobby.gd"

func init():
	if SteamLobby.REMATCHING_ID != 0:
		print("MultiHustle doesn't support rematch button yet")
		SteamLobby.REMATCHING_ID = 0
	.init()
	$"%MatchList".hide()

func _on_retrieved_lobby_members(members):
	._on_retrieved_lobby_members(members)
	var script = load("res://ui/SteamLobby/LobbyUser.gd")
	for child in $"%UserList".get_children():
		var member = child.member
		child.disconnect("challenge_pressed", self, "_on_user_challenge_pressed")
		Network.ensure_script_override(child)
		#child.set_script(script)
		child.init(member)
