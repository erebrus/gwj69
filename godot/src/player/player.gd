extends CharacterBody2D
class_name Player

const DEATH_Y=500
const DEATH_HEIGHT = 24.0
const JUMP_VELOCITY := -200.0
const BASE_SPEED :=50.0


@export var tilemap:PlatformsLayer

@export var base_speed := BASE_SPEED 
@export var jump_velocity := JUMP_VELOCITY

	
@export var vfx_jump_high: PackedScene

@onready var sprite: Sprite2D = $Sprite2D
@onready var sfx_walk: AudioStreamPlayer2D = $sfx/sfx_walk
@onready var sfx_jump: AudioStreamPlayer2D = $sfx/sfx_jump
@onready var sfx_jump_high: AudioStreamPlayer2D = $sfx/sfx_jump_high
@onready var terrain_detection_debug: TerrainDetectionDebug = $TerrainDetectionDebug

var high_jumps := 0:
	set(hj):
		high_jumps=hj
		jump_velocity = JUMP_VELOCITY * (1.0 if hj == 0 else 1.5)#HACK magic value

var facing_direction := 1:
	set(value):
		facing_direction = value
		_turn_to_facing_direction()
	

@onready var animation_player: AnimationPlayer = $AnimationPlayer


var last_y_on_floor:float = -999
var boost_duration := 0.0
var in_animation:bool = true
var current_cell:Vector2i:
	set(value):
		current_cell = value
		terrain_detection_debug.current_cell = current_cell
var cell_map_string:String =""
var follow_target: Node2D = null

var paused:bool = false
var is_spawning:bool = true
var safe := true

func _ready():
	Globals.player_alive = true
	Globals.player = self
	
	Events.turn_around_requested.connect(_on_turn_around_requested)
	Events.jump_requested.connect(_on_jump_requested)
	Events.speed_requested.connect(_on_speed_requested)
	Events.game_mode_changed.connect(_on_game_mode_changed)
	Events.end_card_collected.connect(_on_end_card_collected)

	Events.die_requested.connect(_do_death.bind("death"))
	
	Events.player_respawned.emit(self)
	
	Logger.info("player_respawned")
	$sfx/sfx_respawn.play()	
	_turn_to_facing_direction()
	in_animation = true
	animation_player.play("spawn")
	await animation_player.animation_finished
	
	in_animation = false
	last_y_on_floor=position.y
	current_cell = tilemap.local_to_map(position-Vector2(0,1))
	is_spawning = false


func init_log():
	HyperLog.log(self).text("position>round")
	HyperLog.log(self).text("current_cell")
	HyperLog.log(self).text("cell_map_string")

func remove_log():
	HyperLog.remove_log(self)
	
func _physics_process(delta):
	if Globals.player_pause or paused or is_spawning:
		return
	boost_duration = clamp(boost_duration-delta, 0, 100) 
	
	if follow_target != null:
		global_position = follow_target.global_position
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		last_y_on_floor=position.y
	if not in_animation:
		if position.y > DEATH_Y:
			_do_gravity_death()
			return
		if boost_duration == 0:
			base_speed = BASE_SPEED
			$AnimationPlayer.speed_scale = 1
			$RunFast.emitting = false
		else:
			$AnimationPlayer.speed_scale = base_speed/BASE_SPEED
			$RunFast.emitting = true
		velocity.x = base_speed * facing_direction
		if is_on_floor() and not _can_walk():
			velocity.x=0 
			if _should_jump():
				in_animation = true
				animation_player.play("jump")

			#else :
				#velocity.x=0 
		if not in_animation:
			_update_animation()		
	var was_on_floor:bool = is_on_floor()
	var last_vy=velocity.y
	move_and_slide()
	current_cell = tilemap.local_to_map(position-Vector2(0,1))
	
	if animation_player.current_animation=="edge":
		var mid_cell_point = tilemap.map_to_local(current_cell)
		if facing_direction > 0 and position.x > mid_cell_point.x:
			position.x = mid_cell_point.x+1
		elif facing_direction < 0 and position.x < mid_cell_point.x:
			position.x = mid_cell_point.x-1
	cell_map_string = get_cell_map_string()
	
	#if landed
	if not was_on_floor and is_on_floor():
		Logger.trace("Landing speed = %2f" % last_vy)
		if last_vy > 300:
			_do_landing()
		if position.y-last_y_on_floor>DEATH_HEIGHT and last_y_on_floor!=-999:			
			_do_gravity_death(true)
			return
		
