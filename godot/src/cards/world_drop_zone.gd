extends CardDropzone



func card_ui_dropped(card_ui : CardUI):
	Logger.info("Dropped %s" % card_ui.card_data.nice_name)
	card_ui.card_data.play() 
	#TODO wait for card to be played before discarding
	if card_pile_ui:
		card_pile_ui.set_card_pile(card_ui, CardPileUI.Piles.discard_pile)
func can_drop_card(card_ui : CardUI):
	return true
