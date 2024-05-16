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
		CardPileUI.Piles.draw_pile: _draw_pile.map(_get_card_name),
		CardPileUI.Piles.hand_pile: _hand_pile.map(_get_card_name),
		CardPileUI.Piles.discard_pile: _discard_pile.map(_get_card_name)
	}

func set_state(state):
	for pile in state:
		for card in get_cards_in_pile(pile):
			remove_card_from_game(card)
		for card in state[pile]:
			create_card_in_pile(card, pile)
	

func _on_card_destroy_requested(card:CardUI):
	_maybe_remove_card_from_any_piles(card)
	card.queue_free()

func _get_card_name(card: CardUI) -> String:
	return card.card_data.nice_name
	

