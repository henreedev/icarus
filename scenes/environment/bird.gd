extends Node2D
class_name bird


#region: globals

var startPosition := Vector2.ZERO
var currentPosition := Vector2.ZERO
var moveSpeed := 100  
var ftm := 200

var framesPassed := 0
var movingRight := true

#endregion



#region: functions

func _ready():
	startPosition = position
	currentPosition = startPosition

func _process(delta):
	framesPassed += 1
	
	if movingRight:
		currentPosition.x += moveSpeed * delta
		if framesPassed >= ftm:
			framesPassed = 0
			movingRight = false
	else:
		currentPosition.x -= moveSpeed * delta
		if framesPassed >= ftm:
			framesPassed = 0
			movingRight = true
	
	position = currentPosition
	
#endregion
