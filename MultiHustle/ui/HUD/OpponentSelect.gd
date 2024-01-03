extends "res://MultiHustle/ui/HUD/CharacterSelect.gd"

func PreConnect():
	.PreConnect()
	on_ParentChanged()

func _item_selected(index):
	._item_selected(index)
	if get_game().current_opponent_indicies[parent.activeCharIndex] != activeCharIndex:
		get_game().current_opponent_indicies[parent.activeCharIndex] = activeCharIndex
		parent.GetActionButtons().extra_updated()

func on_ParentChanged():
	ReactivateAllAlive()
	SelectIndex(get_game().current_opponent_indicies[parent.activeCharIndex])
	DeactivateChar(parent.activeCharIndex)
	DeactivateAllies()

func DeactivateAllies():
	pass
