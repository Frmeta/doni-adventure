extends Area2D


var is_hover = false
var cardType
var cm

func _ready():
	pass


func _on_Card_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT and is_hover:
		cm.use_card(self)


func _on_Card_mouse_entered():
	is_hover = true


func _on_Card_mouse_exited():
	is_hover = false
