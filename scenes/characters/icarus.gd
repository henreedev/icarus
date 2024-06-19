extends RigidBody2D
class_name Icarus

#region: Globals

# Enums
enum State {FLAPPING, GLIDING, FALLING}
enum Flap {WEAK, NORMAL, STRONG, NONE}

# Constants
const MIN_HOZ_SPEED = 30.0
const MAX_HOZ_SPEED = 200.0
const MAX_HEAT = 1.0
const MAX_MOISTURE = 1.0
const TERMINAL_VEL = 200.0
const FLAP_COOLDOWN = 0.5
const STRONG_CHARGE_TIME = 1.0

# State variables
var state : State = State.FLAPPING
var ignore_player_input = false
var durability := 1.0 # Can run into obstacles twice
var heat := 0.0
var moisture := 0.0
var speed := 0.0

# Flapping variables
var doing_flap = false
var charging_flap = false
var flap_on_cooldown = false
var flap_type : Flap = Flap.NONE
var flap_charge_time := 0.0

# Movement variables
var hoz_speed = MIN_HOZ_SPEED

# Other variables

# Onready variables
@onready var main : Main = get_tree().get_first_node_in_group("main")
@onready var flap_timer : Timer = $FlapTimer

#endregion

#region: Base functions
func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	_process_state(delta)
	print("Info: ", flap_type, flap_on_cooldown, doing_flap)

func _physics_process(delta: float) -> void:
	speed = linear_velocity.length()
	_physics_process_state(delta)
#endregion

#region: State functions 
func _process_state(delta : float) -> void:
	match state:
		State.FLAPPING:
			if doing_flap and flap_type == Flap.NORMAL:
				if Input.is_action_just_pressed("flap"):
					_flap()
			if not doing_flap:
				if Input.is_action_just_pressed("flap"):
					_begin_flap()
				if Input.is_action_just_released("flap"):
					_release_flap()
			if charging_flap:
				flap_charge_time += delta
		State.GLIDING:
			pass
		State.FALLING:
			pass

func _physics_process_state(delta) -> void:
	match state:
		State.FLAPPING:
			if doing_flap:
				match flap_type:
					Flap.WEAK:
						_do_weak_flap(delta)
					Flap.NORMAL:
						_do_normal_flap(delta)
					Flap.STRONG:
						_do_strong_flap(delta)
					Flap.NONE:
						print("ERROR Flap.NONE encountered")
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

#region: Helper functions
func _flap_timer(duration : float):
	flap_timer.start(duration)
	await flap_timer.timeout
#endregion

#region: Action functions

func _flap() -> void:
	# TODO start flap animation
	flap_type = _pick_flap_type()
	flap_on_cooldown = true
	doing_flap = true
	match flap_type:
		Flap.WEAK:
			apply_central_impulse(Vector2(0, -100))
		Flap.NORMAL:
			apply_central_impulse(Vector2(0, -200))
			pass
		Flap.STRONG:
			apply_central_impulse(Vector2(0, -300))
			pass
	await get_tree().create_timer(0.25).timeout
	if not charging_flap:
		doing_flap = false
	await get_tree().create_timer(0.25).timeout
	if not charging_flap:
		flap_on_cooldown = false

func _do_weak_flap(delta : float):
	doing_flap = false

func _do_normal_flap(delta : float):
	doing_flap = false

func _do_strong_flap(delta : float):
	doing_flap = false


func _pick_flap_type() -> Flap:
	if flap_on_cooldown:
		return Flap.WEAK
	elif flap_charge_time > STRONG_CHARGE_TIME:
		return Flap.STRONG
	else:
		return Flap.NORMAL

func _begin_flap() -> void:
	# TODO start charge animation
	charging_flap = true
	flap_charge_time = 0
	flap_type = Flap.NONE

func _release_flap() -> void:
	if charging_flap:
		charging_flap = false
		
		_flap()
#endregion
