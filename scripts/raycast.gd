extends RayCast2D

#Make sure to also see player.gd
#The origin raycast is created in player.gd

#Info
#This script is attached to the raycast.tscn scene.
#Every raycast uses this script to calculate reflections.
#I've added the 'self' keyword to help distinguish whether the incident ray or reflected ray is being called.

#Raycast/Line Visibility
#To turn on visible raycasts go to
#Debug -> Visible collision shapes
#To turn off the lines, either hide the Line2D node in the raycast scene, or comment out self.updateLine() in _physics_process()

@onready var raycast_scene = preload("res://scenes/raycast.tscn")

var default_line_length = 128

#The parent ray or 'incident ray' causing this ray to exist.
var incident_ray

var is_reflection = false
var has_child_reflection = false

func _ready():
	#Sets the target_position of the raycast to the default_line_length
	target_position = Vector2(0, default_line_length)

func _physics_process(delta):
	#If the incident ray is colliding with a mirror, create a reflection ray
	if self.is_colliding() and self.has_child_reflection == false:
		if get_collider().is_in_group("mirrors"): #For help with groups, see: https://docs.godotengine.org/en/stable/tutorials/scripting/groups.html
			createNewRay(get_collider(), true)
	
	#Checks done on all rays every frame
	self.reflect()
	self.updateLine()

func updateLine():
	$Line2D.set_point_position(1, Vector2(0, default_line_length))
	
	#Make the incident ray line end at the collision point of a mirror/wall
	if self.is_reflection:
		var collision_point = incident_ray.get_collision_point()
		get_parent().get_child(0).set_point_position(1, get_parent().get_child(0).to_local(collision_point))
	if self.is_colliding():
		var collision_point = get_collision_point()
		$Line2D.set_point_position(1, to_local(collision_point))

func reflect():
	if self.is_reflection:
		self.checkParentCollision()
	
		#Set position of the reflection ray to the collision point of incident ray
		var collision_point = incident_ray.get_collision_point()
		self.position = collision_point
		
		var collision_normal = incident_ray.get_collision_normal()
		
		#Calculate the normalized ray direction
		var incident_ray_origin = incident_ray.global_position
		var incident_ray_endpoint = collision_point
		var ray_direction = incident_ray_endpoint-incident_ray_origin
		var ray_direction_normalized = ray_direction.normalized()
		
		var reflection_vector = ray_direction_normalized.bounce(collision_normal)
		self.rotation = (reflection_vector.angle() - deg_to_rad(90))
		
		#Previously I was using the below to calculate the reflection vector, however I changed this to Vector2.bounce() as it was simpler, however I left this in in case it was useful. 
		#var dot = ray_direction_normalized.dot(collision_normal)
		#var reflection_vector = ray_direction_normalized - (2*dot*collision_normal)	
		#var incident_angle = ray_direction_normalized.angle()
		#var incident_angle_deg = rad_to_deg(incident_angle)

#Creates a reflection ray
func createNewRay(collider_surface, is_reflection = false):
	self.has_child_reflection = true
	
	var new_raycast = raycast_scene.instantiate()
	new_raycast.top_level = true ##! Top level is really important !, it will break without this
	new_raycast.is_reflection = is_reflection

	new_raycast.incident_ray = self
	new_raycast.add_exception(collider_surface)
	self.add_child(new_raycast)

func checkParentCollision():
	#If the incident ray stops colliding with a mirror, then delete the reflection ray.
	if incident_ray.is_colliding() == false:
		incident_ray.has_child_reflection = false
		self.queue_free()
