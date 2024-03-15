extends Node2D

class_name CardManager
enum CardType {AXE, SWORD, BEAM, COSMIC, DRAW, STUN, HEALTHY, SHIELD, SHUFFLE, METEOR, TELEPORT, EARTHQUAKE, ASCEND}

var gm

var cardPrefab = preload("res://prefab/card.tscn")
var stunPrefab := preload("res://prefab/stun.tscn")
var meteorPrefab := preload("res://prefab/meteor.tscn")

export var cardTitles: PoolStringArray = []
export var cardDesc: PoolStringArray = []
export (Array, Texture) var cardTextures
export (CardType) var cheatCard

var jarak = 190
var temp_jarak
var moveSpeed = 0.5

var cards = []
var ada_shield = false

var idx_hover_right = -1
var idx_hover_right_prev = -1

func _ready():
	randomize()
	for _i in range(3):
		get_card()

func enable():
	pass


func disable():
	pass
	
func _physics_process(_delta):
	
	
	if cards.size() <= 5:
		temp_jarak = jarak
	else:
		temp_jarak = 200*5/cards.size()
	
	var anak = get_children()
	var size = anak.size()
	
	# index hover trakhir
	idx_hover_right = -1
	for i in range(size):
		if anak[i].is_hover:
			idx_hover_right = i
	
	if idx_hover_right != idx_hover_right_prev:
		if idx_hover_right != -1:
			SoundManager.play("cardHover")
		idx_hover_right_prev = idx_hover_right
	
	for i in range(size):
		var ketinggian
		
		if i == idx_hover_right:
			ketinggian = -120
			anak[i].z_index = 2
		else:
			ketinggian = -80
			anak[i].z_index = 0
		
		
		var target = Vector2((float(i)-(float(size)-1)/2) * temp_jarak, ketinggian) + gm.get_node("Cam").position
		anak[i].position = lerp(anak[i].position, target, moveSpeed)
		
		

func get_card_type(cardType):
	
	if cardType == CardType.SHIELD:
		ada_shield = true
		
	if cards.size() < 10:
	
		var c = cardPrefab.instance()
		call_deferred("add_child", c)
		
		c.get_node("TitleLabel").text = cardTitles[cardType]
		c.get_node("DescLabel").text = cardDesc[cardType]
		c.get_node("Sprite").texture = cardTextures[cardType]
		c.cardType = cardType
		c.cm = self
		c.position = Vector2()
		
		cards.append(c)
	
	else:
		gm.show_warning("YOU HAVE REACHED THE MAXIMUM NUMBER OF CARDS")
	
	
func get_card():
	var cardType = randi() % CardType.size()

	if cardType == CardType.SHIELD and ada_shield:
		cardType = (cardType + (CardType.size()-1)) % CardType.size()
			
	get_card_type(cardType)

func draw_card():
	var cardType = randi() % CardType.size()

	if cardType == CardType.SHIELD and ada_shield:
		cardType = (cardType + (CardType.size()-1)) % CardType.size()
	
	if cardType == CardType.DRAW:
		cardType = (cardType + (CardType.size()-1)) % CardType.size()
			
	get_card_type(cardType)
	
