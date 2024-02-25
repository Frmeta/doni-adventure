extends Area2D


var speed = 1200
var atk_damage = 1

signal hit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	position = position + Vector2.RIGHT.rotated(rotation) * speed * delta


func _on_Fire_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if area.name == "GameArea":
		emit_signal("hit")
		self.queue_free()


func _on_Fire_body_entered(body):
	body.damage(atk_damage)
	emit_signal("hit")
	self.queue_free()
