extends Node

#class_name MultiHustle_UISelectors

onready var selects = {1:[get_child(0), get_child(2)], 2:[get_child(1), get_child(3)]}
onready var local_char_select = selects[1][0]
var main

func Init(main):
	self.main = main
	var assigned_ids = []
	for id in selects.keys():
		var charSelect = selects[id][0]
		var oppSelect = selects[id][1]
		charSelect.parent = self
		oppSelect.parent = charSelect
		charSelect.opponentSelect = oppSelect
		if id == 1 && Network.multiplayer_active:
			charSelect.Init(main, Network.player_id)
			charSelect.hide()
			assigned_ids.append(Network.player_id)
		else:
			var new_id = id
			while assigned_ids.has(new_id):
				new_id += 1
			charSelect.Init(main, new_id)
			assigned_ids.append(new_id)
	# TODO - Make this more expandable
	selects[1][0].DeactivateChar(assigned_ids[1])
	selects[2][0].DeactivateChar(assigned_ids[0])

func DeactivateOther(selfId:int, charId:int):
	match(selfId):
		1:
			selects[2][0].DeactivateChar(charId)
		2:
			selects[1][0].DeactivateChar(charId)

func _process(delta):
	for pair in selects.values():
		for entry in pair:
			if Network.multiplayer_active && entry == local_char_select:
				continue
			if !entry.visible && main.game.game_paused:
				entry.ClearGameOver()
			entry.visible = main.game.game_paused

func GetAllActiveChars():
	var active_chars = []
	for pair in selects.values():
		var entry = pair[0]
		active_chars.append(entry.get_activeChar())
	return active_chars

func ResetGhosts():
	for index in main.game.players.keys():
		main.player_ghost_actions[index] = "Continue"
		main.player_ghost_datas[index] = null
		main.player_ghost_extras[index] = null
