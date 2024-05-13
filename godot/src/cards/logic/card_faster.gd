extends CustomCardUIData
const DURATION:float = 3.0
const FACTOR:float = 2.0
func _do_play():
	Events.speed_requested.emit(FACTOR, DURATION)
	
