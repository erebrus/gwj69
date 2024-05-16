extends CustomCardUIData
class_name CardCheckPoint


func can_play() -> bool:
	return Globals.player_alive


func _do_play() -> void:
	Events.checkpoint_requested.emit()
