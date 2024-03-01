extends Node2D

var spawnParticlePrefab := preload("res://prefab/SpawnParticle.tscn")

var kotakPrefab := preload("res://prefab/kotak.tscn")

var playerPrefab := preload("res://prefab/player.tscn")
var eyeballPrefab := preload("res://prefab/eyeball.tscn")
var goblinPrefab := preload("res://prefab/goblin.tscn")
var archerPrefab := preload("res://prefab/archer.tscn")
var cardItemPrefab := preload("res://prefab/cardItem.tscn")

var kotakDecorPrefab := preload("res://prefab/kotakDecor.tscn")
var playerDecorPrefab := preload("res://prefab/playerDecor.tscn")


onready var atkButton = $AttackButton
onready var healthText = $CanvasLayer/HealthText
onready var playerAtkLine = $PlayerAtkLine
onready var heartIcon = $CanvasLayer/HeartIcon
onready var cam = $Cam

var spacing = 80

var player

signal kotak_clicked_signal
signal attack_clicked_signal


var board = []
var clickablePos = []
var enemies = []


var is_card_usable = false


var distance_to_next_level = 1100
var current_level = 1

func _ready():
	# Setup reference
	$CardManager.gm = self
	level_start()
	
	

func level_start():
	
	# Init 2d array
	board = []
	for i in range(5):
		board.append([])
		for _j in range(11):
			board[i].append(null)
	
	# Clear kotak
	for kotak in get_tree().get_nodes_in_group("kotak"):
		kotak.queue_free()
		
	# Clear card item
	for ci in get_tree().get_nodes_in_group("cardItem"):
		ci.queue_free()
	
	# Setup kotak 5 x 11
	for i in range(5):
		for j in range(11):
			var instance = instantiate(kotakPrefab)
			instance.position = Vector2(j-5, i-2) * spacing
			instance.gm = self
			instance.pos = Vector2(i, j)
			instance.connect("clicked", self, "kotak_clicked")
		
		
	# Setup kotak decor for next level
	for i in range(5):
		for j in range(11):
			var instance = instantiate(kotakDecorPrefab)
			instance.position = Vector2(j-5, i-2) * spacing + Vector2.RIGHT * distance_to_next_level
			
			instance = instantiate(kotakDecorPrefab)
			instance.position = Vector2(j-5, i-2) * spacing + Vector2.LEFT * distance_to_next_level
			
			instance = instantiate(kotakDecorPrefab)
			instance.position = Vector2(j-5, i-2) * spacing + Vector2.RIGHT *2 * distance_to_next_level
	
	
	# Spawn player
	if is_instance_valid(player):
		var spawnPos = Vector2(2, 2)
		player.position = pos_to_position(spawnPos)
		player.set_pos(spawnPos)
		board[spawnPos.x][spawnPos.y] = player
	else:
		player = spawn_entity(playerPrefab, Vector2(2, 2))
	
		# init healthText
		player.healthText = healthText
		healthText.text = str(player.max_health)
	player.get_node("AnimatedSprite").play("idle")
	
	
	# Spawn enemies
	var eyeball = spawn_entity(eyeballPrefab, Vector2(1, 9))
	enemies.append(eyeball)
	# eyeball = spawn_entity(archerPrefab, Vector2(3, 9))
	# enemies.append(eyeball)
	
	
	
	# Spawn cardItem
	for _i in range(5):
		while (true):
			var a = randi() % 5 
			var b = randi() % 11
			if board[a][b] == null:
				spawn_entity(cardItemPrefab, Vector2(a, b))
				break
	
	
	
	atkButton.disabled = true
	
	# Game loop
	while true:

		# Wait for player move
		var clickPos = player.pos
		clickablePos = player.get_movement()
		if clickablePos.size() > 0:
			clickPos = yield(self, "kotak_clicked_signal")
		clickablePos = []
			

		# move slowly
		yield (move_entity(player, clickPos), "completed")
		yield(get_tree().create_timer(0.1), "timeout")
		
		# Player pick card
		if $CardManager.cards.size() > 0:
			atkButton.disabled = false
			is_card_usable = true
			get_tree().call_group("kotak", "set_type", Kotak.HighlightType.DISABLED)
			
			yield(self, "attack_clicked_signal")
			
			atkButton.disabled = true
			is_card_usable = false
		
		if enemies.size() == 0:
			break
		
		# Player attack line
		playerAtkLine.visible = true
		var angle = yield(playerAtkLine, "click")
		
		# Player attack animation
		playerAtkLine.visible = false
		yield(player.attack_enemy(angle), "completed")
		
		
		
		if enemies.size() == 0:
			break
			
		# Enemies' turn
		for enemy in enemies:
			
			# Handle enemy stun
			if enemy.isStun:
				enemy.unstun()
				continue
			
			# Enemy move
			var targetPos = enemy.get_movement()[0]
			yield(move_entity(enemy, targetPos), "completed")
			
			# Enemy attack
			yield(enemy.attack_player(), "completed")
		
		
		# Losing
		if not is_instance_valid(player) or player.health <= 0:
			print("Player lose")
			
	
	print("next level")
	
	# win animation
	player.get_node("AnimatedSprite").play("win")
	yield(player.get_node("AnimatedSprite"), "animation_finished")
	yield(get_tree().create_timer(1), "timeout")
	
	
	# Spawn player running
	player.visible = false
	var pd = playerDecorPrefab.instance()
	add_child(pd)
	pd.position = player.position
	cam.target = Vector2(distance_to_next_level, 100)
	
	yield(pd, "tree_exiting")
	
	player.visible = true
	cam.position = Vector2(0, 100)
	cam.target = Vector2(0, 100)
	
	# Level Start
	current_level += 1
	level_start()

