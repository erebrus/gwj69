extends CardPileUI

@export var hand_start_size:=3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	card_clicked.connect(func(_x): Events.card_clicked.emit())
	Events.discard_requested.connect(_on_discard_requested)
	Events.card_destroy_requested.connect(_on_card_destroy_requested)
	Events.card_clicked.connect(_on_card_clicked)
	Events.card_played.connect(_on_card_played)
	card_drawn.connect(_on_card_drawn)
	draw(hand_start_size, false)
	
func reset():
	_reset_card_collection()
	draw(hand_start_size, false)
	
func draw(num_cards := 1, manual:=true):
	for i in range(num_cards):
		super.draw(1, manual)
		$sfx_draw.play()
		await get_tree().create_timer(.2).timeout


func _on_discard_requested(card_ui:CardUI):
	set_card_pile(card_ui, CardPileUI.Piles.discard_pile)
	
func _on_card_drawn():
	if not get_card_pile_size(Piles.draw_pile):
		_shuffle_discard_on_draw()
		Events.reshuffled_discard_pile.emit()
		$sfx_reshuffle.play()
		
func load_json_path():
	card_database = _load_json_cards_from_path(json_card_database_path)
	var cards: Array[String]
	for card_name in Globals.current_deck:
		for i in Globals.current_deck[card_name]:
			cards.append(card_name)
	
	card_collection = cards

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
			
func create_card_in_pile(nice_name : String, pile_to_add_to : Piles):
	if pile_to_add_to==Piles.hand_pile:
		if _hand_pile.size() == max_hand_size:
			_on_discard_requested(_hand_pile[0])
	super.create_card_in_pile(nice_name, pile_to_add_to)
	$sfx_draw.play()

func _on_card_destroy_requested(card:CardUI):
	_maybe_remove_card_from_any_piles(card)
	card.queue_free()

func _get_card_name(card: CardUI) -> String:
	return card.card_data.nice_name
	

func _on_card_clicked():
	$sfx_pick.play()
func _on_card_played(_card:CardUI):
	$sfx_play.play()

func add_card(card:CustomCardUIData):
	if not card.nice_name in Globals.current_deck:
		Globals.current_deck[card.nice_name] = 0
	Globals.current_deck[card.nice_name] = Globals.current_deck[card.nice_name] + 1
	load_json_path()
