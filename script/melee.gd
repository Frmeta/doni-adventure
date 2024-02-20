extends "res://script/entity.gd"


# enemy only
func attack_player():
	yield(get_tree().create_timer(0.1), "timeout")
	if pos.distance_to(gm.player.pos) <= 1:
		gm.player.damage(atk_damage)


func get_movement():
	var output := []
	
	output.append(pos + Vector2.UP)
	output.append(pos + Vector2.RIGHT)
	output.append(pos + Vector2.LEFT)
	output.append(pos + Vector2.DOWN)
	
	output = gm.filter(output)
	
	for k in range(move_step - 1):
		for i in range(output.size()):
			output.append(output[i] + Vector2.UP)
			output.append(output[i] + Vector2.RIGHT)
			output.append(output[i] + Vector2.LEFT)
			output.append(output[i] + Vector2.DOWN)
		
		output = gm.filter(output)
	
	
	# Melee
	var best = [pos]
	var best_score = pos.distance_to(gm.player.pos)
	
	randomize()
	output.shuffle()

	for o in output:
		var selisih = o - gm.player.pos
		if o.distance_to(gm.player.pos) < best_score:
			best = [o]
			best_score = o.distance_to(gm.player.pos)
			
	
	
	return best
