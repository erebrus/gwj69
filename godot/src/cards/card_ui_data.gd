extends CardUIData
class_name CustomCardUIData

signal played


@export 
var description:String = ""
@export
var cost:int = 0
@export
var image_path:String = ""


func play():
	if can_play():
		Logger.info("Played %s card" % nice_name)
		_do_play()
		played.emit()
	else:
		Logger.info("Can't play %s card" % nice_name)

func can_play()->bool:
	return true

func _do_play():
	pass
