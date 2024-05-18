class_name CheckPoint extends BaseBlock


var card_engine_state: Dictionary
var world_state: Dictionary

func _ready() -> void:
	# checkpoint block should never be timed
	timed = false
	
func get_state() -> Dictionary:
	return {}
