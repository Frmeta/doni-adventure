extends Node2D


func _ready():
	SoundManager.play("mainMenuMusic")
	pass


func _on_TextureButton_pressed():
	SoundManager.stop_all_sound()
	get_tree().change_scene("res://scene/Level.tscn")


func _on_Quit_pressed():
	 get_tree().quit()
