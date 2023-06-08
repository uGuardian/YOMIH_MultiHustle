extends "res://characters/states/ThrowState.gd"

func _release():
	var opponentTemp = host.opponent.opponent
	if host.is_in_group("Fighter"):
		host.opponent.opponent = host
	elif host.fighter_owner:
		host.opponent.opponent = host.fighter_owner
	._release()
	host.opponent.opponent = opponentTemp
