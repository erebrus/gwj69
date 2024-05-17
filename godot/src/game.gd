extends Node


const CHECKPOINT_SCENE = preload("res://src/world/blocks/checkpoint_block.tscn")


@export var world_scene:PackedScene
@export var scale_factor:int = 2
@export var draw_cooldown:float = 2

var checkpoint: CheckPoint

@onready var sfx_err: AudioStreamPlayer = $CanvasLayer/sfx_err
@onready var card_engine: Control = $CanvasLayer/CardEngine
@onready var draw_timer: Timer = $DrawTimer
@onready var music: AudioStreamPlayer = $music

var world:World:
	set(w):
		world = w
		world.scale=Vector2.ONE*scale_factor

var debug_mode:bool = false

func _ready():
	if Globals.last_level:
		load_world(Globals.last_level)
	elif world_scene != null:
		load_world(world_scene)
		
	world = $BaseWorld
	
	Events.card_error.connect(_on_card_error)
	Events.player_died.connect(_on_player_died)
	Events.checkpoint_requested.connect(_on_checkpoint_requested)
	
	card_engine.card_drawn.connect(_on_card_drawn)
	draw_timer.wait_time = draw_cooldown
	
func load_world(scene:PackedScene):
		var old_world = get_child(0)
		remove_child(old_world)		
		old_world.queue_free()
		var new_world = scene.instantiate()
		new_world.name = "BaseWorld"
		add_child(new_world)
		move_child(new_world, 0)
		world = new_world
		Globals.last_level = world_scene	
	

func create_checkpoint():
	checkpoint = CHECKPOINT_SCENE.instantiate()
	
	checkpoint.position = Globals.tilemap.cell_top_left(Globals.player.position)
	
	checkpoint.player_state = Globals.player.get_state()
	checkpoint.card_engine_state = card_engine.get_state()
	checkpoint.tilemap_state = Globals.tilemap.get_state()
	
	world.place_checkpoint(checkpoint)
	

func restore_checkpoint():
	if checkpoint == null:
		# TODO: should we create a checkpoint with the start-level state?
		get_tree().reload_current_scene()
	else:
		checkpoint.get_parent().remove_child(checkpoint)
		load_world(Globals.last_level)
		card_engine.set_state(checkpoint.card_engine_state)
		Globals.tilemap.set_state(checkpoint.tilemap_state)
		# TODO: add respawn card instead
		Globals.player.set_state(checkpoint.player_state)
		
		world.place_checkpoint(checkpoint)
		
	
	

func _on_card_error():
	sfx_err.play()

func _process(delta: float) -> void:
	#TODO update draw cooldown label
	if Input.is_action_just_pressed("restart_level"):
		if Globals.last_level:
			restore_checkpoint()
		else:
			Logger.warn("No level to load.")
	if Input.is_action_just_pressed("debug"):
		debug_mode = not debug_mode
		if Globals.player and Globals.player_alive:
			if debug_mode:
				Globals.player.init_log()
			else:
				Globals.player.remove_log()
			


func _on_draw_timer_timeout() -> void:
	card_engine.click_draw_pile_to_draw = true
	Logger.info("Draw allowed")

func _on_card_drawn():
	if draw_cooldown:
		card_engine.click_draw_pile_to_draw = false
		Logger.info("Draw in cooldown")
		draw_timer.start()
	
func _on_player_died():
	card_engine.create_card_in_pile("The abyss will gaze back into you", CardPileUI.Piles.hand_pile)
	

func _on_music_finished() -> void:
	music.play() #not using loop, because we might want to change songs
	

func _on_checkpoint_requested() -> void:
	create_checkpoint()
	
