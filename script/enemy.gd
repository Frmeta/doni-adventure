extends "res://script/entity.gd"


export var move_step := 2 # enemy only

func _ready():
	healthText = get_node("HealthText")
	healthText.text = str(health)
