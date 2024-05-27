extends Node2D

var spawnParticlePrefab := preload("res://prefab/SpawnParticle.tscn")

var kotakPrefab := preload("res://prefab/kotak.tscn")

var playerPrefab := preload("res://prefab/player.tscn")
var eyeballPrefab := preload("res://prefab/eyeball.tscn")
var goblinPrefab := preload("res://prefab/goblin.tscn")
var archerPrefab := preload("res://prefab/archer.tscn")
var mochiPrefab := preload("res://prefab/mochi.tscn")
var eggPrefab := preload("res://prefab/egg.tscn")
var pekkaPrefab := preload("res://prefab/pekka.tscn")
var hawkeyePrefab := preload("res://prefab/hawkeye.tscn")


var cardItemPrefab := preload("res://prefab/cardItem.tscn")

var kotakDecorPrefab := preload("res://prefab/kotakDecor.tscn")
var playerDecorPrefab := preload("res://prefab/playerDecor.tscn")


var enemyScript := preload("res://script/enemy.gd")


onready var atkButton = $CanvasLayer/AttackButton
onready var healthText = $CanvasLayer/HealthText
onready var playerAtkLine = $PlayerAtkLine
onready var heartIcon = $CanvasLayer/HeartIcon
onready var cam = $Cam
onready var levelText = $CanvasLayer/LevelImg/LevelText
onready var transition = $CanvasLayer/Transition
onready var retryButton = $"CanvasLayer/LoseScreen/Retry Button"
onready var loseScreenAnimationPlayer := $CanvasLayer/LoseScreen/AnimationPlayer
onready var warningAnim = $CanvasLayer/Warning/AnimationPlayer
onready var warningText = $CanvasLayer/Warning/text

onready var pauseScreen := $CanvasLayer/PauseScreen
onready var continueButton := $CanvasLayer/PauseScreen/ContinueButton
onready var mainMenuButton := $CanvasLayer/PauseScreen/MainMenuButton


var spacing = 80

var player

signal kotak_clicked_signal
signal attack_clicked_signal


var board = []
var clickablePos = []
var enemies = []


var is_card_usable = false


var distance_to_next_level = 1100
export var current_level = 1
var cardItemCount = 0


func _ready():
	# Setup reference
	$CardManager.gm = self
	level_start()
	
	# retry button
	retryButton.connect("pressed", self, "go_to_scene", ["Level"])
	
	
	# game music
	SoundManager.play("bgMusic")


