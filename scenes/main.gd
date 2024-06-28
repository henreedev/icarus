extends Node2D
class_name Main

#region: globals

@onready var icarus : Icarus = $Icarus
@onready var bird_scene = preload("res://scenes/environment/bird.tscn")
@onready var wave_scene = preload("res://scenes/environment/wave.tscn")
@onready var hurricane_scene = preload("res://scenes/environment/hurricane.tscn")


#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawner(prefab, position):
	var pref = prefab.instance()  # Create an instance of the bullet scene
	pref.position = position  # Set the position of the bullet
	add_child(pref)  # Add the bullet to the scene