func entity_died(obj):
	# remove at board
	for i in range(5):
		for j in range(11):
			if board[i][j] == obj:
				board[i][j] = null
	
	
	if obj == player:
		# player death
		pass
	else:
		# enemy death
		var idx = enemies.find(obj)
		enemies.remove(idx)
			
		
	

func spawn_entity(prefab, pos):
	
	# spawn particle
	var p = instantiate(spawnParticlePrefab)
	p.position = pos_to_position(pos)
	p.get_node("AnimationPlayer").play("spawn")
	
	# spawn object
	var obj = instantiate(prefab)
	obj.position = pos_to_position(pos)
	if obj.has_method("set_pos"):
		obj.gm = self
		obj.set_pos(pos)
	board[pos.x][pos.y] = obj
	
	return obj

func move_entity(entity, targetPos):
	board[entity.pos.x][entity.pos.y] = null
	board[targetPos.x][targetPos.y] = entity
	
	entity.set_pos(targetPos)
	
	yield(entity, "onTarget")

func kotak_clicked(pos):
	emit_signal("kotak_clicked_signal", pos)


func _on_TextureButton_pressed():
	emit_signal("attack_clicked_signal")
	
func instantiate(prefab):
	var obj = prefab.instance();
	add_child(obj)
	return obj
	
func pos_to_position(pos):
	return (Vector2(pos.y-5, pos.x-2)) * spacing

func filter(list_of_pos, isPlayer):
	var ans = []
	list_of_pos = filter_inside_board(list_of_pos)
	for o in list_of_pos:
		if o.x >= 0 and o.y >= 0 and o.x <= 4 and o.y <= 10:
			if not is_instance_valid(board[o.x][o.y]) or (isPlayer and board[o.x][o.y].is_in_group("cardItem")):
				ans.append(o)
	return ans

func filter_inside_board(list_of_pos):
	var ans = []
	for o in list_of_pos:
		if o.x >= 0 and o.y >= 0 and o.x <= 4 and o.y <= 10:
			ans.append(o)
	return ans
