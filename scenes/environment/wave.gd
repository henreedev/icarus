extends RigidBody2D
class_name wave


#region: globals

var startPosition := Vector2.ZERO
var currentPosition := Vector2.ZERO
var moveSpeed := 20  
var ftm := 200
var framesPassed := 0

#endregion



#region: functions

func _ready():
	startPosition = position
	currentPosition = startPosition

func _process(delta):
	framesPassed += 1
	currentPosition.x += moveSpeed * delta
	position = currentPosition
	
#endregion
