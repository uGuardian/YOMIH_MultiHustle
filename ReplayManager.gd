extends "res://ReplayManager.gd"

func init():
	.init()
	for index in Global.current_game.players:
		frames[index] = {}
		frames["emotes"][index] = {}

func frame_ids():
	var ids = .frame_ids()
	for id in frames:
		if id is int and !ids.has(id):
			ids.append(id)
	return ids
