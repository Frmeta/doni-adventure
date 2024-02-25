extends "res://script/entity.gd"

# dipanggil oleh cardItem
signal get_card

export var beam: PackedScene


func get_movement():
	var output := []
	
	output.append(pos + Vector2.UP)
	output.append(pos + Vector2.RIGHT)
	output.append(pos + Vector2.LEFT)
	output.append(pos + Vector2.DOWN)
	
	output = gm.filter(output, true)
	
	for i in range(output.size()):
		output.append(output[i] + Vector2.UP)
		output.append(output[i] + Vector2.RIGHT)
		output.append(output[i] + Vector2.LEFT)
		output.append(output[i] + Vector2.DOWN)
	
	output = gm.filter(output, true)
	
	for i in output.count(pos):
		output.erase(pos)
	
	return output

func attack_enemy(angle):
	
	# attack animation
	$AnimatedSprite.play("atk")
	yield($AnimatedSprite, 'animation_finished')
	$AnimatedSprite.play("atk2")
	
	# spawn bullet
	var b = gm.instantiate(bullet)
	b.rotation = angle
	b.position = position
	b.atk_damage = atk_damage
	
	yield($AnimatedSprite, 'animation_finished')
	
	$AnimatedSprite.play("idle")
	
	# wait
	if is_instance_valid(b):
		yield(b, "hit")
		
	yield(get_tree().create_timer(1.0), "timeout")

func beam_attack(angle):
	
	# attack animation
	$AnimatedSprite.play("atk")
	yield($AnimatedSprite, 'animation_finished')
	$AnimatedSprite.play("atk2")
	
	# spawn beam
	var b = gm.instantiate(beam)
	b.rotation = angle
	b.position = position
	
	# damage enemies
	var enemies = b.get_overlapping_bodies()
	for enemy in enemies:
		enemy.damage(2)
	
	
	yield($AnimatedSprite, 'animation_finished')
	$AnimatedSprite.play("idle")
	yield(get_tree().create_timer(1.0), "timeout")
