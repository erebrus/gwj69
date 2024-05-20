extends Control
class_name TutorialStep

@onready var text: TutorialDialog = $MarginContainer
@export var can_skip = true
var completed = false
var started = false
var skip_requested = false
var complete_requested = false
var tutorial: Tutorial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text.skip_requested.connect(_on_skip_requested)
	text.can_skip = can_skip


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_tutorial_step()->void:
	started = true
	text.show_text()
#
func finish_tutorial_step()->void:
	if !completed:
		completed = true
		text.hide_text()

func is_step_complete():
	return skip_requested or complete_requested
	
func _on_skip_requested() -> void:
	skip_requested = true

#func begin() -> void:
