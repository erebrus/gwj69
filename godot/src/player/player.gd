extends CharacterBody2D


@export var base_speed :=50.0
@export var jump_velocity := -200.0
@export var jump_height := 8:
	set(value):
		if value != jump_height:
			%TerrainDetector.max_jump_distance = value
			jump_height = value
	

@onready var terrain_detector = %TerrainDetector


func _ready():
	terrain_detector.max_jump_distance = jump_height
	
	terrain_detector.jump_detected.connect(_on_jump_detected)
	terrain_detector.fall_detected.connect(_on_fall_detected)
	
	velocity.x = base_speed

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_floor():
		if _should_jump():
			velocity.y = jump_velocity
		elif terrain_detector.wall_ahead:
			_turn_arround()
			
	move_and_slide()
	

func _should_jump() -> bool:
	return terrain_detector.jump_height > 0 and terrain_detector.jump_height <= jump_height
	

func _turn_arround() -> void:
	Logger.debug("turning")
	velocity.x = -velocity.x
	terrain_detector.flip = velocity.x < 0
	

func _on_jump_detected(height: float) -> void:
	Logger.debug("Jump of %s detected!" % height)
	

func _on_fall_detected(height: float) -> void:
	Logger.debug("Fall of %s detected!" % height)
