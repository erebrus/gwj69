extends Node

@export var world_scene:PackedScene
@export var scale_factor:int = 2
@onready var sfx_err: AudioStreamPlayer = $CanvasLayer/sfx_err
@onready var card_engine: Control = $CanvasLayer/CardEngine

var world:World:
	set(w):
		world = w
		world.scale=Vector2.ONE*scale_factor
		
func _ready():
	if Globals.last_level:
		load_world(Globals.last_level)
	elif world_scene != null:
		load_world(world_scene)
		
	world = $BaseWorld
	
	Events.card_error.connect(_on_card_error)

func load_world(scene:PackedScene):
		var old_world = get_child(0)
		remove_child(old_world)		
		old_world.queue_free()
		var new_world = scene.instantiate()
		new_world.name = "BaseWorld"
		add_child(new_world)
		move_child(new_world, 0)
		Globals.last_level = world_scene	
func _on_card_error():
	sfx_err.play()	#TODO need to set sfx

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart_level"):
		if Globals.last_level:
			#var state = card_engine.get_state()
			#load_world(Globals.last_level)
			#card_engine.set_state(state) #TODO use this logic to load checkpoint
			get_tree().reload_current_scene()
		else:
			Logger.warn("No level to load.")
		
