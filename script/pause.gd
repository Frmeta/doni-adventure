extends Panel


func _ready():
	hide()


func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			get_tree().paused = false
			hide()
		else:
			get_tree().paused = true
			show()


func _on_ContinueButton_pressed():
	get_tree().paused = false
	hide()


func _on_MainMenuButton_pressed():
	get_tree().paused = false
	hide()
	SoundManager.stop_all_sound()
	get_tree().change_scene("res://scene/MainMenu.tscn")
