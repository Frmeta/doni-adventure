extends Node2D

onready var gm = get_node("..")

onready var ray = $RayCast2D
onready var line = $Line2D
onready var end = $Position2D

var length = 800
var isTembus = false

signal click

func _ready():
	pass # Replace with function body.


func _process(delta):
	
	if not is_instance_valid(gm.player):
		return
	
	position = gm.player.position
	
	ray.cast_to = get_local_mouse_position().normalized() * length
	
	if ray.is_colliding() and not isTembus:
		end.global_position = ray.get_collision_point()
	else:
		end.global_position = ray.cast_to
	
	# line.set_point_position(0, gm.pos_to_position(gm.player.pos))
	line.set_point_position(1, end.position)
	
	if Input.is_action_just_pressed("lmb"):
		emit_signal("click", ray.cast_to.angle())
