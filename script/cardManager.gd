extends Node2D

class_name CardManager
enum CardType {AXE, SWORD, BEAM, COSMIC, DRAW_FOUR, STUN, MOVE, SHIELD, SHUFFLE, METEOR, TELEPORT, EARTHQUAKE}

var gm

var cardPrefab = preload("res://prefab/card.tscn")
var stunPrefab := preload("res://prefab/stun.tscn")
var meteorPrefab := preload("res://prefab/meteor.tscn")

export var cardTitles: PoolStringArray = []
export var cardDesc: PoolStringArray = []
export (Array, Texture) var cardTextures
export (CardType) var cheatCard

var jarak = 180
var moveSpeed = 0.5

var cards = []

func _ready():
	randomize()
	pass

func enable():
	pass


func disable():
	pass
	
func _physics_process(_delta):
	var anak = get_children()
	var size = anak.size()
	for i in range(size):
		var target = Vector2((float(i)-(float(size)-1)/2) * jarak, -100) + gm.get_node("Cam").position
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
	gm.atkButton.disabled = true
	gm.is_card_usable = false
	
	var player = gm.player
	cards.erase(card)
	
	
	match card.cardType:
		CardType.AXE:
			var playerAnim = player.get_node("AnimatedSprite")
			playerAnim.play("axe")
			yield (playerAnim, "animation_finished")
			playerAnim.play("idle")
			
			for enemy in gm.enemies:
				if abs(enemy.pos.x - player.pos.x) <= 1 and abs(enemy.pos.y - player.pos.y) <= 1:
					enemy.damage(5)
			
		CardType.SWORD:
			var best_score = INF
			var best_enemy = gm.enemies[0]
			for enemy in gm.enemies:
				var jarakk = enemy.position.distance_to(player.position)
				if jarakk < best_score:
					best_enemy = enemy
			best_enemy.damage(3)
					
		CardType.BEAM:
			gm.playerAtkLine.visible = true

			yield (VisualServer, 'frame_pre_draw')
			var angle = yield(gm.playerAtkLine, "click")
			
			gm.playerAtkLine.visible = false
			
			# TODO: Player attack animation
			yield(player.tembus_attack(angle, false), "completed")
			
		CardType.COSMIC:
			gm.playerAtkLine.visible = true

			yield (VisualServer, 'frame_pre_draw')
			var angle = yield(gm.playerAtkLine, "click")
			
			gm.atkButton.disabled = false
			gm.playerAtkLine.visible = false
			
			# TODO: Player attack animation
			yield(player.tembus_attack(angle, true), "completed")
			
		
			
		CardType.DRAW_FOUR:
			for _i in range(4):
				get_card()
				
		CardType.STUN:
			
			#  Wait for click on kotak
			gm.clickablePos = get_every_enemy_pos()
			var clickPos = yield(gm, "kotak_clicked_signal")
			
			
			gm.clickablePos = []
			gm.atkButton.disabled = false
			
			# spawn stunPrefab
			gm.cam.shake()
			var stun = gm.instantiate(stunPrefab)
			stun.position = gm.pos_to_position(clickPos)
			
			var korban = gm.board[clickPos.x][clickPos.y]
			if is_instance_valid(korban):
				korban.stun()
			
			
		CardType.MOVE:
			pass
			
		CardType.SHIELD:
			gm.player.get_shield()
			
		CardType.SHUFFLE:
			var c = cards.size()
			for i in cards:
				i.queue_free()
			cards = []
			for _i in range(c):
				get_card()
				
		CardType.METEOR:
			
			#  Wait for click on kotak
			gm.clickablePos = get_every_inside_pos()
			var clickPos = yield(gm, "kotak_clicked_signal")
			gm.clickablePos = []
			
			# Spawn meteor
			var m = gm.instantiate(meteorPrefab)
			m.position = gm.pos_to_position(clickPos)
			gm.cam.shake()
			
			# get 3x3 area
			var poss = []
			for i in range(-1, 2):
				for j in range(-1, 2):
					poss.append(clickPos + Vector2(i, j))
			poss = gm.filter_inside_board(poss)
			
			# deal damage
			for p in poss:
				var obj = gm.board[p.x][p.y]
				if is_instance_valid(obj) and obj != gm.player and not obj.is_in_group("cardItem"):
					obj.damage(2)
				
			
		CardType.TELEPORT:
			
			#  Wait for click on walkable kotak
			gm.clickablePos = get_every_pos()
			gm.clickablePos = gm.filter(gm.clickablePos, true)
			var clickPos = yield(gm, "kotak_clicked_signal")
			gm.clickablePos = []
			
			
		CardType.EARTHQUAKE:
			gm.cam.shake()
			for enemy in gm.enemies:
				enemy.damage(1)
			

	yield(get_tree().create_timer(1), "timeout")
	
	gm.atkButton.disabled = false
	gm.is_card_usable = true
	
	if cards.size() == 0 or gm.enemies.size() == 0:
		gm.emit_signal("attack_clicked_signal")


func _on_Button_pressed():
	# cheat button
	get_card_type(cheatCard)

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

func get_every_inside_pos():
	var ans = []
	for i in range(1, 4):
		for j in range(1, 10):
			ans.append(Vector2(i, j))
	return ans
