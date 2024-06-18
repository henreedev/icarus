extends RigidBody2D
class_name Icarus

#region: Globals
# Enums
enum State {FLAPPING, GLIDING, FALLING}

# Constants
const MIN_HOZ_SPEED = 30.0
const MAX_HOZ_SPEED = 200.0
const MAX_HEAT = 1.0
const MAX_MOISTURE = 1.0
const TERMINAL_VEL = 200.0

# State variables
var state : State = State.FLAPPING
var ignore_player_input = false
var health := 2 # Can run into obstacles twice
var heat := 0.0
var moisture := 0.0
var speed := 0.0


# Movement variables
var hoz_speed = MIN_HOZ_SPEED



# Other variables
# tweens...

# Onready variables
@onready var main : Main = get_tree().get_first_node_in_group("main")
#endregion

#region: Base functions
func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	_process_state(delta)

func _physics_process(delta: float) -> void:
	speed = linear_velocity.length()
#endregion

#region: State functions 
func _process_state(delta : float) -> void:
	match state:
		State.FLAPPING:
			pass
		State.GLIDING:
			pass
		State.FALLING:
			pass

func _begin_flapping():
	pass

func _begin_gliding():
	pass

func _begin_falling():
	pass
#endregion
