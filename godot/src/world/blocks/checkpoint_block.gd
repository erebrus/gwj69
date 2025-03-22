class_name CheckPoint extends BaseBlock

var void_cooldown:int
var card_engine_state: Dictionary
var world_state: Dictionary

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# checkpoint block should never be timed
	timed = false
	anim_player.play("Place")
	

func get_state() -> Dictionary:
	return {}
