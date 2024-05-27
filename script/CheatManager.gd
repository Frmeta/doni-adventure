extends Node2D

var cheat_code = [KEY_F, KEY_R, KEY_E, KEY_D, KEY_O]


var progress = 0
var is_cheating = false

func _ready():
	pass

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == cheat_code[progress]:
			progress += 1
			if progress == cheat_code.size():
				progress = 0
				CheatSingleton.is_cheating = !CheatSingleton.is_cheating
				print("cheatcode activated")
		else:
			progress = 0