func level_start():
	
	levelText.text = "LEVEL " + str(current_level)
	
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
	cardItemCount = 0
	
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
	
	
	var playerSpawnPos = Vector2(2, 2)
	
	# Spawn player
	if is_instance_valid(player):
		player.position = pos_to_position(playerSpawnPos)
		player.set_pos(playerSpawnPos)
		board[playerSpawnPos.x][playerSpawnPos.y] = player
		player.set_default_flip()
	else:
		player = spawn_entity(playerPrefab, playerSpawnPos) 
	
		# init healthText
		player.healthText = healthText
		player.change_health(0)
	player.get_node("AnimatedSprite").play("idle")
	
	
	
	yield (get_tree().create_timer(1.0), "timeout")
	
	# Spawn enemies
	var prefabs = generate_enemies()
	for prefab in prefabs:
		while true:
			var a = randi() % 5 
			var b = randi() % 11
			if board[a][b] == null and playerSpawnPos.distance_to(Vector2(a,b)) > 1.9:
				spawn_entity(prefab, Vector2(a, b))
				break
	
	
	atkButton.disabled = true
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	# Game loop
	while true:
		
		# Spawn card items
		if cardItemCount <= 0:
			var cardsPrefab = generate_cardItem()
			for prefab in cardsPrefab:
				while true:
					var a = randi() % 5 
					var b = randi() % 11
					if board[a][b] == null:
						cardItemCount += 1
						spawn_entity(prefab, Vector2(a, b))
						break
						
		
			yield (get_tree().create_timer(1.0), "timeout")
		
		yield(transition.play(transition.TransitionStatus.PLAYER_TURN), "completed")

		# Wait for player move
		var clickPos = player.pos
		clickablePos = player.get_movement()
		if clickablePos.size() > 0:
			clickPos = yield(self, "kotak_clicked_signal")
		clickablePos = []
			

		# move slowly
		yield (move_entity(player, clickPos), "completed")
		SoundManager.play("move")
		yield(get_tree().create_timer(0.1), "timeout")
		
		# Player pick card
		if $CardManager.cards.size() == 0:
			show_warning("YOU HAVE NO CARDS LEFT, CLICK THE ATTACK BUTTON")
			
		atkButton.disabled = false
		is_card_usable = true
		get_tree().call_group("kotak", "set_type", Kotak.HighlightType.DISABLED)
		
		yield(self, "attack_clicked_signal")
		SoundManager.play("atkButton")
		
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
			
			
			
		# Enemy's turn
		yield(transition.play(transition.TransitionStatus.ENEMY_TURN), "completed")
		
		if is_instance_valid(player):
			var enemies_tmp = enemies.duplicate()
			for enemy in enemies_tmp:
				if player.health > 0:
					# Handle enemy stun
					if enemy.isStun:
						enemy.unstun()
						continue
					
					# Enemy move
					var targetPos = enemy.get_movement()[0]
					yield(move_entity(enemy, targetPos), "completed")
					if is_instance_valid(enemy): # handle egg
						SoundManager.play("move")
					
					# Enemy attack
					yield(enemy.attack_player(), "completed")
				
				
		
		
		yield(get_tree().create_timer(0.5), "timeout")
		
		
		# Losing
		if not is_instance_valid(player) or player.health <= 0:
			SoundManager.stop_all_sound()
			SoundManager.play("gameOver")
			loseScreenAnimationPlayer.play("show")
			yield(get_tree().create_timer(3600), "timeout")
			
			
	
	SoundManager.play("levelClear")
	yield(transition.play(transition.TransitionStatus.PLAYER_WIN), "completed")
	
	
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

func generate_enemies():
	var prefabs = []
	
	var total = round(sqrt(current_level))
	var kesusahan = pow(current_level, 2)/3/100
	print(kesusahan)
	
	
	# special level
	if current_level >= 5:
		if current_level % 5 == 1:
			for _i in range(total*3):
				prefabs.append(eggPrefab)
			return prefabs
		
		
	
	randomize()
	
	
	for _i in range(clamp(total, 1, 15)):
		var acak = randf()
		if current_level > 10 and acak < kesusahan/3:
			# super hard enemy
			acak = randi() % 2
			match acak:
				0:
					prefabs.append(pekkaPrefab)
				1:
					prefabs.append(hawkeyePrefab)
			
		elif acak < kesusahan:
			# hard enemy
			
			acak = randi() % 2
			match acak:
				0:
					prefabs.append(goblinPrefab)
				1:
					prefabs.append(mochiPrefab)
		else:
			# easy enemy
			
			acak = randi() % 2
			match acak:
				0:
					prefabs.append(archerPrefab)
				1:
					prefabs.append(eyeballPrefab)
					
		
	return prefabs

func generate_cardItem():
	var prefabs = []
	randomize()
	
	var cardItem = max(1, 5 - round(current_level/10))
	for _i in range(cardItem):
		prefabs.append(cardItemPrefab)
	
	return prefabs

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
	
	SoundManager.play("spawnBeam")
	
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
	
	# append to enemies
	if obj is enemyScript:
		enemies.append(obj)
	
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
	isPlayer = true
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

func go_to_scene(scene_name):
	SoundManager.stop_all_sound()
	get_tree().change_scene("res://scene/" + scene_name + ".tscn")


func show_warning(warning_msg):
	warningText.text = warning_msg
	warningAnim.play("bum")

