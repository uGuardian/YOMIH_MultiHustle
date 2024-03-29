# This class is supposed to be immutable, values should never change.
class Footprint:
	var x1:int
	var x2:int
	var y1:int
	var y2:int
	var width:int
	var height:int

	# Optional variables
	var obj:BaseObj
	var box_arr:Array
	var aabb_arr:Array

	func _init(x1, x2, y1, y2):
		self.x1 = x1
		self.x2 = x2
		self.y1 = y1
		self.y2 = y2
		self.width = x2 - x1
		self.height = y2 - y1

	static func get_collision_footprint_dic_from_obj(obj:BaseObj)->Footprint:
		var footprint = get_collision_footprint_dic_from_collision_arr(obj.get_active_hitboxes())
		footprint.obj = obj
		return footprint

	static func get_collision_footprint_dic_from_collision_arr(arr:Array)->Footprint:
		var aabbs = []
		aabbs.resize(len(arr))
		for index in len(arr):
			aabbs = arr[index].get_aabb()
		var footprint = get_collision_footprint_dic_from_aabb_dic_arr(aabbs)
		footprint.box_arr = arr
		footprint.aabb_arr = aabbs
		return footprint

	static func get_collision_footprint_dic_from_aabb_dic_arr(aabbs:Array)->Footprint:
		var x1:int = 0
		var x2:int = 0
		var y1:int = 0
		var y2:int = 0
		for aabb in aabbs:
			if aabb["x1"] < x1:
				x1 = aabb["x1"]
			if aabb["x2"] > x2:
				x2 = aabb["x2"]
			if aabb["y1"] < y1:
				y1 = aabb["y1"]
			if aabb["y2"] > y2:
				y2 = aabb["y2"]
		return Footprint.new(x1, x2, y1, y2)

	func overlaps(box:Footprint):
		if width == 0 and height == 0:
			return false
		if box.width == 0 and box.height == 0:
			return false
		return not (x1 > box.x2 or x2 < box.x1 or y1 > box.y2 or y2 < box.y1)
