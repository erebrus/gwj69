class_name MusicManager extends Node


@onready var menu_music: AudioStreamPlayer = $menu_music
@onready var game_music: AudioStreamPlayer = $game_music


@onready var game_music_stream:AudioStreamSynchronized = game_music.stream
var current_game_music_id = Types.GameMusic.EASY


func fade_in_menu_music(time:float=1.0):
	fade_in_stream(menu_music,time)

func fade_menu_music(time:float=1.0):
	fade_stream(menu_music, time)
	
func fade_in_game_music(time:float=1.0):
	fade_in_stream(game_music, time)

func fade_game_music(time:float=1.0):
	fade_stream(game_music, time)
		
func play_music(node:AudioStreamPlayer):
	if not node.playing:
		node.play()
	
func reset_synchronized_stream():
	for i in range(game_music_stream.stream_count):
		if i == current_game_music_id:
			game_music_stream.set_sync_stream_volume(i,0)
		else:
			game_music_stream.set_sync_stream_volume(i,-60)

func fade_in_stream(node:AudioStreamPlayer, duration := 1.0):
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	node.volume_db=-20
	node.play()
	tween.tween_property(node,"volume_db",0 , duration)
	

func fade_stream(node:AudioStreamPlayer, duration := 1.0):
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node,"volume_db",-20 , duration)
	await tween.finished
	node.stop()
	

func _helper_set_volume(volume_db:float, id:int):
	game_music_stream.set_sync_stream_volume(id, volume_db)
	

func change_game_music_to(new_id:Types.GameMusic, time:=1.0):
	if new_id == current_game_music_id:
		return
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_method(_helper_set_volume.bind(current_game_music_id),0,-60, time)
	tween.parallel().tween_method(_helper_set_volume.bind(new_id),-60,0, time).set_ease(Tween.EASE_OUT)
	await tween.finished
	current_game_music_id = new_id
	Logger.info("Music changed to: %s" % new_id)
