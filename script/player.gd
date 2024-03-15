extends "res://script/entity.gd"

# dipanggil oleh cardItem
signal get_card

var beam: PackedScene = preload("res://prefab/Beam.tscn")
var shieldHitPrefab := preload("res://prefab/ShieldHit.tscn")

var isShield = false

		

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
	_update_flip(angle)
	
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

func tembus_attack(angle, isCosmic):
	_update_flip(angle)
	
	# attack animation
	$AnimatedSprite.play("atk")
	yield($AnimatedSprite, 'animation_finished')
	gm.cam.shake()
	$AnimatedSprite.play("atk2")
	
	# spawn beam
	SoundManager.play("beam")
	var b = gm.instantiate(beam)
	b.rotation = angle
	b.position = position
	
	yield($AnimatedSprite, 'animation_finished')
	$AnimatedSprite.play("idle")
	
	# damage enemies
	var enemies = b.get_overlapping_bodies()
	for enemy in enemies:
		if isCosmic:
			enemy.damage(5)
		else:
			enemy.damage(2)
		
	yield(get_tree().create_timer(1.0), "timeout")
	
func damage(amount):
	SoundManager.play("playerHurt")
	yield(VisualServer, 'frame_pre_draw')
	if isShield:
		var s = shieldHitPrefab.instance()
		add_child(s)
		s.position = Vector2()
		off_shield()
	else:
		.damage(amount)


func get_shield():
	gm.heartIcon.play("shieldOn")
	
	if not isShield:
		SoundManager.play("shield")
	isShield = true
	

func off_shield():
	gm.heartIcon.play("shieldOff")
	isShield = false

func set_default_flip():
	$AnimatedSprite.flip_h = true
	
func _update_flip(angle):
	if angle < PI/2 and angle > -PI/2:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false

func change_health(amount):
	health += amount
	if health > max_health:
		gm.show_warning("you are already on full health")
	health = clamp(health, 0, max_health)
	healthText.text = str(health) + "/" + str(max_health)

func change_max_health(amount):
	.change_max_health(amount)
	healthText.text = str(health) + "/" + str(max_health)
