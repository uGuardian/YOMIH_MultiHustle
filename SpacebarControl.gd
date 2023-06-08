# I really need to find a better way to do this
extends Button

var uilayer

func _ready():
	shortcut = preload("res://ui/ActionSelector/SelectButtonShortcut.tres")
	mouse_filter = MOUSE_FILTER_IGNORE 
	set_button_mask(0)
	set_scale(Vector2(0.001, 0.001))
	connect("pressed", uilayer, "ContinueAll")
