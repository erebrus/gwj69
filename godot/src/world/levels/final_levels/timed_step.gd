extends TutorialStep

@export var time_to_wait: float = 2.0
var time: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	time = time_to_wait

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	if started and !completed:
		time -= delta
		
func is_step_complete():
	return time <= 0 or super.is_step_complete()
