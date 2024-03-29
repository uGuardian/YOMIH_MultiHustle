extends "res://modloader/MLMainHook.gd"

const incompat_list = [
	"platform_library"
]

func _ready():
	MH_addIncompatList()

func MH_addIncompatList():
	var mod_w_missing = ModLoader.mods_w_missing_depend
	var list = addContainer("MHModIncompatibleContainer", "MultiHustle Incompatibilities")
	var close = generateButton("Close")
	close.connect("pressed", self, "MH_modmissing_closebutton_pressed")
	list.get_node("VBoxContainer").get_node("TitleBar").get_node("Title").add_child(close)
	var hasIncompat = false
	var top_label = Label.new()
	top_label.text = "MultiHustle is currently incompatible with:\n"
	list.list_container.add_child(top_label)
	for mod in ModLoader.active_mods:
		if incompat_list.has(mod[1].name):
			hasIncompat = true
			var label = Label.new()
			label.text = mod[1].friendly_name
			list.list_container.add_child(label)
	if hasIncompat:
		$"%MainMenu".get_node("MHModIncompatibleContainer").show()
	else:
		$"%MainMenu".get_node("MHModIncompatibleContainer").queue_free()

func MH_modmissing_closebutton_pressed():
	$"%MainMenu".get_node("MHModIncompatibleContainer").queue_free()
