extends CardPileUI

@export var hand_start_size:=3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	Events.discard_requested.connect(_on_discard_requested)
	Events.card_destroy_requested.connect(_on_card_destroy_requested)
	hand_pile_updated.connect(_on_hand_pile_updated)
	draw(hand_start_size, false)
	
func _on_discard_requested(card_ui:CardUI):
	set_card_pile(card_ui, CardPileUI.Piles.discard_pile)
	
func _on_hand_pile_updated():
	if not get_card_pile_size(Piles.draw_pile):
		_shuffle_discard_on_draw()
		
func load_json_path():
	card_database = _load_json_cards_from_path(json_card_database_path)
	card_collection = Globals.current_deck

func get_state():
	return {
		"draw_pile": _draw_pile,
		"hand_pile": _hand_pile,
		"discard_pile": _discard_pile
	}	
func set_state(state):
	_draw_pile = state.draw_pile
	_hand_pile = state.hand_pile
	_discard_pile = state.discard_pile
	reset_target_positions()

func _on_card_destroy_requested(card:CardUI):
	_maybe_remove_card_from_any_piles(card)
	card.queue_free()
