extends "res://script/melee.gd"

var egg = preload("res://prefab/egg.tscn")

func attack_player():
	yield(.attack_player(), "completed")
	
	if randi() % 3 == 0:
		# Spawn egg
		
		var output := []
		output.append(pos + Vector2.UP)
		output.append(pos + Vector2.RIGHT)
		output.append(pos + Vector2.LEFT)
		output.append(pos + Vector2.DOWN)
		
		output = gm.filter(output, false)
		
		randomize()
		output.shuffle()
		
		for _i in range(randi() % 2 + 1):
			if output.size() > 0:
				gm.spawn_entity(egg, output[0])
				output.remove(0)

# override melee directed movement
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
