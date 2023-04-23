extends "res://Scenes/Enemy/shooterEnemy.gd"

var attackPatternToUse : int
var inverted : int
var attackIndex : int = 0
var attackPatterns = [ # 420 means don't shoot this time
	[30, 20, 10, 0, 420, -30, -20, -10, 0],
	[40, -40, 30, -30, 20, -20, 10, -10, 0],
	[-40, -30, -20, -10, 0, 10, 20, 30, 40]
]

func attack(delta):
	shake_violent(4)
	slow_down(0.05, delta)
	
	var angle = attackPatterns[attackPatternToUse][attackIndex]
	var direction
	
	if (angle == 420) :
		direction = Vector2.ZERO
	else :
		direction = (player.position - position).rotated( inverted * angle * PI / 180)
	if $enemyShooter.fire(direction) :
		
		attackIndex += 1
		if attackIndex >= len(attackPatterns[attackPatternToUse]) :
			enter_hover_mode()

func enter_attack() :
	attackPatternToUse = rng.randi_range(0, len(attackPatterns) - 1)
	attackIndex = 0
	curr_state = ShooterEnemyStates.ATTACK
	inverted = 1 if rng.randi_range(0, 1) else -1
