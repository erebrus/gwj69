extends CustomCardUI
class_name CardSelectionUI

var can_do_selection = true


func _card_can_be_interacted_with():
	return can_do_selection


func _on_mouse_enter():
	if !is_clicked and _card_can_be_interacted_with():
		mouse_is_hovering = true
		target_position.y -= hover_distance
		emit_signal("card_hovered", self)

#func _on_mouse_exited():
	#if is_clicked:
		#return
	#if mouse_is_hovering:
		#mouse_is_hovering = false
		#target_position.y += hover_distance
		#var parent = get_parent()
		#if parent is CardPileUI:
			#parent.reset_card_ui_z_index()
		#emit_signal("card_unhovered", self)


func _on_gui_input(event):
	if !_card_can_be_interacted_with():
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if !is_clicked:
				is_clicked = true
				rotation = 0
				emit_signal("card_clicked", self)
			else:
				is_clicked = false
				emit_signal("card_dropped", self)
		#if is_clicked:
			#var now = Time.get_ticks_msec()
			#var double_click := true if last_click != -1 and now - last_click < 500 else false
			#last_click = now
			#is_clicked = false
			#mouse_is_hovering = false
			#rotation = 0
			#var parent = get_parent()
			#if parent is CardPileUI and parent.is_card_ui_in_hand(self):
				#parent.call_deferred("reset_target_positions")
			#var all_dropzones := []
			#get_dropzones(get_tree().get_root(), "CardDropzone", all_dropzones)
			#
			#for dropzone in all_dropzones:
				#if double_click:
					#if dropzone.default_zone and dropzone.can_drop_card(self):
						#dropzone.card_ui_dropped(self)
						#break
				#
				#var has_point:bool = dropzone.get_global_rect().has_point(get_global_mouse_position())
				#if has_point:
					#if dropzone.can_drop_card(self):
						#dropzone.card_ui_dropped(self)
						#break
				#
						#
			#emit_signal("card_dropped", self)
			#emit_signal("card_unhovered", self)
			
func _on_card_clicked(card):
	if card == self:
		Logger.info("Clicked %s" % card_data.nice_name)
		
		
		