func use_card():
	if idx_hover_right < 0:
		return
		
	var player = gm.player
	var card = cards[idx_hover_right]
	var cardType = card.cardType
	
	if cardType == CardType.SHIELD and player.isShield:
		gm.show_warning("you already have shield")
		return
	
	SoundManager.play("selectCard")
		
	
	cards.erase(card)
	card.queue_free()
	
	idx_hover_right = -1
	
	
	
	
	
	gm.atkButton.disabled = true
	gm.is_card_usable = false
	
	
	
	match cardType:
		CardType.AXE:
			var playerAnim = player.get_node("AnimatedSprite")
			playerAnim.play("axe")
			yield (playerAnim, "animation_finished")
			SoundManager.play("axe")
			playerAnim.play("idle")
			
			for enemy in gm.enemies:
				if abs(enemy.pos.x - player.pos.x) <= 1 and abs(enemy.pos.y - player.pos.y) <= 1:
					enemy.damage(4)
			yield(get_tree().create_timer(1.0), "timeout")
			
		CardType.SWORD:
			var best_score = INF
			var best_enemy = gm.enemies[0]
			for enemy in gm.enemies:
				var jarakk = enemy.position.distance_to(player.position)
				if jarakk < best_score:
					best_enemy = enemy
					best_score = jarakk
			yield(best_enemy.damage(3), "completed")
					
		CardType.BEAM:
			gm.playerAtkLine.visible = true
			gm.playerAtkLine.isTembus = true

			yield (VisualServer, 'frame_pre_draw')
			var angle = yield(gm.playerAtkLine, "click")
			
			gm.playerAtkLine.visible = false
			gm.playerAtkLine.isTembus = false
			
			yield(player.tembus_attack(angle, false), "completed")
			
		CardType.COSMIC:
			gm.playerAtkLine.visible = true
			gm.playerAtkLine.isTembus = true

			yield (VisualServer, 'frame_pre_draw')
			var angle = yield(gm.playerAtkLine, "click")
			
			gm.atkButton.disabled = false
			gm.playerAtkLine.visible = false
			gm.playerAtkLine.isTembus = false
			
			yield(player.tembus_attack(angle, true), "completed")
			
		
			
		CardType.DRAW:
			# draw three
			SoundManager.play("card")
			for _i in range(3):
				draw_card()
				
		CardType.STUN:
			
			#  Wait for click on kotak
			gm.clickablePos = get_every_enemy_pos()
			var clickPos = yield(gm, "kotak_clicked_signal")
			gm.clickablePos = []
			gm.atkButton.disabled = false
			
			# spawn stunPrefab
			SoundManager.play("stun")
			var stun = gm.instantiate(stunPrefab)
			stun.position = gm.pos_to_position(clickPos)
			
			# Stun & deal damage 1
			var korban = gm.board[clickPos.x][clickPos.y]
			if is_instance_valid(korban):
				korban.stun()
			
			
		CardType.HEALTHY:
			SoundManager.play("heal")
			gm.player.heal(5)
			
		CardType.ASCEND:
			SoundManager.play("heal")
			gm.player.ascend(2)
			
			
		CardType.SHIELD:
			ada_shield = false
			player.get_shield()
			
		CardType.SHUFFLE:
			gm.cam.shake()
			SoundManager.play("card")
			var c = cards.size()
			for i in cards:
				i.queue_free()
			cards = []
			for _i in range(c+1):
				draw_card()
				
		CardType.METEOR:
			
			#  Wait for click on kotak
			gm.clickablePos = get_every_inside_pos()
			var clickPos = yield(gm, "kotak_clicked_signal")
			gm.clickablePos = []
			
			# Spawn meteor
			gm.cam.shake()
			SoundManager.play("meteor")
			var m = gm.instantiate(meteorPrefab)
			m.position = gm.pos_to_position(clickPos)
			
			# get 3x3 area
			var poss = []
			for i in range(-1, 2):
				for j in range(-1, 2):
					poss.append(clickPos + Vector2(i, j))
			poss = gm.filter_inside_board(poss)
			
			# deal damage
			for p in poss:
				var obj = gm.board[p.x][p.y]
				if is_instance_valid(obj) and obj != player and not obj.is_in_group("cardItem"):
					obj.damage(2)
				
			
		CardType.TELEPORT:
			
			#  Wait for click on walkable kotak
			gm.clickablePos = get_every_pos()
			gm.clickablePos = gm.filter(gm.clickablePos, true)
			var clickPos = yield(gm, "kotak_clicked_signal")
			gm.clickablePos = []
			
			# move it
			gm.cam.shake()
			player.position = gm.pos_to_position(clickPos)
			yield(gm.move_entity(player, clickPos), "completed")
			
			
		CardType.EARTHQUAKE:
			for enemy in gm.enemies:
				enemy.damage(1)
		

	yield(get_tree().create_timer(0.7), "timeout")
	
	gm.atkButton.disabled = false
	gm.is_card_usable = true
	
	if gm.enemies.size() == 0: # cards.size() == 0 or
		gm.emit_signal("attack_clicked_signal")
	
	if cards.size() == 0:
		gm.show_warning("YOU HAVE NO CARDS LEFT, CLICK THE ATTACK BUTTON")
	
	# print(cards)

func _on_Button_pressed():
	# cheat button
	get_card()
	# get_card_type(cheatCard)
	
	# for enemy in gm.enemies:
	#	enemy.damage(5)
	
	# gm.current_level += 5

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
