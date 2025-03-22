class_name CheckPoint extends BaseBlock

var save_state: SaveState

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# checkpoint block should never be timed
	timed = false
	anim_player.play("Place")
	

func get_state() -> Dictionary:
	return {}
