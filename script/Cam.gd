extends Node2D


var speed := 1000

var target = Vector2(0, 100)

# signal onTarget


func _physics_process(delta):
	position = position.move_toward(target, speed * delta)
	
	# if position == target:
		# emit_signal("onTarget")

func shake():
	$AnimationPlayer.play("shake")
