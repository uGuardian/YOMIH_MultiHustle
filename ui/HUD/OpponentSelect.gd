extends "res://MultiHustle/ui/HUD/CharacterSelect.gd"

func PreConnect():
	.PreConnect()
	on_ParentChanged()

func _item_selected(index):
	._item_selected(index)
	#var realIndex = index-1
	get_game().current_opponent_indicies[parent.activeCharIndex] = activeCharIndex
	#var ghost_game = get_ghost_game()
	#if is_instance_valid(ghost_game):
		#ghost_game.players[parent.activeCharIndex].opponent = ghost_game.players[activeCharIndex]
	parent.parent.main.start_ghost()

func on_ParentChanged():
	ReactivateAllAlive()
	SelectChar(parent.get_activeChar().opponent)
	DeactivateChar(parent.activeCharIndex)
	DeactivateAllies()

func DeactivateAllies():
	pass
