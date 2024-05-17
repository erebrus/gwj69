extends Node


const CHECKPOINT_SCENE = preload("res://src/world/blocks/checkpoint_block.tscn")


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

	load_world(Globals.get_current_world_scene())
		
	world = $BaseWorld
	
	Events.card_error.connect(_on_card_error)
	Events.player_died.connect(_on_player_died)
	Events.checkpoint_requested.connect(_on_checkpoint_requested)
	Events.spawn_requested.connect(_on_spawn_requested)
	Events.level_ended.connect(_on_level_ended)
	
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
		load_world(Globals.get_current_world_scene())
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
		if Globals.get_current_world_scene():
			get_tree().reload_current_scene()
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
	#Events.tick.emit()
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
	
func _on_spawn_requested() -> void:
	if checkpoint == null:
		# TODO: should we create a checkpoint with the start-level state?
		await get_tree().process_frame #necessary to let the discard finish
		get_tree().reload_current_scene()
	else:
		checkpoint.get_parent().remove_child(checkpoint)
		load_world(Globals.get_current_world_scene())
		card_engine.set_state(checkpoint.card_engine_state)
		Globals.tilemap.set_state(checkpoint.tilemap_state)
		# TODO: add respawn card instead
		Globals.player.set_state(checkpoint.player_state)
		
		world.place_checkpoint(checkpoint)


func _on_level_ended():
	Globals.current_level_idx += 1
	var next_world := Globals.get_current_world_scene()
	if next_world:
		load_world(next_world)	
	else:
		do_game_win()
		
func do_game_win():
	Logger.info("You won!")
	get_tree().quit() #TODO do ending
	
