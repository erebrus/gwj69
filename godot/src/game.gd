extends Node


const CHECKPOINT_SCENE = preload("res://src/world/blocks/checkpoint_block.tscn")
const PLAYER_SCENE = preload("res://src/player/player.tscn")
@export var card_play_cooldown_impact=1
@export var scale_factor:int = 2
@export var draw_cooldown:float = 2

var checkpoint: CheckPoint

@onready var sfx_err: AudioStreamPlayer = $CanvasLayer/sfx_err
@onready var card_engine: CardPileUI = $CanvasLayer/CardEngine
@onready var draw_timer: Timer = $DrawTimer
@onready var music: AudioStreamPlayer = $music
@onready var sfx_button: AudioStreamPlayer = $CanvasLayer/sfx_button
@onready var card_selection: SelectionUI = $"CanvasLayer/Card Selection"
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var camera_mode:= Types.CameraMode.TRACKING
var world:World:
	set(w):
		world = w
		world.scale=Vector2.ONE*scale_factor

var debug_mode:bool = false
var player_needed:= true
func _ready():

	load_world(Globals.get_current_world_scene())
	card_engine.create_card_in_pile("spawn", CardPileUI.Piles.hand_pile)
			
	world = $BaseWorld
	
	%DieButton.pressed.connect(_on_die_pressed)
	
	Events.card_error.connect(_on_card_error)
	Events.player_died.connect(_on_player_died)
	Events.checkpoint_requested.connect(_on_checkpoint_requested)
	Events.spawn_requested.connect(_on_spawn_requested)
	Events.level_ended.connect(_on_level_ended)
	Events.game_ended.connect(_on_game_ended)
	Events.end_card_collected.connect(_on_end_card_collected)
	Events.card_played.connect(_on_card_played)
	Events.global_void_expanded.connect(func(): $sfx_void.play())
	card_engine.card_drawn.connect(_on_card_drawn)
	if draw_cooldown > 0:
		draw_timer.wait_time = draw_cooldown
		draw_timer.start()
	
func load_world(scene:PackedScene):
		var old_world = get_child(0)
		remove_child(old_world)		
		old_world.queue_free()
		var new_world = scene.instantiate()
		new_world.name = "BaseWorld"
		add_child(new_world)
		move_child(new_world, 0)
		world = new_world
		player_needed = true

		
	

func create_checkpoint():
	checkpoint = CHECKPOINT_SCENE.instantiate()
	
	checkpoint.position = Globals.tilemap.cell_top_left(Globals.player.position)
	
	checkpoint.card_engine_state = card_engine.get_state()
	checkpoint.world_state = world.get_state()
	
	world.place_checkpoint(checkpoint)
	
func spawn_player():
	if player_needed:
		var player = PLAYER_SCENE.instantiate()
		player.tilemap = Globals.tilemap		
		
		if checkpoint:
			player.set_state(checkpoint.world_state.player)
		else:
			player.position = world.get_start_position()	
		world.add_child(player)
		player_needed = false
		world._on_player_respawned(player)		

func restore_checkpoint():
	if checkpoint == null:
		reload_level()
	elif checkpoint:
		checkpoint.get_parent().remove_child(checkpoint)
		load_world(Globals.get_current_world_scene())
		card_engine.set_state(checkpoint.card_engine_state)
		card_engine.create_card_in_pile("spawn", CardPileUI.Piles.hand_pile)
		world.set_state(checkpoint.world_state)
		world.place_checkpoint(checkpoint)
		return
	

func reload_level():
	if Globals.get_current_world_scene():
		await get_tree().process_frame #necessary to let the discard finish
		load_world(Globals.get_current_world_scene())
		card_engine.reset()
		card_engine.create_card_in_pile("spawn", CardPileUI.Piles.hand_pile)
	else:
		Logger.warn("No level to load.")
	

func _on_card_error():
	sfx_err.play()

func _process(delta: float) -> void:
	%TimeLabel.text = "%02.f" % draw_timer.time_left
	if Input.is_action_just_pressed("skip_intro") and world.can_skip:
		_on_level_ended()
		
	if Input.is_action_just_pressed("restart_level"):
		reload_level()
	if Input.is_action_just_pressed("debug"):
		debug_mode = not debug_mode
		if Globals.player and Globals.player_alive:
			if debug_mode:
				Globals.player.init_log()
			else:
				Globals.player.remove_log()
	if Input.is_action_just_pressed("toggle_camera"):
		toggle_camera()

func _on_draw_timer_timeout() -> void:
	card_engine.click_draw_pile_to_draw = true
	Logger.info("Draw allowed")

func _on_card_drawn():
	Events.tick.emit()
	if draw_cooldown:
		card_engine.click_draw_pile_to_draw = false
		Logger.info("Draw in cooldown")
		draw_timer.start()
	
func _on_player_died():
	await get_tree().process_frame
	restore_checkpoint()
	

func _on_music_finished() -> void:
	music.play() #not using loop, because we might want to change songs
	

func _on_checkpoint_requested() -> void:
	create_checkpoint()
	
func _on_spawn_requested() -> void:
	spawn_player()
	

func _on_end_card_collected():
	if Globals.is_last_level():
		card_engine.create_card_in_pile("end_game", CardPileUI.Piles.hand_pile)
	else:
		card_engine.create_card_in_pile("end_level", CardPileUI.Piles.hand_pile)

func _on_game_ended():	
	Logger.info("You won!")
	get_tree().quit() #TODO do ending


func _on_level_ended():
	player_needed = true
	Globals.player_alive=false
	Globals.player.queue_free()
	Globals.current_level_idx += 1
	var next_world := Globals.get_current_world_scene()
	if next_world:
		card_selection.show_card_selection()
		anim_player.play("FadeOut")
		#load_world(next_world)	
	else:
		Logger.error("Can't find world at idx:%d" % Globals.current_level_idx)


func _on_die_pressed():
	if Globals.player_alive:
		sfx_button.play()
		Events.die_requested.emit()
		

func toggle_camera():
	if not Globals.player_alive:
		return
	if camera_mode == Types.CameraMode.TRACKING:
		camera_mode = Types.CameraMode.FREE		
	else:
		camera_mode = Types.CameraMode.TRACKING
	Events.camera_toggled.emit(camera_mode)
	Logger.info("Camera mode changed to %s" % Types.CameraMode.keys()[camera_mode])

func _on_card_played(card:CardUI):
	if draw_timer.wait_time>0:
		if draw_timer.wait_time>1:
			draw_timer.wait_time -= 1
		else:
			_on_draw_timer_timeout()


func _on_card_selection_card_selected(card: CardUI) -> void:
	var next_world := Globals.get_current_world_scene()
	card_engine.reset()
	load_world(next_world)	
	anim_player.play("FadeIn")
	

