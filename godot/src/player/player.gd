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

var high_jumps := 0:
	set(hj):
		high_jumps=hj
		jump_velocity = JUMP_VELOCITY* (1 if hj == 0 else 1.5)#HACK magic value

@onready var animation_player: AnimationPlayer = $AnimationPlayer


var last_y_on_floor:float = -999
var boost_duration := 0.0
var in_animation:bool = true
var current_cell:Vector2i
var cell_map_string:String =""

var paused:bool = false
var is_spawning:bool = true

func _ready():
	Globals.player_alive = true
	Globals.player = self
	
	Events.turn_around_requested.connect(_on_turn_around_requested)
	Events.jump_requested.connect(_on_jump_requested)
	Events.speed_requested.connect(_on_speed_requested)
	Events.game_mode_changed.connect(_on_game_mode_changed)
	Events.end_card_collected.connect(_on_end_card_collected)
	
	Events.player_respawned.emit(self)
	
	Logger.info("player_respawned")
	
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
	if paused or is_spawning:
		return
	boost_duration = clamp(boost_duration-delta, 0, 100) 
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		last_y_on_floor=position.y
	if not in_animation:
		if position.y > DEATH_Y:
			_do_death("death")
			return
		if boost_duration == 0:
			base_speed = BASE_SPEED
			$AnimationPlayer.speed_scale = 1
			$RunFast.emitting = false
		else:
			$AnimationPlayer.speed_scale = base_speed/BASE_SPEED
			$RunFast.emitting = true
		velocity.x = base_speed * get_facing_direction()
		if is_on_floor() and not _can_walk():
			if _should_jump():
				velocity.y = jump_velocity
				if high_jumps>0:
					high_jumps -= 1
					sfx_jump_high.play()
					var vfx = vfx_jump_high.instantiate()
					vfx.global_position = global_position
					get_tree().root.add_child(vfx)
				else:
					sfx_jump.play()
			else :
				velocity.x=0 
		_update_animation()		
	var was_on_floor:bool = is_on_floor()
	move_and_slide()
	current_cell = tilemap.local_to_map(position-Vector2(0,1))
	cell_map_string = get_cell_map_string()
	#if landed
	if not was_on_floor and is_on_floor():
		if position.y-last_y_on_floor>DEATH_HEIGHT and last_y_on_floor!=-999:
			_do_death("death")
			return
		
	
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
			new_anim = "jump"
		else:
			new_anim = "fall"
	if animation_player.current_animation != new_anim:
		Logger.trace("change anim to %s" % new_anim)
		animation_player.play(new_anim)
		
	
func get_facing_direction()->int:
	return -1 if sprite.flip_h else 1
	
func _turn_around() -> void:
	Logger.debug("turning")
	sprite.flip_h = !sprite.flip_h
	#terrain_detector.flip = sprite.flip_h
	

func _on_jump_detected(height: float) -> void:
	Logger.debug("Jump of %s detected!" % height)

	

func _on_fall_detected(height: float) -> void:
	Logger.debug("Fall of %s detected!" % height)

func _on_turn_around_requested():
	_turn_around()

func _on_jump_requested():
	high_jumps += 1
	
func _on_speed_requested(factor:float, duration:float):
	base_speed = BASE_SPEED * factor
	boost_duration += duration 
	
func consume():
	_do_death("void_death")

func _do_death(animation):
	in_animation = true
	if is_on_floor():
		velocity.x=0
	animation_player.play(animation)
	#TODO we should prevent the player from playing cards until animation is over
	await animation_player.animation_finished	
	Events.player_died.emit()
	if get_parent():
		get_parent().remove_child(self)	
	Globals.player_alive = false	
	remove_log()
	queue_free()

func _can_walk()->bool:
	
	
	var mid_cell_position = tilemap.map_to_local(current_cell)
	#if we haven't reached the middle position of the cell, we can still walk
	if get_facing_direction()>0 and position.x < mid_cell_position.x:
		return true
	if get_facing_direction()<0 and position.x > mid_cell_position.x:
		return true
		
	var front_cell := _get_front_cell()

	var front_empty:bool = tilemap.is_cell_empty(front_cell) and tilemap.is_cell_empty(front_cell+Vector2i.UP)

	return front_empty and not _is_on_deep_edge()	

func _is_on_deep_edge()->bool:
	var front_cell := _get_front_cell()
	return tilemap.is_cell_empty(front_cell+Vector2i.DOWN) and \
		tilemap.is_cell_empty(front_cell + Vector2i.DOWN*2)


func _get_front_cell()->Vector2i:
	return current_cell + Vector2i.RIGHT * get_facing_direction()

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
			return true
	
	var front_cell_above3_empty := tilemap.is_cell_empty(front_cell+ Vector2i.UP * 3)
	var front_cell_below1_empty := tilemap.is_cell_empty(front_cell+ Vector2i.DOWN)
	var front_cell_below2_empty := tilemap.is_cell_empty(front_cell+ Vector2i.DOWN * 2)
	
	var front2_cell_empty := tilemap.is_cell_empty(front_cell+ Vector2i.RIGHT*get_facing_direction())
	var front2_below1_empty := tilemap.is_cell_empty(front_cell+ Vector2i.DOWN+Vector2i.RIGHT*get_facing_direction())
	# 1 block gap
	
	var past_mid_x:bool = position.x > mid_cell_position.x
	if  past_mid_x and \
		front_cell_empty and \
		front_cell_above1_empty and \
		front_cell_above2_empty and \
		front_cell_above2_empty and \
		front_cell_below1_empty and\
		front_cell_below2_empty and\
		front2_cell_empty and\
		not front2_below1_empty :
			return true

	# step down
	if  front_cell_empty and \
		front_cell_above1_empty and \
		front_cell_above2_empty and \
		front_cell_above1_empty and \
		not front_cell_below2_empty and\
		front2_below1_empty:
			return true

	# 2 block obstacle with jump card
	if high_jumps:
		if not front_cell_above1_empty and \
			front_cell_above2_empty  and \
			front_cell_above3_empty: #should we?
				return true
				
			
	# edge but with jump card
		if _is_on_deep_edge():
			_on_speed_requested(2,.2)
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
		"position" = position 
	}
	

func set_state(state: Dictionary) -> void:
	position = state.position
	
func _on_game_mode_changed(mode: Types.GameMode):
	paused = mode == Types.GameMode.PlacingBlock
	if paused:
		animation_player.pause()
	else:
		animation_player.play()
	

func _on_void_detector_body_entered(body: Node2D) -> void:
	consume()

func _on_end_card_collected():
	in_animation=true
	collision_layer=0
	velocity.x=0
	velocity.y = jump_velocity
	animation_player.play("level_end")
