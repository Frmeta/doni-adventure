extends Area2D


var is_hover = false
var cardType
var cm

export var normalColor: Color
export var disabledColor: Color

func _process(_delta):
	if cm.gm.is_card_usable:
		modulate = normalColor
	else:
		modulate = disabledColor


func _on_Card_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT and is_hover:
		if cm.gm.is_card_usable:
			cm.use_card()


func _on_Card_mouse_entered():
	is_hover = true


func _on_Card_mouse_exited():
	is_hover = false
