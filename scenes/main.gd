extends Node2D
class_name Main

#region: globals

@onready var icarus : Icarus = $Icarus
var bird_scene = "res://scenes/environment/bird.tscn"
var wave_scene = "res://scenes/environment/wave.tscn"
var hurricane_scene = "res://scenes/environment/hurricane.tscn"

var level_length = 1000
var end_range = 5
var stored = 0
var rng = RandomNumberGenerator.new()




#class to speed things along
#placeholder is apparently necessary, and must be a valid file
class populator:
	var start = 0
	var population = 0
	var prefab = "res://scenes/environment/bird.tscn"
	var min_height = 0
	var max_height = 256
	func _init(a,b,c, d, e):
		start = a
		population = b
		prefab = c
		min_height = d
		max_height = e
		

#endregion

var hurricane = populator.new(3, 2, hurricane_scene, 0, 256)
var bird = populator.new(1,2, bird_scene, 100, 256)
var wave = populator.new(2,2, wave_scene, 0, 100)
	
var all = [hurricane, bird, wave]


func _ready() -> void:
	populate(0)
	pass




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	##var pos = $Icarus.position
	##var current = floor(pos.x/1000)
	##if current != stored:
	##	populate(current)
	##	stored = current
	pass
		

func populate(intake: int) -> void:
	for a in range(0, end_range):
		for b in all:
			if a >= b.start:
				for c in range (0, b.population * (a - b.start +1)):
					spawner(b,a)

func spawner(a: populator, r:int):
	var rand_x = rng.randf_range(0, level_length) + (r * level_length)
	var rand_y = rng.randf_range(a.min_height, a.max_height)
	var prefab_scene = load(a.prefab)
	var pref = prefab_scene.instantiate()
	pref.global_position.x = rand_x 
	pref.global_position.y = rand_y
	add_child(pref)  # Add the bullet to the scene
