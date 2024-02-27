extends "res://script/entity.gd"


export var move_step := 2 # enemy only

var isStun = false

func _ready():
	healthText = get_node("HealthText")
	healthText.text = str(health)

func stun():
	isStun = true

func unstun():
	isStun = false
