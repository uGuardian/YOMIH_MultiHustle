extends OptionButton

var main
var id:int
var activeCharIndex:int
var parent

# For some reason properties are broken
#var activeChar:Fighter setget , get_activeChar
func get_activeChar():
	return get_game().players[activeCharIndex]

#var game:Game setget , get_game
func get_game():
	return Global.current_game

#var ghost_game:Game setget , get_ghost_game
func get_ghost_game():
	return get_game().ghost_game

func Init(main, id:int):
	self.main = main
	self.id = id
	var game = get_game()
	for index in game.players.keys():
		var player = game.players[index]
		add_item(GetName(index))
	PreConnect()
	self.connect("item_selected", self, "_item_selected")

func PreConnect():
	pass

func GetName(index:int):
	var name:String
	if Network.multiplayer_active:
		name = Network.pid_to_username(index)
	else:
		name = get_game().match_data.user_data["p"+str(index)]
	return name

func DeactivateChar(index:int):
	set_item_disabled(index-1, true)

func ReactivateAllAlive():
	var game = get_game()
	for index in game.players.keys():
		if !game.players[index].game_over:
			set_item_disabled(index-1, false)
		else:
			set_item_disabled(index-1, true)

func ClearGameOver():
	var game = get_game()
	for index in game.players.keys():
		if game.players[index].game_over:
			set_item_disabled(index-1, true)

func _item_selected(index):
	activeCharIndex = index+1

func SelectIndex(index:int):
	activeCharIndex = index
	select(index-1)

func SelectChar(character:Fighter):
	activeCharIndex = character.id
	select(character.id-1)
