extends Node2D

class_name CardManager
enum CardType {AXE, SWORD, BEAM, COSMIC, DRAW_FOUR, STUN, MOVE, SHIELD, SHUFFLE, METEOR, TELEPORT, EARTHQUAKE}

var gm

var cardPrefab = preload("res://prefab/card.tscn")

export var cardTitles: PoolStringArray = []
export var cardDesc: PoolStringArray = []
export (Array, Texture) var cardTextures

var jarak = 200
var moveSpeed = 0.5

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
		var target = Vector2((float(i)-(float(size)-1)/2) * jarak, 0)
		anak[i].position = lerp(anak[i].position, target, moveSpeed)

func get_card_type(cardType):
	var c = cardPrefab.instance()
	add_child(c)
	c.get_node("TitleLabel").text = cardTitles[cardType]
	c.get_node("DescLabel").text = cardDesc[cardType]
	c.get_node("Sprite").texture = cardTextures[cardType]
	c.cardType = cardType
	c.cm = self
	
	cards.append(c)
	
	
func get_card():
	print("getcard")
	var cardType = randi() % CardType.size()
	get_card_type(cardType)
	
func use_card(card):
	var player = gm.player
	cards.erase(card)
	
	match card.cardType:
		CardType.AXE:
			print("axe")
			for enemy in gm.enemies:
				if abs(enemy.pos.x - player.pos.x) <= 1 and abs(enemy.pos.y - player.pos.y) <= 1:
					enemy.damage(5)
			
		CardType.SWORD:
			var best_score = INF
			var best_enemy = gm.enemies[0]
			for enemy in gm.enemies:
				var jarak = enemy.position.distance_to(player.position)
				if jarak < best_score:
					best_enemy = enemy
			best_enemy.damage(3)
					
		CardType.BEAM:
			gm.atkButton.disabled = true
			gm.playerAtkLine.visible = true

			yield (VisualServer, 'frame_pre_draw')
			var angle = yield(gm.playerAtkLine, "click")
			
			gm.atkButton.disabled = false
			gm.playerAtkLine.visible = false
			
			# TODO: Player attack animation
			yield(player.tembus_attack(angle, false), "completed")
			
		CardType.COSMIC:
			gm.atkButton.disabled = true
			gm.playerAtkLine.visible = true

			yield (VisualServer, 'frame_pre_draw')
			var angle = yield(gm.playerAtkLine, "click")
			
			gm.atkButton.disabled = false
			gm.playerAtkLine.visible = false
			
			# TODO: Player attack animation
			yield(player.tembus_attack(angle, true), "completed")
			
		
			
		CardType.DRAW_FOUR:
			for i in range(4):
				get_card()
				
		CardType.STUN:
			
			#  Wait for click on kotak
			gm.atkButton.disabled = true
			gm.clickablePos = get_every_enemy_pos()
			var clickPos = yield(gm, "kotak_clicked_signal")
			
			
			gm.clickablePos = []
			gm.atkButton.disabled = false
			
			# OPTIONAL: Player attack animation
			var korban = gm.board[clickPos.x][clickPos.y]
			if is_instance_valid(korban):
				korban.stun()
			
			
		CardType.MOVE:
			pass
			
		CardType.SHIELD:
			gm.player.get_shield()
			
		CardType.SHUFFLE:
			var c = cards.size()
			cards = []
			for i in range(c):
				get_card()
				
		CardType.METEOR:
			
			#  Wait for click on kotak
			gm.atkButton.disabled = true
			gm.clickablePos = get_every_pos()
			var clickPos = yield(gm, "kotak_clicked_signal")
			
			
			gm.clickablePos = []
			gm.atkButton.disabled = false
			
			# OPTIONAL: Player attack animation
			
			var poss = []
			for i in range(-1, 2):
				for j in range(-1, 2):
					poss.append(clickPos + Vector2(i, j))
			
			poss = gm.filter_inside_board(poss)
			var obj = gm.board[clickPos.x][clickPos.y]
			if is_instance_valid(obj) and obj != gm.player:
				gm.board[clickPos.x][clickPos.y].damage(2)
			
			pass
			
		CardType.TELEPORT:
			pass
			
		CardType.EARTHQUAKE:
			for enemy in gm.enemies:
				enemy.damage(1)
			

	yield(get_tree().create_timer(0.5), "timeout")
	
	if cards.size() == 0:
		gm.emit_signal("attack_clicked_signal")


func _on_Button_pressed():
	get_card()

func get_every_pos():
	var ans = []
	for i in range(5):
		for j in range(11):
			ans.append(Vector2(i, j))
	return ans

func get_every_enemy_pos():
	var ans = []
	for enemy in gm.enemies:
		ans.append(enemy.pos)
	return ans
