class_name Game extends Node


const CHECKPOINT_SCENE = preload("res://src/world/blocks/checkpoint_block.tscn")
const PLAYER_SCENE = preload("res://src/player/player.tscn")
@export var card_play_cooldown_impact=1
@export var scale_factor:int = 2
@export var draw_cooldown:float = 2
@export var start_void_cooldown:float = 15
@export var void_cooldown_progression=.5
@export var do_void_progression := true
@export var vertical_progression_factor := 1.0

@export var void_time_tick:=true
@export var void_card_tick:=true

var checkpoint: CheckPoint

@onready var sfx_err: AudioStreamPlayer = $CanvasLayer/sfx_err
@onready var card_engine: CardPileUI = $CanvasLayer/CardEngine
@onready var draw_timer: Timer = $DrawTimer
@onready var void_timer: Timer = $VoidTimer
@onready var sfx_button: AudioStreamPlayer = $CanvasLayer/sfx_button
@onready var card_selection: SelectionUI = $"CanvasLayer/Card Selection"
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var game_menu: Container = %GameMenu
@onready var void_cooldown = start_void_cooldown
@onready var sfx_swoosh_to_game: AudioStreamPlayer = $CanvasLayer/sfx_swoosh_to_game
@onready var sfx_swoosh_to_place: AudioStreamPlayer = $CanvasLayer/sfx_swoosh_to_place

var camera_mode:= Types.CameraMode.TRACKING
var world:World:
	set(w):
		world = w
		world.scale=Vector2.ONE*scale_factor

var debug_mode:bool = false
var player_needed:= true

func _ready():
	Globals.game = self
	
	load_world(Globals.get_current_world_scene())
	card_engine.create_card_in_pile("spawn", CardPileUI.Piles.hand_pile)
			
	world = $BaseWorld
	
	%DieButton.pressed.connect(_on_die_pressed)
	game_menu.void_toggled.connect(toggle_void_progression)
	Events.player_pause_state_changed.connect(func():%PauseButton.button_pressed = Globals.player_pause)
	Events.player_respawned.connect(_on_player_respawned)
	Events.card_error.connect(_on_card_error)
	Events.player_died.connect(_on_player_died)
	Events.checkpoint_requested.connect(_on_checkpoint_requested)
	Events.spawn_requested.connect(_on_spawn_requested)
	Events.level_ended.connect(_on_level_ended)
	Events.game_ended.connect(_on_game_ended)
	Events.end_card_collected.connect(_on_end_card_collected)
	Events.card_played.connect(_on_card_played)
	Events.restart_requested.connect(func(): reload_level())
	Events.close_menu_requested.connect(func(): game_menu.hide(); get_tree().paused = false)
	Events.global_void_expanded.connect(func(): $sfx_void.play())
	Events.reshuffled_discard_pile.connect(_on_reshuffled_discard_pile)
	Events.game_mode_changed.connect(_on_game_mode_changed)
	card_engine.card_drawn.connect(_on_card_drawn)
	if draw_cooldown > 0:
		draw_timer.wait_time = draw_cooldown
		draw_timer.start()
	reset_void_cooldown()
	Globals.music_manager.fade_in_game_stream(Types.GameMusic.RHYTHM, .15)

func _on_player_respawned(player):
	Globals.player_pause = false
	%PauseButton.button_pressed = false
	
func _on_game_mode_changed(mode: Types.GameMode):
	if mode == Types.GameMode.ChoosingCard:
		Globals.music_manager.fade_in_game_stream(Types.GameMusic.RHYTHM, .15)
		#sfx_swoosh_to_game.play()
	elif mode == Types.GameMode.PlacingBlock:
		#sfx_swoosh_to_place.play()
		Globals.music_manager.fade_out_game_stream(Types.GameMusic.RHYTHM, .15)

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
		Globals.game_mode = Types.GameMode.ChoosingCard
		
	

func create_checkpoint():
	checkpoint = CHECKPOINT_SCENE.instantiate()
	checkpoint.void_cooldown = void_cooldown
	checkpoint.position = Globals.tilemap.cell_top_left(Globals.player.position)
	
	checkpoint.card_engine_state = card_engine.get_state()
	checkpoint.world_state = world.get_state()
	
	world.place_checkpoint(checkpoint)
	
func spawn_player():
	if player_needed:
		var player = PLAYER_SCENE.instantiate()
		player.tilemap = Globals.tilemap		
		
		if is_instance_valid(checkpoint):
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
		void_cooldown = checkpoint.void_cooldown
		Logger.info("Checkpoint void cooldown is %.2fs" % void_cooldown)
		if void_cooldown > 0:
			void_timer.start()
		world.place_checkpoint(checkpoint)
		return
	
