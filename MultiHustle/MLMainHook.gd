extends "res://modloader/MLMainHook.gd"

var hasIncompat = false

const testedVersion = "1.9.0-steam"

const incompat_list = [
	"platform_library"
]

func _ready():
	# Check shouldn't be neccecary, but just to make sure
	if not Global.VERSION.match("*MH-*"):
		Global.VERSION += " MH-" + ModLoader._readMetadata("res://MultiHustle/_metadata")["version"]
	MH_addWarningMessage()

func MH_addWarningMessage():
	var list = addContainer("MHModIncompatibleContainer", "MultiHustle Incompatibilities")
	var close = generateButton("Close")
	close.connect("pressed", self, "MH_modmissing_closebutton_pressed")
	list.get_node("VBoxContainer").get_node("TitleBar").get_node("Title").add_child(close)
	MH_checkVersionCompatibility(list.list_container)
	MH_addIncompatList(list.list_container)
	if hasIncompat:
		$"%MainMenu".get_node("MHModIncompatibleContainer").show()
	else:
		$"%MainMenu".get_node("MHModIncompatibleContainer").queue_free()

func MH_checkVersionCompatibility(list_container):
	var top_label = Label.new()
	top_label.text = "MultiHustle is currently built for game version:\n%s\n\n" % testedVersion
	list_container.add_child(top_label)
	if testedVersion in Global.VERSION:
		top_label.queue_free()
	else:
		hasIncompat = true

func MH_addIncompatList(list_container):
	var modIncompat = false
	var top_label = Label.new()
	top_label.text = "MultiHustle is currently incompatible with:\n"
	list_container.add_child(top_label)
	for mod in ModLoader.active_mods:
		if incompat_list.has(mod[1].name):
			hasIncompat = true
			modIncompat = true
			var label = Label.new()
			label.text = mod[1].friendly_name
			list_container.add_child(label)
	if !modIncompat:
		top_label.queue_free()

func MH_modmissing_closebutton_pressed():
	$"%MainMenu".get_node("MHModIncompatibleContainer").queue_free()
