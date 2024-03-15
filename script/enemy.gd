extends "res://script/entity.gd"


export var move_step := 2 # enemy only

onready var atkText = $AtkText

var isStun = false

func _physics_process(_delta):
	if isStun:
		$AnimatedSprite.playing = false
	elif not is_instance_valid(gm.player):
		pass
	elif pos.y > gm.player.pos.y:
		$AnimatedSprite.flip_h = false
	elif pos.y < gm.player.pos.y:
		$AnimatedSprite.flip_h = true
				
				
func _ready():
	healthText = get_node("HealthText")
	healthText.text = str(health)
	
	if is_instance_valid(atkText):
		atkText.text = str(atk_damage)

func stun():
	SoundManager.play("enemyHurt")
	isStun = true
	$AnimatedSprite.playing = false

func unstun():
	isStun = false
	$AnimatedSprite.playing = true
	
func damage(amount):
	SoundManager.play("enemyHurt")
	yield (.damage(amount), "completed")
