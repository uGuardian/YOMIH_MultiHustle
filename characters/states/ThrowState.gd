extends "res://characters/states/ThrowState.gd"

var hit_opponents = []

# This is just to make extra sure
func _frame_0_shared():
	hit_opponents.append(host.opponent)
	._frame_0_shared()

func _release():
	for opponent in hit_opponents:
		var opponentTemp = host.opponent.opponent
		if host.is_in_group("Fighter"):
			host.opponent.opponent = host
		elif host.fighter_owner:
			host.opponent.opponent = host.fighter_owner
		._release()
		host.opponent.opponent = opponentTemp
	hit_opponents.clear()