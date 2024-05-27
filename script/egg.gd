extends "res://script/enemy.gd"

var chiPrefab = preload("res://prefab/chi.tscn")

onready var timerText = $TimerText


export var max_timer = 2
var timer = max_timer

# set timer
func _ready():
	timer = randi() % (max_timer+1)
	timerText.text = str(timer)


# melee attack
func attack_player():
	if timer == 0 and health > 0:
		$AnimatedSprite.play("break")
	
		yield($AnimatedSprite, "animation_finished")
		
		# Replaced by chi
		queue_free()
		gm.entity_died(self)
		gm.spawn_entity(chiPrefab, pos)
	
	else:
		timer -= 1
		timerText.text = str(timer)
	
	yield(VisualServer,"frame_pre_draw")

# directed movement
func get_movement():
	return [pos]
