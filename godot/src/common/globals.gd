extends Node

const GAME_SCENE_PATH = "res://src/game.tscn"
const WIN_SCENE_PATH = "res://src/win_screen.tscn"


const GameDataPath = "user://conf.cfg"
var config:ConfigFile


var levels:Array[PackedScene] =[
	#preload("res://src/world/levels/test_angela_world.tscn"),
	#preload("res://src/world/levels/test_erebrus_world.tscn"),
	#preload("res://src/world/levels/level_tutorial.tscn"),
	#preload("res://src/world/levels/test_level_tunnel.tscn"),
	#preload("res://src/world/levels/test_level_up.tscn"),
	preload("res://src/world/levels/test_level_swirl.tscn"),
	#preload("res://src/world/levels/final_levels/level_00_tutorial.tscn"),
	#preload("res://src/world/levels/final_levels/level_01.tscn"),
	#preload("res://src/world/levels/final_levels/level_02.tscn"),
	#preload("res://src/world/levels/final_levels/level_03.tscn"),
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
	#"zblock": 5,
	#"moving_block": 2,
	"checkpoint":1,
	#"stairs": 2,
}

var current_deck: Dictionary = {}

var player_alive:bool = false
var player_pause:bool = false:
	set(_v):
		player_pause=_v
		Events.player_pause_state_changed.emit()

var game_mode: Types.GameMode:
	set(value):
		if value != game_mode:
			game_mode = value
			Events.game_mode_changed.emit(game_mode)
	
var in_game:=false

var tilemap: PlatformsLayer
var void_tilemap: VoidLayer
var player: Player
var game: Game

@onready var music_manager: MusicManager = $MusicManager

func _ready():
	_init_logger()
	

func start_game():
	Logger.info("Starting Game")
	in_game=true
	
	music_manager.fade_menu_music()
	await get_tree().create_timer(1).timeout
	music_manager.reset_synchronized_stream()
	
	current_deck = starting_deck.duplicate()
	get_tree().change_scene_to_file(GAME_SCENE_PATH)
	music_manager.fade_in_game_music()
	

func win_game():
	get_tree().change_scene_to_file(WIN_SCENE_PATH)
	

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
	

func get_current_world_scene()-> PackedScene:
	
	if current_level_idx < levels.size():
		return levels[current_level_idx]
	else:
		return null
	

func is_last_level()->bool:
	return current_level_idx + 1 == levels.size()
