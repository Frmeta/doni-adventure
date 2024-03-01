extends KinematicBody2D


func _ready():
	# play animation player winning/horraying
	var targetPosition = Vector2(-3, 0) * 80 + Vector2.RIGHT * 1100
	
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", targetPosition, 2)
	tween.tween_callback(self, "queue_free")
