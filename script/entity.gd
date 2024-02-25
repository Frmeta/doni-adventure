extends KinematicBody2D

export var max_health := 5
export var atk_damage := 2

export var bullet : PackedScene

onready var deathParticle = preload("res://prefab/deathParticle.tscn")

var healthText

var gm
var pos
var health
var speed := 1000


signal onTarget

func _ready():
	health = max_health

func _physics_process(delta):
	var target = gm.pos_to_position(pos)
	position = position.move_toward(target, speed * delta)
	if position == target:
		emit_signal("onTarget")
		
		if is_instance_valid(gm.player):
			if gm.player == self:
				$AnimatedSprite.flip_h = false
			elif pos.y > gm.player.pos.y:
				$AnimatedSprite.flip_h = false
			elif pos.y < gm.player.pos.y:
				$AnimatedSprite.flip_h = true
			
func set_pos(p):
	pos = p


func damage(amount):
	
	# change health
	health -= amount
	healthText.text = str(health)
	
	# hurt animation
	$AnimatedSprite.play("hurt")
	yield($AnimatedSprite, "animation_finished")
	
	# death
	if health <= 0:
		# spawn particle
		var p = deathParticle.instance()
		gm.add_child(p)
		p.emitting = true
		p.position = position
		
		
		gm.entity_died(self)
		self.queue_free()
	else:
		$AnimatedSprite.play("idle")
