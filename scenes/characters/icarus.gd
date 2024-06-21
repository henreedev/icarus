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
var applied_flap_impulse = false
var flap_type : Flap = Flap.NONE
var flap_charge_time := 0.0

# Movement variables
var hoz_speed = MIN_HOZ_SPEED

# Other variables

# Onready variables
@onready var main : Main = get_tree().get_first_node_in_group("main")
@onready var flap_timer : Timer = $FlapTimer
@onready var asprite : AnimatedSprite2D = $AS

#endregion

#region: Base functions
func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	_process_state(delta)

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
					applied_flap_impulse = false
					_flap()
			if not doing_flap:
				if Input.is_action_just_pressed("flap"):
					_begin_flap()
				if Input.is_action_just_released("flap"):
					_release_flap()
			if charging_flap:
				flap_charge_time += delta
		State.GLIDING:
			if Input.is_action_just_pressed("flap"):
				_tumble()
		State.FALLING:
			pass

func _physics_process_state(delta) -> void:
	match state:
		State.FLAPPING:
			_rotate_on_input(delta)
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
			_rotate_on_input(delta)
			var rotation_vector = Vector2.from_angle(rotation)
			linear_velocity = linear_velocity.length() * rotation_vector
			_pick_animation()
		State.FALLING:
			pass # TODO add height check for losing the game


func _begin_flapping():
	state = State.FLAPPING
	_pick_animation()

func _begin_gliding():
	state = State.GLIDING
	_pick_animation()
	_reset_flap_vars()
	linear_damp = 0.0

func _begin_falling():
	state = State.FALLING
	_pick_animation()
	_reset_flap_vars()
#endregion

#region: Helper functions
func _flap_timer(duration : float):
	flap_timer.start(duration)
	await flap_timer.timeout

func _reset_flap_vars():
	applied_flap_impulse = false
	doing_flap = false
	flap_on_cooldown = false
	flap_type = Flap.NONE
	linear_damp = 1.0


func apply_upward_force(magnitude):
	apply_central_force(Vector2(0, -magnitude).rotated(rotation))

func apply_upward_impulse(magnitude):
	apply_central_impulse(Vector2(0, -magnitude).rotated(rotation))


func _pick_animation():
	match state:
		State.FLAPPING:
			if doing_flap:
				match flap_type:
					Flap.WEAK:
						asprite.animation = "flap_weak"
					Flap.NORMAL:
						asprite.animation = "flap_normal"
					Flap.STRONG:
						asprite.animation = "flap_strong"
			else:
				asprite.animation = "float"
		State.GLIDING:
			if rotation_degrees > 10.0: asprite.animation = "glide_down"
			elif rotation_degrees < -10.0: asprite.animation = "glide_up"
			elif asprite.animation != "glide_down" and asprite.animation != "glide_up":
				asprite.animation = "glide_up"
		State.FALLING:
			asprite.animation = "fall"
	asprite.play()

#endregion

#region: Action functions
func _rotate_on_input(delta : float) -> void:
	match state:
		State.FLAPPING:
			const ROTATION_SPEED = 30.0
			const ROTATION_LIMIT = 15.0
			var rotation_adj = 0.0
			if Input.is_action_pressed("lean_left"):
				rotation_adj -= ROTATION_SPEED
			if Input.is_action_pressed("lean_right"):
				rotation_adj += ROTATION_SPEED
			apply_torque(rotation_adj)
			rotation_degrees = clampf(rotation_degrees, -ROTATION_LIMIT, ROTATION_LIMIT)
		State.GLIDING:
			const ROTATION_SPEED = 45.0
			const ROTATION_LIMIT = 45.0
			var rotation_adj = 0.0
			if Input.is_action_pressed("lean_left"):
				rotation_adj -= ROTATION_SPEED
			if Input.is_action_pressed("lean_right"):
				rotation_adj += ROTATION_SPEED
			apply_torque(rotation_adj)
			rotation_degrees = clampf(rotation_degrees, -ROTATION_LIMIT, ROTATION_LIMIT)

func _tumble() -> void:
	asprite.animation = "tumble"
	asprite.play()

func _flap() -> void:
	flap_type = _pick_flap_type()
	flap_on_cooldown = true
	doing_flap = true
	match flap_type:
		Flap.WEAK:
			pass
		Flap.NORMAL:
			pass
		Flap.STRONG:
			pass
	_pick_animation()

func _do_weak_flap(delta : float):
	const FORCE_STR = 100.0
	const IMPULSE_STR = 100.0
	match asprite.frame:
		0: 
			linear_damp = 10.0
			apply_upward_force(-FORCE_STR)
		1:
			if not applied_flap_impulse:
				applied_flap_impulse = true
				apply_upward_impulse(IMPULSE_STR) 
		2: 
			linear_damp = 1.0
			apply_upward_force(FORCE_STR)

func _do_normal_flap(delta : float):
	const FORCE_STR = 300.0
	const IMPULSE_STR = 300.0
	match asprite.frame:
		0: linear_damp = 10.0
		1:
			if not applied_flap_impulse:
				applied_flap_impulse = true
				apply_upward_impulse(IMPULSE_STR) 
		2, 3, 4: 
			linear_damp = 1.0
			apply_upward_force(FORCE_STR)
		5: linear_damp = 10.0

func _do_strong_flap(delta : float):
	const IMPULSE_STR = 200.0
	const FORCE_STR = 350.0
	if asprite.animation == "tumble":
		#match asprite.frame:
		linear_damp = 0.0
	else:
		match asprite.frame:
			0,1: linear_damp = 10.0
			2: 
				linear_damp = 1.0
				if not applied_flap_impulse:
					applied_flap_impulse = true
					apply_upward_impulse(IMPULSE_STR)
				apply_upward_force(FORCE_STR)
			4: linear_damp = 1.0

func _pick_flap_type() -> Flap:
	if flap_on_cooldown:
		return Flap.WEAK
	elif flap_charge_time > STRONG_CHARGE_TIME:
		return Flap.STRONG
	else:
		return Flap.NORMAL

func _begin_flap() -> void:
	charging_flap = true
	flap_charge_time = 0.0
	flap_type = Flap.NONE

func _release_flap() -> void:
	if charging_flap:
		charging_flap = false
		
		_flap()
#endregion

#region: Signal connection functions

func _on_as_animation_finished() -> void:
	match asprite.animation:
		"flap_weak", "flap_normal":
			_reset_flap_vars()
			_pick_animation()
		"flap_strong":
			_tumble()
		"tumble":
			if state == State.FLAPPING:
				_begin_gliding()
			else:
				_begin_flapping()

