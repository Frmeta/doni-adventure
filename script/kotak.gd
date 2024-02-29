extends Node2D

class_name Kotak

enum HighlightType {PLAYER_MOVE, AXE, DISABLED}

export var normalColor = Color.white
export var clickableColor = Color.white;

onready var sprite = $Sprite

var hover := false
var clickable := false
var sizeSpeed = 50
var pos := Vector2.ZERO
var gm

signal clicked(pos)

func _on_Area2D_input_event(viewport, event, shape_idx):
	if  event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if clickable:
			emit_signal("clicked", pos)

# Hover effect
func _process(delta):
	if gm.clickablePos.has(pos):
		clickable = true
	else:
		clickable = false
	
	if clickable:
		sprite.modulate = clickableColor
	else:
		sprite.modulate = normalColor
		
	if hover and clickable:
		$Sprite/Spiral.visible = true
		# scale = lerp(scale, Vector2.ONE * 1.2, delta * sizeSpeed)
	else:
		
		$Sprite/Spiral.visible = false
		# scale = lerp(scale, Vector2.ONE, delta * sizeSpeed)
		


func _on_Area2D_mouse_entered():
	hover = true

func _on_Area2D_mouse_exited():
	hover = false

