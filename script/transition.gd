extends TextureRect

class_name transition
enum TransitionStatus {PLAYER_TURN, ENEMY_TURN, PLAYER_WIN}

func _ready():
	pass

func play(transitionStatus):
	match transitionStatus:
		TransitionStatus.PLAYER_TURN:
			$AnimationPlayer.play("playerTurn")
			
		TransitionStatus.ENEMY_TURN:
			$AnimationPlayer.play("enemyTurn")
			
		TransitionStatus.PLAYER_WIN:
			$AnimationPlayer.play("playerWin")
	
	yield($AnimationPlayer, "animation_finished")
