extends CharacterBody2D
class_name Player

const JUMP_HEIGHT := 8
const JUMP_VELOCITY := -200.0
const BASE_SPEED :=50.0

@export var base_speed := BASE_SPEED 
@export var jump_velocity := JUMP_VELOCITY
@export var jump_height := JUMP_HEIGHT:
	set(value):
		if value != jump_height:
			%TerrainDetector.max_jump_distance = value
			jump_height = value
	

@onready var terrain_detector = %TerrainDetector
@onready var sprite: Sprite2D = $Sprite2D
@onready var sfx_walk: AudioStreamPlayer2D = $sfx/sfx_walk
@onready var sfx_jump: AudioStreamPlayer2D = $sfx/sfx_jump
@onready var sfx_jump_high: AudioStreamPlayer2D = $sfx/sfx_jump_high

var high_jumps := 0:
	set(hj):
		high_jumps=hj
		jump_height = JUMP_HEIGHT* (1 if hj == 0 else 3)#HACK magic value
		jump_velocity = JUMP_VELOCITY* (1 if hj == 0 else 1.5)#HACK magic value


var boost_duration := 0.0
var in_animation:bool = true
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	Globals.player_alive = true
	
	Events.turn_around_requested.connect(_on_turn_around_requested)
	Events.jump_requested.connect(_on_jump_requested)
	Events.speed_requested.connect(_on_speed_requested)
	terrain_detector.max_jump_distance = jump_height
	
	terrain_detector.jump_detected.connect(_on_jump_detected)
	terrain_detector.fall_detected.connect(_on_fall_detected)
	
	Events.player_respawned.emit(self)
	Logger.info("player_respawned")
	
	in_animation = true
	animation_player.play("spawn")
	await animation_player.animation_finished
	
	in_animation = false
	Globals.last_checkpoint = position
	
	


func _physics_process(delta):

	boost_duration = clamp(boost_duration-delta, 0, 100) 
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if not in_animation:
		if boost_duration == 0:
			base_speed = BASE_SPEED
			$AnimationPlayer.speed_scale = 1
		else:
			$AnimationPlayer.speed_scale = base_speed/BASE_SPEED
		velocity.x = base_speed * get_facing_direction()
		if is_on_floor():
			if _should_jump():
				velocity.y = jump_velocity
				if high_jumps>0:
					high_jumps -= 1
					sfx_jump_high.play()
				else:
					sfx_jump.play()
			elif terrain_detector.wall_ahead:
				velocity.x=0 
		_update_animation()		
	
	move_and_slide()
	

func _update_animation():
	var new_anim=""
	if is_on_floor():
		if velocity.x != 0:
			new_anim = "move"
		else:
			new_anim = "idle"
	else:
		if velocity.y > 0:
			new_anim = "jump"
		else:
			new_anim = "fall"
	if animation_player.current_animation != new_anim:
		animation_player.play(new_anim)
		
func _should_jump() -> bool:
	return terrain_detector.jump_height > 0 and terrain_detector.jump_height <= jump_height
	
func get_facing_direction()->int:
	return -1 if sprite.flip_h else 1
	
func _turn_around() -> void:
	Logger.debug("turning")
	sprite.flip_h = !sprite.flip_h
	terrain_detector.flip = sprite.flip_h
	

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
	in_animation = true
	
	animation_player.play("void_death")
	#TODO we should prevent the player from playing cards until animation is over
	await animation_player.animation_finished	
	Events.player_died.emit()
	get_parent().remove_child(self)	
	Globals.player_alive = false	
	queue_free()
