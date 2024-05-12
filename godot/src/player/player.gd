extends CharacterBody2D


@export var base_speed :=50.0
@export var jump_velocity := -200.0
@export var jump_height := 8:
	set(value):
		if value != jump_height:
			%TerrainDetector.max_jump_distance = value
			jump_height = value
	

@onready var terrain_detector = %TerrainDetector
@onready var sprite: Sprite2D = $Sprite2D


func _ready():
	
	Events.turn_around_requested.connect(_on_turn_around_requested)
	
	terrain_detector.max_jump_distance = jump_height
	
	terrain_detector.jump_detected.connect(_on_jump_detected)
	terrain_detector.fall_detected.connect(_on_fall_detected)
	
	velocity.x = base_speed

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = base_speed * get_facing_direction()
	if is_on_floor():
		if _should_jump():
			velocity.y = jump_velocity
		elif terrain_detector.wall_ahead:
			velocity.x=0 
			
	move_and_slide()
	

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
