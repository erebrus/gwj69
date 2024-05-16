extends CardUIData
class_name CustomCardUIData

signal played

enum Traits{ONE_USE}

@export 
var display_name:String = ""
@export 
var description:String = ""
@export
var cost:int = 0
@export
var image_path:String = ""
@export
var traits:={}

func play():
	if can_play():
		Logger.info("Played %s card" % nice_name)
		_do_play()
		played.emit()
		
	else:
		Logger.info("Can't play %s card" % nice_name)
		Events.card_error.emit()

func can_play()->bool:
	return true

func _do_play():
	pass

func has_trait(_trait:Traits)->bool:
	var key = Traits.keys()[_trait]	
	return key in traits and traits[key]

