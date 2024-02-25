extends Area2D

signal get_card

func _ready():
	pass


func _on_Card_item_body_entered(body):
	if body.name == "Player":
		#  and body.gm.pos_to_position(body.pos) == body.position
		body.emit_signal("get_card")
		queue_free()
