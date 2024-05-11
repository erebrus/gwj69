extends CardUIData
class_name CustomCardUIData

@export 
var description:String = ""
@export
var cost:int = 0
@export
var target_type:=Types.TargetType.GLOBAL

func play():
	match target_type:
		Types.TargetType.GLOBAL:
			_do_play()
		Types.TargetType.POSITION:
			Events.request_position.emit()
		
func _do_play(target = null):
	pass
	
