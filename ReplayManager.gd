extends "res://ReplayManager.gd"

func init():
	.init()
	for index in Global.current_game.players:
		frames[index] = {}
		frames["emotes"][index] = {}
