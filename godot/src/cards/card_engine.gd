extends CardPileUI


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	Events.discard_requested.connect(_on_discard_requested)
	draw(3)
	
func _on_discard_requested(card_ui:CardUI):
	set_card_pile(card_ui, CardPileUI.Piles.discard_pile)
	