func reset_void_cooldown():
	if void_cooldown > 0:
		void_cooldown = start_void_cooldown
		void_timer.wait_time = void_cooldown
		Logger.info("Void cooldown is %.2fs" % void_cooldown)
		void_timer.start()
			
func reload_level():
	if Globals.get_current_world_scene():
		await get_tree().process_frame #necessary to let the discard finish
		load_world(Globals.get_current_world_scene())		
		#Events.reshuffled_discard_pile.disconnect(_on_reshuffled_discard_pile)
		card_engine.reset()
		card_engine.create_card_in_pile("spawn", CardPileUI.Piles.hand_pile)
		Globals.player_alive = false
		#Events.reshuffled_discard_pile.connect(_on_reshuffled_discard_pile)
		reset_void_cooldown()
		
	else:
		Logger.warn("No level to load.")
	

func _on_card_error():
	sfx_err.play()

func _process(_delta: float) -> void:
	void_timer.paused = not Globals.player_alive or Globals.player_pause
	if void_timer.is_stopped():
		%TimeLabel.text = "--"
	else:
		%TimeLabel.text = "%02.f" % void_timer.time_left
	
	if Globals.game_mode != Types.GameMode.SelectionScreen:
		if Input.is_action_just_pressed("skip_intro") and world.can_skip:
			_on_level_ended()
		if Input.is_action_just_pressed("toggle_void"):
			toggle_void()
		if Input.is_action_just_pressed("toggle_void_progression"):
			game_menu.toggle_void()
		if Input.is_action_just_pressed("restart_level"):
			reload_level()
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_menu()
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
	if void_card_tick:
		Events.tick.emit()
	if draw_cooldown:
		card_engine.click_draw_pile_to_draw = false
		Logger.info("Draw in cooldown")
		draw_timer.start()
	
func _on_player_died():
	await get_tree().process_frame
	restore_checkpoint()
	

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
	Globals.win_game()
	

func _on_level_ended():
	void_timer.stop()
	#Events.reshuffled_discard_pile.disconnect(_on_reshuffled_discard_pile)
	player_needed = true
	Globals.player_alive=false
	if is_instance_valid(Globals.player):
		Globals.player.queue_free()
	Globals.current_level_idx += 1
	var next_world = Globals.get_current_world_scene()
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

func _on_card_played(_card:CardUI):
	Globals.player_pause = false
#	TODO this was removed before this event was no longer emitted. Check
	if draw_timer.wait_time>0:
		if draw_timer.wait_time>1:
			draw_timer.wait_time -= 1
		else:
			_on_draw_timer_timeout()


func _on_card_selection_card_selected(card: CardUI) -> void:
	var next_world = Globals.get_current_world_scene()
	
	load_world(next_world)	
	reset_void_cooldown()
	card_engine.add_card(card.card_data)	
	card_engine.reset()
	card_engine.create_card_in_pile("spawn", CardPileUI.Piles.hand_pile)	
	Globals.player_alive = false
	#Events.reshuffled_discard_pile.connect(_on_reshuffled_discard_pile)	
	anim_player.play("FadeIn")
	

func toggle_menu():
	Logger.info("toggle menu: %s" % not game_menu.visible)
	game_menu.visible = not game_menu.visible
	await get_tree().process_frame
	get_tree().paused = game_menu.visible
	

func _on_help_button_pressed() -> void:
	sfx_button.play()
	$CanvasLayer/MarginContainer2/HelpPanel.show()	
	get_tree().paused = true


func _on_void_timer_timeout() -> void:
	if void_time_tick:
		Events.tick.emit()
	void_timer.wait_time = void_cooldown
	void_timer.start()

func _on_reshuffled_discard_pile():
	if not do_void_progression:
		Logger.info("Not doing void cooldown progression")
		return 
	void_cooldown *= void_cooldown_progression
	Logger.info("New void cooldown is %.2fs" % void_cooldown)

func toggle_void():
	if start_void_cooldown == 0:
		return
	if void_cooldown == 0:
		void_cooldown = start_void_cooldown
		void_timer.start()
		Logger.info("Reset void cooldown is %.2fs" % void_cooldown)
	else:
		void_cooldown = 0 
		void_timer.stop()
		Logger.info("Stopped void timer.")


func toggle_void_progression():
	do_void_progression = not do_void_progression
	Logger.info("void timer cooldown progression: %s" % do_void_progression)
	if not do_void_progression:
		void_cooldown = start_void_cooldown


func _on_pause_button_toggled(toggled_on: bool) -> void:
	Globals.player_pause = toggled_on
