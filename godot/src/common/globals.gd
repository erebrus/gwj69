extends Node


var master_volume:float = 100
var music_volume:float = 100
var sfx_volume:float = 100

const GameDataPath = "user://conf.cfg"
var config:ConfigFile

var debug_build := false

var last_level:PackedScene
var last_checkpoint:Vector2 
var current_deck:Array = ["Space Jump", "Turn around", "Turn around", "Turn around","Space Jump", "Leave the void behind", "Miracle of creation", "Miracle of creation", "Two is better than one", "Two is better than one", "Three is a lucky number", "4 blocks", "Three is a lucky number", "4 blocks", "The abyss will gaze back into you"]

var player_alive:bool = false

var game_mode: Types.GameMode:
	set(value):
		if value != game_mode:
			game_mode = value
			Events.game_mode_changed.emit(game_mode)
	

var tilemap: TileMapLayer


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
