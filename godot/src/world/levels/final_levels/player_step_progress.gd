extends Area2D
class_name TutorialAreaProgress

signal player_entered_progress_area(area: TutorialAreaProgress)

var tutorial: Tutorial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	player_entered_progress_area.emit(self)