func _do_landing():
	in_animation=true
	velocity.x=0
	animation_player.play("land")
	await animation_player.animation_finished
	in_animation=false
func _do_jump():
	in_animation=false
	velocity.x = base_speed * facing_direction
	velocity.y = jump_velocity
	if high_jumps>0:
		high_jumps -= 1
		sfx_jump_high.play()
		var vfx = vfx_jump_high.instantiate()
		vfx.global_position = global_position
		get_tree().root.add_child(vfx)
	else:
		sfx_jump.play()	
	move_and_slide()

func _input(event: InputEvent):
	if event.is_action_pressed("die"):
		_do_death("death")
	

func _update_animation():
	var new_anim=""
	if is_on_floor():
		if velocity.x != 0:
			new_anim = "move"
		else:
			if _is_on_deep_edge():
				new_anim = "edge"
			else:
				new_anim = "idle"
	else:
		if velocity.y > 0:
			new_anim = "fall"
		#else:
			#new_anim = "jump"
	if animation_player.current_animation != new_anim:
		Logger.trace("change anim to %s" % new_anim)
		animation_player.play(new_anim)
	

func _turn_to_facing_direction() -> void:
	if sprite != null and sprite.is_inside_tree():
		sprite.flip_h = facing_direction < 0
		#terrain_detector.flip = sprite.flip_h
	

func _on_jump_detected(height: float) -> void:
	Logger.debug("Jump of %s detected!" % height)

	

func _on_fall_detected(height: float) -> void:
	Logger.debug("Fall of %s detected!" % height)

func _on_turn_around_requested():
	Logger.debug("turning")
	facing_direction = -facing_direction
	

func _on_jump_requested():
	high_jumps += 1
	
func _on_speed_requested(factor:float, duration:float):
	base_speed = BASE_SPEED * factor
	boost_duration += duration 
	
func _do_gravity_death(crash:=false):
	if not Globals.player_alive:
		return
	_do_death("crash_death" if crash else "death")
	if not crash:
		$sfx/sfx_death_gravity.play()
	
func consume():
	if not Globals.player_alive:
		return
	_do_death("void_death")
	$sfx/sfx_death_void.play()

func _do_death(animation):
	in_animation = true
	Globals.player_alive = false	
	if is_on_floor():
		velocity.x=0
	animation_player.play(animation)
	#TODO we should prevent the player from playing cards until animation is over
	await animation_player.animation_finished	
	
	if get_parent():
		get_parent().remove_child(self)	
	remove_log()
	Events.player_died.emit()	
	queue_free()

func _can_walk()->bool:
	
	
	var mid_cell_position = tilemap.map_to_local(current_cell)
	#if we haven't reached the middle position of the cell, we can still walk
	if facing_direction>0 and position.x < mid_cell_position.x:
		return true
	if facing_direction<0 and position.x > mid_cell_position.x:
		return true
		
	var front_cell := _get_front_cell()

	var front_empty:bool = tilemap.is_cell_empty(front_cell) and tilemap.is_cell_empty(front_cell+Vector2i.UP)

	return front_empty and not _is_on_deep_edge()	

func _is_on_deep_edge()->bool:
	var front_cell := _get_front_cell()
	return tilemap.is_cell_empty(front_cell+Vector2i.DOWN) and \
		tilemap.is_cell_empty(front_cell + Vector2i.DOWN*2)


func _get_front_cell()->Vector2i:
	return current_cell + Vector2i.RIGHT * facing_direction

func _should_jump()->bool:
	var mid_cell_position = tilemap.map_to_local(current_cell)
	var front_cell := _get_front_cell()
	
	var front_cell_empty := tilemap.is_cell_empty(front_cell)
	var front_cell_above1_empty := tilemap.is_cell_empty(front_cell+ Vector2i.UP)
	var front_cell_above2_empty := tilemap.is_cell_empty(front_cell+ Vector2i.UP * 2)
	
	# 1 block obstacle
	if not front_cell_empty and \
		front_cell_above1_empty and \
		front_cell_above2_empty:
			Logger.info ("1 block obstacle jump")
			return true
	
	var front_cell_above3_empty := tilemap.is_cell_empty(front_cell+ Vector2i.UP * 3)
	var front_cell_below1_empty := tilemap.is_cell_empty(front_cell+ Vector2i.DOWN)
	var front_cell_below2_empty := tilemap.is_cell_empty(front_cell+ Vector2i.DOWN * 2)
	
	var front2_cell_empty := tilemap.is_cell_empty(front_cell+ Vector2i.RIGHT*facing_direction)
	var front2_below1_empty := tilemap.is_cell_empty(front_cell+ Vector2i.DOWN+Vector2i.RIGHT*facing_direction)
	# 1 block gap
	
	var past_mid_x:bool = position.x > mid_cell_position.x if facing_direction > 0 \
			else position.x < mid_cell_position.x
	if  past_mid_x and \
		front_cell_empty and \
		front_cell_above1_empty and \
		front_cell_above2_empty and \
		front_cell_above2_empty and \
		front_cell_below1_empty and\
		front_cell_below2_empty and\
		front2_cell_empty and\
		not front2_below1_empty :
			Logger.info ("1 block gap jump")
			return true

	# step down
	if  front_cell_empty and \
		front_cell_above1_empty and \
		front_cell_above2_empty and \
		front_cell_above1_empty and \
		not front_cell_below2_empty and\
		front2_below1_empty:
			Logger.info ("step down")
			return true

	# 2 block obstacle with jump card
	if high_jumps:
		if not front_cell_above1_empty and \
			front_cell_above2_empty  and \
			front_cell_above3_empty: #should we?
				Logger.info ("2 block obstacle space jump")
				return true
				
			
	# edge but with jump card
		if _is_on_deep_edge():
			_on_speed_requested(2,.5)
			Logger.info ("space jump on edge")
			return true
	
	return false
	
func get_cell_map_string()->String:
	var ret=""
	for x in range(-3,4):
		for y in range(-3,4):
			ret += "0" if tilemap.is_cell_empty(current_cell + Vector2i(x,y)) else "1"
		ret += " "
	return ret

func get_state() -> Dictionary:
	return {
		"position" = position,
		"direction" = facing_direction,
	}
	

func set_state(state: Dictionary) -> void:
	position = state.position
	facing_direction = state.direction
	

func _on_game_mode_changed(mode: Types.GameMode):
	paused = mode == Types.GameMode.PlacingBlock
	if paused:
		animation_player.pause()
	else:
		animation_player.play()
	

func _on_void_detector_body_entered(_body: Node2D) -> void:
	consume()

func _on_end_card_collected():
	in_animation = true
	collision_layer=0
	velocity.x=0
	velocity.y = jump_velocity
	animation_player.play("level_end")

func set_rt_target(node_path:String):
	$RemoteTransform2D.remote_path = node_path

func get_rt()->RemoteTransform2D:
	return $RemoteTransform2D

func capture(target: Node2D) -> void:
	animation_player.play("idle")
	follow_target = target
	

func release() -> void:
	follow_target = null
	current_cell = tilemap.local_to_map(position-Vector2(0,1))
	


func _on_safety_timer_timeout() -> void:
	check_safety()
	
#TODO Review formula and handle magic numbers
func check_safety():
	var was_safe := safe
	
	current_cell = tilemap.local_to_map(position-Vector2(0,1))
	var close_area_count :int = Globals.void_tilemap.count_void_in_area(current_cell, 2)
	if close_area_count > 4:
		safe = false
	else:
		var large_area_count :int = Globals.void_tilemap.count_void_in_area(current_cell, 8)
		var small_area_count :int = Globals.void_tilemap.count_void_in_area(current_cell, 4)
		var danger_ratio:float = large_area_count/64*.3+ small_area_count/16*.7
		safe = danger_ratio <.3	
	
	if was_safe and not safe:
		Globals.music_manager.fade_in_game_stream(Types.GameMusic.STRESS)
		Logger.info("Player in danger")
		Events.in_danger.emit()
	elif not was_safe and safe:
		Logger.info("Player safe")
		Events.not_in_danger.emit()
		Globals.music_manager.fade_out_game_stream(Types.GameMusic.STRESS)

		
