extends Node2D

@onready var raycast_scene = preload("res://scenes/raycast.tscn")
var rotation_speed = 1
var is_mouse_hover = false

func _ready():
	#This creates the origin raycast.
	var origin = raycast_scene.instantiate()
	#The origin raycast is added to the sprite_dish node because that is the node I want to rotate.
	$Sprite_Dish.add_child(origin)

#Misc code for moving the 
func _physics_process(delta):
	if Input.is_action_pressed("move_tower_left"):
		$Sprite_Dish.rotation -= delta * rotation_speed
	if Input.is_action_pressed("move_tower_right"):
		$Sprite_Dish.rotation += delta * rotation_speed
	
