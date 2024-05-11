extends CardUI
class_name CustomCardUI

func _ready():
	super()
	card_data.connect("card_data_updated", _update_display)
	_update_display()
	
func _update_display():
	pass
	#cost_label.text = "%d" % card_data.cost
	#name_label.text = "%s" % card_data.nice_name			
	#type_label.text = "%s" % card_data.type
	#description_label.text = "%s" % card_data.description

	
