extends CardPileUI


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	Events.discard_requested.connect(_on_discard_requested)
	hand_pile_updated.connect(_on_hand_pile_updated)
	draw(3)
	
func _on_discard_requested(card_ui:CardUI):
	set_card_pile(card_ui, CardPileUI.Piles.discard_pile)
	
func _on_hand_pile_updated():
	if not get_card_pile_size(Piles.draw_pile):
		_shuffle_discard_on_draw()
		
	
	

