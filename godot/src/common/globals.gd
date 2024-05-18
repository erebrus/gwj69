extends Node


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
	#preload("res://src/world/levels/level_01.tscn"),
	#preload("res://src/world/levels/level_02.tscn"),
	#preload("res://src/world/levels/level_03.tscn"),
	preload("res://src/world/levels/level_04_empty.tscn")
	]
var current_level_idx=0

var current_deck: Dictionary = {
	"Space Jump": 3,
	"Turn around": 3,
	"Leave the void behind": 1, 
	"Miracle of creation": 2,
	"Two is better than one": 2,
	"Three is a lucky number": 2,
	"3 blocks in a row": 2,
	"4 blocks": 2,
}

var player_alive:bool = false

var game_mode: Types.GameMode:
	set(value):
		if value != game_mode:
			game_mode = value
			Events.game_mode_changed.emit(game_mode)
	



var tilemap: PlatformsLayer
var player: Player


func _ready():
	_init_logger()


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
	

func fade_music():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(%Music,"volume_db",-60,1)

func get_current_world_scene()->PackedScene:	
	if current_level_idx < levels.size():
		return levels[current_level_idx]
	else:
		return null
	

func is_last_level()->bool:
	return current_level_idx + 1 == levels.size()
