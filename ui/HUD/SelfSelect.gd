extends "res://MultiHustle/ui/HUD/CharacterSelect.gd"

onready var opponentSelect

func PreConnect():
	.PreConnect()
	SelectIndex(id)
	opponentSelect.Init(main, id)

func DeactivateChar(index:int):
	ReactivateAllAlive()
	.DeactivateChar(index)

func _item_selected(index):
	._item_selected(index)
	var realIndex = index+1
	if id == 1:
		Network.multihustle_action_button_manager.set_active_buttons(realIndex, false)
	else:
		Network.multihustle_action_button_manager.set_active_buttons(realIndex, true)
	InitUI(realIndex)
	ReconnectButtons(realIndex)
	parent.DeactivateOther(id, realIndex)
	opponentSelect.on_ParentChanged()

func InitUI(index:int):
	var actionButtons = GetActionButtons()
	InitHUD(index)

func ReconnectButtons(realIndex):
	# REVIEW - Why do I constantly disconnect and reconnect again?
	# var actionButtons = GetActionButtons()
	#actionButtons.disconnect("action_clicked", parent.main, "on_action_clicked")
	#actionButtons.connect("action_clicked", parent.main, "on_action_clicked", [realIndex])
	# TODO - Handle Opposite Buttons somehow
	# actionButtons.opposite_buttons
	pass

func GetActionButtons():
	match(id):
		1:
			return main.ui_layer.p1_action_buttons
		2:
			return main.ui_layer.p2_action_buttons

func InitHUD(index:int):
	match(id):
		1:
			main.hud_layer.initp1(index)
		2:
			main.hud_layer.initp2(index)

func ClearGameOver():
	var game = get_game()
	for player in game.players.values():
		if get_activeChar().game_over:
			var active_chars = parent.GetAllActiveChars()
			if !active_chars.has(player):
				SelectChar(player)
				break
	.ClearGameOver()
