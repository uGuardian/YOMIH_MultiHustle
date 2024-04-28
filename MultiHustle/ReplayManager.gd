extends "res://ReplayManager.gd"

func init():
	.init()
	var mh_data = {}
	frames["MultiHustle"] = mh_data
	for index in Global.current_game.players:
		frames[index] = {}
		frames["emotes"][index] = {}
		mh_data[index] = {}

func frame_ids():
	var ids = .frame_ids()
	for id in frames:
		if id is int and !ids.has(id):
			ids.append(id)
	return ids

func undo(cut = true):
	if resimulating:
		return 
	var last_frame = 0
	var last_id = 1
	for id in frame_ids():
		for frame in frames[id].keys():
			if frame > last_frame:
				last_frame = frame
				last_id = id
	if cut:
		for id in frame_ids():
			frames[id].erase(last_frame)
	resimulating = true
	playback = true
	resim_tick = (last_frame - 2) if cut else - 1