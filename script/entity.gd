extends KinematicBody2D

export var max_health := 5
export var atk_damage := 2

export var bullet : PackedScene

var deathParticle = preload("res://prefab/deathParticle.tscn")
var damageParticle = preload("res://prefab/DamageParticle.tscn")
var healPrefab := preload("res://prefab/Heal.tscn")

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
		
func set_pos(p):
	pos = p


func damage(amount):
	
	gm.cam.shake()
	# change health
	change_health(-amount)
	
	# spawn damage particle
	var d = gm.instantiate(damageParticle)
	d.position = position
	if $AnimatedSprite.flip_h:
		d.get_node("Particle").rotation_degrees = 180
	d.get_node("TextNode/Text").text = "-" + str(amount)
	
	
	# hurt animation
	if (not "isStun" in self) or not self.isStun:
		$AnimatedSprite.play("hurt")
		yield($AnimatedSprite, "animation_finished")
	yield(VisualServer, "frame_pre_draw")
	
	# death
	if health <= 0:
		# spawn particle
		var p = deathParticle.instance()
		gm.add_child(p)
		p.emitting = true
		p.position = position
		
		SoundManager.play("death")
		gm.entity_died(self)
		self.queue_free()
	else:
		$AnimatedSprite.play("idle")

func change_health(amount):
	health += amount
	health = clamp(health, 0, max_health)
	healthText.text = str(health)
	
func change_max_health(amount):
	max_health += amount
	
func heal(amount):
	change_health(amount)
	
	# spawn heal particle
	var s = healPrefab.instance()
	add_child(s)
	s.position = Vector2()

func ascend(amount):
	change_max_health(amount)
	
	# spawn heal particle
	var s = healPrefab.instance()
	add_child(s)
	s.position = Vector2()
