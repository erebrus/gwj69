extends Node

@export var world_scene:PackedScene
@export var scale_factor:int = 2
@onready var sfx_err: AudioStreamPlayer = $sfx_err

var world:World:
	set(w):
		world = w
		world.scale=Vector2.ONE*scale_factor
		
func _ready():
	if world_scene != null:
		remove_child(get_child(0))
		var new_world = world_scene.instantiate()
		new_world.name = "BaseWorld"
		add_child(new_world)
		move_child(new_world, 0)
	world = $BaseWorld
	
	Events.card_error.connect(_on_card_error)

	
func _on_card_error():
	sfx_err.play()	#TODO need to set sfx
