extends "res://script/enemy.gd"

# ranged
onready var timerText = $TimerText
export var max_timer = 2 # berarti 3 turns diam
var timer

# set timer
func _ready():
	randomize()
	timer = randi() % (max_timer+1)
	timerText.text = str(timer)

# enemy only
func attack_player():
	if not is_instance_valid(gm.player):
		return
		
	if timer == 0:
	
		$AnimatedSprite.play("atk")
		
		yield($AnimatedSprite, "animation_finished")
		
		$AnimatedSprite.play("atk2")
		
		var b = gm.instantiate(bullet)
		b.rotation = (gm.player.position - position).angle()
		b.position = position
		b.atk_damage = atk_damage
		
		yield($AnimatedSprite, "animation_finished")
		
		$AnimatedSprite.play("idle")
		
		if is_instance_valid(b):
			yield(b, "hit")
		
		yield(get_tree().create_timer(1), "timeout")
		
		# yield (gm.player.damage(atk_damage), "completed")
		
		timer = max_timer
	else:
		timer -= 1
	
	timerText.text = str(timer)
	
	yield(VisualServer, 'frame_pre_draw')

# random movement
func get_movement():
	var output := []
	
	output.append(pos + Vector2.UP)
	output.append(pos + Vector2.RIGHT)
	output.append(pos + Vector2.LEFT)
	output.append(pos + Vector2.DOWN)
	
	output = gm.filter(output, false)
	randomize()
	output.shuffle()
	
	if output.size() == 0:
		# diam
		return [pos]
	else:
		return output
