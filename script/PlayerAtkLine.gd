extends Node2D

onready var gm = get_node("..")

onready var ray = $RayCast2D
onready var line = $Line2D
onready var end = $End
onready var begin = $Begin

var length = 1400
var isTembus = false

signal click

func _ready():
	pass # Replace with function body.


func _process(_delta):
	
	if not is_instance_valid(gm.player):
		return
	
	position = gm.player.position
	ray.cast_to = get_local_mouse_position().normalized() * length
	begin.position = get_local_mouse_position().normalized() * 30
	
	if ray.is_colliding() and not isTembus:
		end.global_position = ray.get_collision_point()
	else:
		end.global_position = position + ray.cast_to
	
	line.set_point_position(0, begin.position)
	line.set_point_position(1, end.position)
	
	if Input.is_action_just_pressed("lmb"):
		emit_signal("click", ray.cast_to.angle())
