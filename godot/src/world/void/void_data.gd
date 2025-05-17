class_name VoidData extends RefCounted

const TTL=3

var ttl:int=TTL
var area:VoidArea
var cell:Vector2i


func _init(cell:Vector2i) -> void:
	self.cell = cell

func is_active()-> bool:
	return area and area.is_active()
	
func is_expired() -> bool:
	return ttl < 1

func tick() -> void:
	ttl -= 1

#func duplicate()->VoidData:
	#var ret := VoidData.new(cell)
	#ret.area = area
	#ret.ttl= ttl
	#return ret
