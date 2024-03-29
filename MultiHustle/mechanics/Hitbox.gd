extends "res://mechanics/Hitbox.gd"

func hit(obj):
	if not obj.get("opponent") == null:
		var opponentTemp = obj.opponent
		if host.is_in_group("Fighter"):
			obj.opponent = host
		elif host.fighter_owner:
			obj.opponent = host.fighter_owner
		.hit(obj)
		obj.opponent = opponentTemp
	else:
		.hit(obj)
