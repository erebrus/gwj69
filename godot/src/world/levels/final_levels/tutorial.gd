extends MarginContainer
class_name Tutorial

@onready var step_list: Control = $"MarginContainer/Step List"
var steps: Array[TutorialStep]
var current_step: TutorialStep
var step_i: int = 0
var card_engine: CardEngine
var player: Player
var end_level_card

var step_dialog: Array[String] = [
	
]

enum TutorialStep {
	Intro,
	PlayCharacter,
	ProphetWill,
	Camera,
	SimpleObstacle,
	UseDivinePowers,
	DrawFirstHand,
	NavigateToHandUseCard,
	Play2block,
	USeSpecialPowers,
	Checkpoint,
	DieUseRespawn,
	AvoidVoid,
	UseDeathIfStuck,
	ShuffleExplanation,
	VoidSpreads,
	BeatEnd
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	card_engine = get_tree().get_first_node_in_group("card_engine") as CardEngine
	Globals.current_deck.clear()
	Events.player_respawned.connect(_on_player_respawned)
	Events.card_played.connect(_on_card_played)
	Events.jump_requested.connect(_on_jump_requested)
	Events.checkpoint_requested.connect(_on_checkpoint_requested)
	card_engine.reset_and_clear_card_collection()
	#card_engine.create_card_in_pile("spawn", CardPileUI.Piles.hand_pile)
	player = get_tree().get_first_node_in_group("player") as Player
	get_tree().root.get_node("/root/Game")
	steps.assign(step_list.get_children())
	for step in steps:
		step.tutorial = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if step_i >= len(steps):
		# we are done tutorial
		return
	current_step = steps[step_i]
	if !current_step.started:
		current_step.start_tutorial_step()
		do_tutorial_step_kludge(step_i)
	elif !current_step.completed and current_step.is_step_complete():
		current_step.finish_tutorial_step()
		step_i += 1
	else:
		if step_i == TutorialStep.DrawFirstHand and card_engine.get_card_pile_size(CardPileUI.Piles.hand_pile) == 1:
			current_step.complete_requested = true


func do_tutorial_step_kludge(index: int) -> void:
	match index:
		TutorialStep.Intro:
			card_engine.hand_enabled = false
		TutorialStep.PlayCharacter:
			card_engine.hand_enabled = true
		TutorialStep.ProphetWill:
			pass
		TutorialStep.Camera:
			pass
		TutorialStep.SimpleObstacle:
			pass
		TutorialStep.UseDivinePowers:
			pass
		TutorialStep.DrawFirstHand:
			card_engine.create_card_in_pile("block2", CardPileUI.Piles.draw_pile)
			card_engine.hand_enabled = true
		TutorialStep.Play2block:
			card_engine.hand_enabled = true
		TutorialStep.USeSpecialPowers:
			card_engine.create_card_in_pile("jump", CardPileUI.Piles.hand_pile)
		TutorialStep.Checkpoint:
			card_engine.create_card_in_pile("checkpoint", CardPileUI.Piles.draw_pile)
		TutorialStep.DieUseRespawn:
			pass
		TutorialStep.AvoidVoid:
			pass
		TutorialStep.UseDeathIfStuck:
			pass
		TutorialStep.ShuffleExplanation:
			pass
		TutorialStep.VoidSpreads:
			pass
		TutorialStep.BeatEnd:
			Globals.current_deck= Globals.starting_deck.duplicate()
			card_engine.reset_and_set_to_starting_deck()
		
func _on_timer_timeout() -> void:
	pass # Replace with function body.
	
func _on_player_respawned(player: Player) -> void:
	if step_i == TutorialStep.PlayCharacter:
		current_step.complete_requested = true

func _on_card_played(card: CardUI) -> void:
	print(card.card_name)	
	if card.card_name == "checkpoint":
		current_step.complete_requested = true
	elif card.card_name == "jump":
		current_step.complete_requested = true

func _on_jump_requested() -> void:
	if step_i == TutorialStep.USeSpecialPowers:
		current_step.complete_requested = true

func _on_checkpoint_requested() -> void:
	if step_i == TutorialStep.Checkpoint:
		current_step.complete_requested = true
