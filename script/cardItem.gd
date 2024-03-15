extends Area2D


func _ready():
	pass


func _on_Card_item_body_entered(body):
	if body.name == "Player":
		SoundManager.play("getCard")
		body.gm.cardItemCount -= 1
		body.gm.get_node("CardManager").get_card()
		queue_free()
