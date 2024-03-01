extends "res://script/entity.gd"


export var move_step := 2 # enemy only

var isStun = false

func _physics_process(delta):
	if isStun:
		$AnimatedSprite.playing = false
	elif pos.y > gm.player.pos.y:
		$AnimatedSprite.flip_h = false
	elif pos.y < gm.player.pos.y:
		$AnimatedSprite.flip_h = true
				
				
func _ready():
	healthText = get_node("HealthText")
	healthText.text = str(health)

func stun():
	isStun = true
	$AnimatedSprite.playing = false

func unstun():
	isStun = false
	$AnimatedSprite.playing = true
