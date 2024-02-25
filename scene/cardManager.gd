extends Node2D

class_name CardManager
enum CardType {AXE, SWORD, BEAM, COSMIC, DRAW_FOUR, STUN, MOVE, SHIELD, SHUFFLE, METEOR, TELEPORT, EARTHQUAKE}

var gm

var cardPrefab = preload("res://prefab/card.tscn")

export var cardTitles: PoolStringArray = []
export var cardDesc: PoolStringArray = []
export (Array, Texture) var cardTextures

var jarak = 250

var cards = []

func _ready():
	randomize()
	pass

func enable():
	pass


func disable():
	pass
	
func _physics_process(delta):
	var anak = get_children()
	var size = anak.size()
	for i in range(size):
		anak[i].position = Vector2((float(i)-(float(size)-1)/2) * jarak, 0)

func get_card():
	print("getcard")
	var cardType = randi() % CardType.size()
	
	var c = cardPrefab.instance()
	add_child(c)
	c.get_node("TitleLabel").text = cardTitles[cardType]
	c.get_node("DescLabel").text = cardDesc[cardType]
	c.get_node("Sprite").texture = cardTextures[cardType]
	c.cardType = cardType
	c.cm = self
	
	cards.append(c)
	
func use_card(card):
	var player = gm.player
	match card.cardType:
		CardType.AXE:
			for enemy in gm.enemies:
				if abs(enemy.pos.x - player.pos.x) <= 1 and abs(enemy.pos.y - player.pos.y) <= 1:
					enemy.damage(5)
			
		CardType.SWORD:
			var best_score = INF
			var best_enemy = gm.enemies[0]
			for enemy in gm.enemies:
				var jarak = enemy.distance_to(player)
				if jarak < best_score:
					best_enemy = enemy
			best_enemy.damage(5)
					
		CardType.BEAM:
			gm.atkButton.disabled = true
			gm.playerAtkLine.visible = true

			var angle = yield(gm.playerAtkLine, "click")
			
			gm.atkButton.disabled = true
			gm.playerAtkLine.visible = true
			
			# Player attack animation
			yield(player.beam_attack(angle), "completed")
		
			
		CardType.DRAW_FOUR:
			for i in range(4):
				get_card()

	
