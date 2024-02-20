extends Node2D

var kotakPrefab := preload("res://prefab/kotak.tscn")
var playerPrefab := preload("res://prefab/player.tscn")
var eyeballPrefab := preload("res://prefab/eyeball.tscn")

onready var atkButton = $AttackButton
onready var healthBar = $HealthText/Text

var spacing = 80

var player

signal kotak_clicked_signal
signal attack_clicked_signal


var board = []
var clickablePos = []
var enemies = []

func _ready():
	
	# Init 2d array
	for i in range(5):
		board.append([])
		for j in range(11):
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
	
	
	# Spawn player
	player = spawn_entity(playerPrefab, Vector2(2, 2))
	
	# init healthText
	player.healthText = healthBar
	
	
	# Spawn eyeball
	for i in 3:
		var eyeball = spawn_entity(eyeballPrefab, Vector2(i+1, 9))
		enemies.append(eyeball)
	
	
	
	# Game loop
	while true:

		# Wait for player move
		board[player.pos.x][player.pos.y] = null
		
		var clickPos
		atkButton.disabled = true
		clickablePos = player.get_movement()
		while true:
			clickPos = yield(self, "kotak_clicked_signal")
			# print(clickPos)
			if clickPos != player.pos:
				break

		# move slowly
		# set_player_pos(tmp)
		player.set_pos(clickPos)
		board[clickPos.x][clickPos.y] = player
		yield(player, "onTarget")


		# Wait for player attack
		atkButton.disabled = false
		clickablePos = []
		get_tree().call_group("kotak", "set_type", Kotak.HighlightType.DISABLED)
		yield(self, "attack_clicked_signal")
		
		# Enemies move
		for enemy in enemies:
			board[enemy.pos.x][enemy.pos.y] = null
			var targetPos = enemy.get_movement()[0]
			enemy.set_pos(targetPos)
			board[enemy.pos.x][enemy.pos.y] = enemy
			yield(enemy, "onTarget")
			
			yield(enemy.attack_player(), "completed")
		

func spawn_entity(prefab, pos):
	var obj = instantiate(prefab)
	obj.gm = self
	obj.position = pos_to_position(pos)
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

func filter(list_of_pos):
	var ans = []
	for o in list_of_pos:
		if o.x >= 0 and o.y >= 0 and o.x <= 4 and o.y <= 10:
			if board[o.x][o.y] == null:
				ans.append(o)
	return ans
