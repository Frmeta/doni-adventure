extends KinematicBody2D

export var max_health := 5
export var atk_damage := 2
export var move_step := 2 # enemy only

onready var healthText = get_node("HealthText/Text")

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

func get_movement():
	var output := []
	
	output.append(pos + Vector2.UP)
	output.append(pos + Vector2.RIGHT)
	output.append(pos + Vector2.LEFT)
	output.append(pos + Vector2.DOWN)
	
	output = gm.filter(output)
			
	for i in range(output.size()):
		output.append(output[i] + Vector2.UP)
		output.append(output[i] + Vector2.RIGHT)
		output.append(output[i] + Vector2.LEFT)
		output.append(output[i] + Vector2.DOWN)
	
	output = gm.filter(output)
	
	return output

func damage(amount):
	# hurt animation
	health -= amount
	print("player hurt " + str(amount))
	healthText.text = str(health)
	

