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
onready var healthText = $HealthText
onready var playerAtkLine = $PlayerAtkLine
onready var heartIcon = $HeartIcon

var spacing = 80

var player

signal kotak_clicked_signal
signal attack_clicked_signal


var board = []
var clickablePos = []
var enemies = []


var is_card_usable = false


var distance_to_next_level = 1100

func _ready():
	# Setup reference
	$CardManager.gm = self
	
	# Init 2d array
	for i in range(5):
		board.append([])
		for _j in range(11):
			board[i].append(null)
	
	
	
	# Setup board 5 x 9
	for i in range(5):
		for j in range(11):
			var instance = instantiate(kotakPrefab)
			instance.position = Vector2(j-5, i-2) * spacing
			instance.gm = self
			instance.pos = Vector2(i, j)
	var kotaks = get_tree().get_nodes_in_group("kotak")  
	for kotak in kotaks:  
		kotak.connect("clicked", self, "kotak_clicked")
		
		
	# Setup kotak decor for next level
	for i in range(5):
		for j in range(11):
			var instance = instantiate(kotakDecorPrefab)
			instance.position = Vector2(j-5, i-2) * spacing + Vector2.RIGHT * distance_to_next_level
			instance = instantiate(kotakDecorPrefab)
			instance.position = Vector2(j-5, i-2) * spacing + Vector2.LEFT * distance_to_next_level
	
	
	# Spawn player
	player = spawn_entity(playerPrefab, Vector2(2, 2))
	player.connect("get_card", $CardManager, "get_card")
	
	# init healthText
	player.healthText = healthText
	healthText.text = str(player.max_health)
	
	
	# Spawn enemy
	var eyeball = spawn_entity(eyeballPrefab, Vector2(1, 9))
	enemies.append(eyeball)
	
	eyeball = spawn_entity(archerPrefab, Vector2(3, 9))
	enemies.append(eyeball)
	
	# Spawn card
	for i in range(5):
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
		board[player.pos.x][player.pos.y] = null
		
		var clickPos = player.pos
		clickablePos = player.get_movement()
		if clickablePos.size() > 0:
			clickPos = yield(self, "kotak_clicked_signal")
		clickablePos = []
			

		# move slowly
		player.set_pos(clickPos)
		board[clickPos.x][clickPos.y] = player
		yield(player, "onTarget")
		yield(get_tree().create_timer(0.1), "timeout")
		
		# Player pick card
		if $CardManager.cards.size() > 0:
			atkButton.disabled = false
			is_card_usable = true
			get_tree().call_group("kotak", "set_type", Kotak.HighlightType.DISABLED)
			yield(self, "attack_clicked_signal")
			atkButton.disabled = true
			is_card_usable = false
		
		# Player attack line
		playerAtkLine.visible = true
		var angle = yield(playerAtkLine, "click")
		
		# Player attack animation
		playerAtkLine.visible = false
		yield(player.attack_enemy(angle), "completed")
		
		
		
		
		# Enemies' turn
		for enemy in enemies:
			
			# Handle enemy stun
			if enemy.isStun:
				enemy.unstun()
				continue
			
			# Enemy move
			board[enemy.pos.x][enemy.pos.y] = null
			var targetPos = enemy.get_movement()[0]
			enemy.set_pos(targetPos)
			board[enemy.pos.x][enemy.pos.y] = enemy
			yield(enemy, "onTarget")
			
			# Enemy attack
			yield(enemy.attack_player(), "completed")
		
		
		# Losing
		if not is_instance_valid(player) or player.health <= 0:
			break
			
	print("Player lose")

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
		print("sisa enemy: " + str(enemies.size()))
		# next level
		if enemies.size() == 0:
			print("next level")
			var pd = playerDecorPrefab.instance()
			add_child(pd)
			pd.position = player.position
			pass
		
	

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
