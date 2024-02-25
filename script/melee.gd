extends "res://script/enemy.gd"

# melee attack
func attack_player():
	
	if pos.distance_to(gm.player.pos) <= 1:
		$AnimatedSprite.play("atk")
		
		yield($AnimatedSprite, "animation_finished")
		
		$AnimatedSprite.play("idle")
		
		yield (gm.player.damage(atk_damage), "completed")
		
	
	yield(VisualServer, 'frame_pre_draw')

# directed movement
func get_movement():
	var output := []
	
	output.append(pos + Vector2.UP)
	output.append(pos + Vector2.RIGHT)
	output.append(pos + Vector2.LEFT)
	output.append(pos + Vector2.DOWN)
	
	output = gm.filter(output, false)
	
	for _k in range(move_step - 1):
		for i in range(output.size()):
			output.append(output[i] + Vector2.UP)
			output.append(output[i] + Vector2.RIGHT)
			output.append(output[i] + Vector2.LEFT)
			output.append(output[i] + Vector2.DOWN)
		
		output = gm.filter(output, false)
	
	
	# Melee
	var best = [pos]
	var best_score = pos.distance_to(gm.player.pos)
	
	randomize()
	output.shuffle()

	for o in output:
		if o.distance_to(gm.player.pos) < best_score:
			best = [o]
			best_score = o.distance_to(gm.player.pos)
			
	
	
	return best
