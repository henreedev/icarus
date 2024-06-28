extends RigidBody2D
class_name hurricane


#region: globals

var startPosition := Vector2.ZERO
var moveSpeed := 6  
var ftm := 4
var framesPassed := 0

#endregion

#region: functions

func _ready():
	startPosition = position

func _process(delta):
	framesPassed += 1
	if framesPassed >= ftm:
		framesPassed = 0
		var rng = RandomNumberGenerator.new()
		var rand_x = rng.randf_range(-moveSpeed, moveSpeed)
		var rand_y = rng.randf_range(-moveSpeed, moveSpeed)
		position.x += rand_x
		position.y += rand_y
	
	
#endregion
