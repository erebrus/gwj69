extends Node

@export var void_time_tick:=true
@export var void_card_tick:=true

var master_volume:float = 100
var music_volume:float = 100
var sfx_volume:float = 100

const GameDataPath = "user://conf.cfg"
var config:ConfigFile

var debug_build := false

var levels:Array[PackedScene] =[
	#preload("res://src/world/levels/test_angela_world.tscn"),
	#preload("res://src/world/levels/test_erebrus_world.tscn"),
	#preload("res://src/world/levels/level_tutorial.tscn"),
	preload("res://src/world/levels/test_level_tunnel.tscn"),
	preload("res://src/world/levels/test_level_up.tscn"),
	preload("res://src/world/levels/test_level_swirl.tscn"),
	preload("res://src/world/levels/final_levels/level_00_tutorial.tscn"),
	preload("res://src/world/levels/final_levels/level_01.tscn"),
	preload("res://src/world/levels/final_levels/level_02.tscn"),
	preload("res://src/world/levels/final_levels/level_03.tscn"),
	#preload("res://src/world/levels/level_03.tscn"),
	]
var current_level_idx=0

var starting_deck: Dictionary = {
	"jump": 2,
	"turn_around": 2,
	"speed": 1, 
	"block1": 3,
	"block2": 2,
	"block3_step": 2,
	"block3_row": 1,
	"block4": 1,
	#"moving_block": 2,
	"checkpoint":1,
	#"stairs": 2,
}

var current_deck: Dictionary = {}

var player_alive:bool = false

var game_mode: Types.GameMode:
	set(value):
		if value != game_mode:
			game_mode = value
			Events.game_mode_changed.emit(game_mode)
	



var tilemap: PlatformsLayer
var player: Player

@onready var menu_music: AudioStreamPlayer = $menu_music
@onready var game_music: AudioStreamPlayer = $game_music

func _ready():
	_init_logger()

	
func start_game():
	current_deck = starting_deck.duplicate()
	get_tree().change_scene_to_file("res://src/game.tscn")

func win_game():
	get_tree().change_scene_to_file("res://src/win_screen.tscn")
	
func _init_logger():
	Logger.set_logger_level(Logger.LOG_LEVEL_INFO)
	Logger.set_logger_format(Logger.LOG_FORMAT_MORE)
	var console_appender:Appender = Logger.add_appender(ConsoleAppender.new())
	console_appender.logger_format=Logger.LOG_FORMAT_FULL
	console_appender.logger_level = Logger.LOG_LEVEL_DEBUG
	var file_appender:Appender = Logger.add_appender(FileAppender.new("res://debug.log"))
	file_appender.logger_format=Logger.LOG_FORMAT_FULL
	file_appender.logger_level = Logger.LOG_LEVEL_DEBUG
	Logger.info("Logger initialized.")


func init_music():
	%Music.stop()
	%Music.volume_db=-60
	%Music.play()
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(%Music,"volume_db",0,2)
	

func play_music(node:AudioStreamPlayer):
	node.volume_db = 0
	node.play()
	
func fade_music(node:AudioStreamPlayer, duration := 1):
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node,"volume_db",-20 , duration)
	await tween.finished
	node.stop()
	
func get_current_world_scene()->PackedScene:	
	if current_level_idx < levels.size():
		return levels[current_level_idx]
	else:
		return null
	

func is_last_level()->bool:
	return current_level_idx + 1 == levels.size()
