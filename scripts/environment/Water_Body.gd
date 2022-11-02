##This is the script that controls the water body
##it contains all the springs of our water
extends Node2D

#spring factor, dampening factor and spread factor
#spread factor dictates how much the waves will spread to their neighboors
export var k = 0.015
export var d = 0.03
export var spread = 0.2

#the spring array
var springs = []
var passes = 12

#distance in pixel between each spring
export var distance_between_springs = 32
#number of springs in the scene
export var spring_number = 100

#total water body lenght
var water_lenght = distance_between_springs * spring_number

#spring scene reference
onready var water_spring = preload("res://scenes/enivronment/Water_Spring.tscn")

#the body of water depth
export var depth = 1000
var target_height = global_position.y

#the position of the bottom of our body of water
var bottom = target_height + depth

#reference to our polygon2D
onready var water_polygon = $Water_Polygon

#reference to our water border
onready var water_border = $Water_Border
export var border_thickness = 1.1

#reference to the water body area and its collision shape
onready var collisionShape = $Water_Body_Area/CollisionShape2D
onready var water_body_area = $Water_Body_Area

#reference to the particle we just created
onready var splash_particle = preload("res://scenes/enivronment/splash_particles.tscn")

#initializes the spring array and all the springs
func _ready():
	water_border.width = border_thickness

	spread = spread / 1000
	
	var angle_step = 2.0*PI / spring_number
	var angle = 0
	var radius = 540.0
	var center = Vector2(0, 0)
	#loops through all the springs
	#makes an array with all the springs
	#initializes each spring
	for i in range(spring_number):
		#the spring x position
		#they are generated from left to right --- > 0, 32, 64, 96...
#		var x_position = distance_between_springs * i
#		var w = water_spring.instance()
#		add_child(w)
#		springs.append(w)
#		w.initialize(x_position, i)
#		w.set_collision_width(distance_between_springs)
#		#connects our splash signal and calls the function splash
#		w.connect("splash", self, "splash")
		
		var direction = Vector2(cos(angle), sin(angle))
		var pos = center + direction * radius
		var scene_res = load("res://scenes/enivronment/Water_Spring.tscn")
		var node = scene_res.instance()
		node.position = pos
		node.start_position = pos
		add_child(node)
		springs.append(node)
		node.set_collision_width(distance_between_springs)
#		#connects our splash signal and calls the function splash
		node.connect("splash", self, "splash")
		# Rotate one step
		angle += angle_step
	
		
#
	#calculates the total lenght of the water body
	var total_lenght = distance_between_springs * (spring_number - 1)

	#creates a new rectangle shape 2D
	var rectangle = RectangleShape2D.new().duplicate()

	# area position stays right in the middle of the water body
	# the extents of the rectangle are half of the size of the water body
	var rect_position = Vector2(total_lenght / 2, depth / 2)
	var rect_extents = Vector2(total_lenght / 2, depth / 2)

	#sets the position and the extents of the area and the collisionshape
	water_body_area.position = rect_position
	rectangle.set_extents(rect_extents)
	collisionShape.set_shape(rectangle)
#	var radius = 540.0
#	var center = Vector2(0, 0)
#	update()
#
#	# Get how much of an angle objects will be spaced around the circle.
#	# Angles are in radians so 2.0*PI = 360 degrees
#	var count = 360
#	var angle_step = 2.0*PI / count
#
#	var angle = 0
#	# For each node to spawn
#	for _i in range(0, count):
#
#		var direction = Vector2(cos(angle), sin(angle))
#		var pos = center + direction * radius
#		var scene_res = load("res://scenes/enivronment/Water_Spring.tscn")
#		var node = scene_res.instance()
#		node.position = pos
#		var parent = get_node(".")
#		parent.add_child(node)
#		springs.append(node)
#		# Rotate one step
#		angle += angle_step

func _physics_process(delta):
	
	#moves all the springs accordingly
	for i in springs:
		i.water_update(k,d)
	
	enforce_anchors(delta)
	
	#represents the movement of the left and right neighbor of the springs
	
	var left_deltas = []
	var right_deltas = []
	
	#initialize the values with an array of zeros
	for i in range (springs.size()):
		left_deltas.append(0)
		right_deltas.append(0)
		pass
	
	for j in range(passes):
		#loops through each spring of our array
		for i in range(springs.size()):
			#adds velocity to the spring to the LEFT of the current spring
			if i > 0:
				left_deltas[i] = spread * (springs[i].height - springs[i-1].height)
				springs[i-1].velocity += left_deltas[i]
			#adds velocity to the spring to the RIGHT of the current spring
			if i < springs.size()-1:
				right_deltas[i] = spread * (springs[i].height - springs[i+1].height)
				springs[i+1].velocity += right_deltas[i]
	new_border()
	draw_water_body()
	

func draw_water_body():
	
	#gets the curve of the border
	var curve = water_border.curve
	
	#makes an array of the points in the curve
	var points = Array(curve.get_baked_points())
	
	#the water polygon will contain all the points of the surface
	var water_polygon_points = points
	
	#gets the first and last indexes of our surface array
	var first_index = 0
	var last_index = water_polygon_points.size()-1
	
	#add other two points at the bottom of the polygon, to close the water body
	water_polygon_points.append(Vector2(water_polygon_points[last_index].x, bottom))
	water_polygon_points.append(Vector2(water_polygon_points[first_index].x, bottom))
	
	#transforms our normal array into a poolvector2array
	#the polygon draw function uses poolvector2arrays to draw the polygon, so we converted it
	water_polygon_points = PoolVector2Array(water_polygon_points)
	
	#sets the points of our polygon, and also our UV in the case we want to give it a texture
	water_polygon.set_polygon(water_polygon_points)
	water_polygon.set_uv(water_polygon_points)
	pass

func new_border():
	#DRAW A NEW BORDER TO THE WATER
	
	#creates a new curve 2D
	var curve = Curve2D.new().duplicate()
	
	#creates a new array, that holds the positions of the surface points!!
	#we'll use those points to draw our border
	var surface_points = []
	for i in range(springs.size()):
		surface_points.append(springs[i].position)
	
	#adds the points to the curve
	for i in range(surface_points.size()):
		curve.add_point(surface_points[i])
	
	#puts the new curve into our border, smooths it out and then update the border drawing
	water_border.curve = curve
	water_border.smooth(true)
	water_border.update()
	pass

#this function adds a speed to a spring with this index
func splash(index, speed):
	if index >= 0 and index < springs.size():
		springs[index].velocity += speed
	pass

func _on_Water_Body_Area_body_entered(body):
#	body.in_water()
	
	#creates a instace of the particle system
	var s = splash_particle.instance()
	
	#adds the particle to the scene
	get_tree().current_scene.add_child(s)
	
	#sets the position of the particle to the same of the body
	s.global_position = body.global_position
	
	pass # Replace with function body.

#onready var gravityCenter = get_node("GravityPoint")
#onready var boundarynode = get_node("BoundaryNodes")
#var gravityField = GRAVITY / 4
#
#func _ready():
#	var radius = 540.0
#	var center = Vector2(0, 0)
#	update()
#
#	# Get how much of an angle objects will be spaced around the circle.
#	# Angles are in radians so 2.0*PI = 360 degrees
#	var angle_step = 2.0*PI / count
#
#	var angle = 0
#	# For each node to spawn
#	for _i in range(0, count):
#
#		var direction = Vector2(cos(angle), sin(angle))
#		var pos = center + direction * radius
#		var scene_res = load("res://scenes/enivronment/BoundaryNode.tscn")
#		var node = scene_res.instance()
#		node.position = pos
#		node.start_position = pos
#		var parent = get_node("BoundaryNodes")
#		parent.add_child(node)
#		print(node.start_position)
#		# Rotate one step
#		angle += angle_step
#
#func _physics_process(delta):
#	enforce_anchors(delta)
#	enforce_neighbours(delta)
#	enforce_boundary(delta)
#
#func _draw():
#	draw_circle(gravityCenter.get_position(), gravityField, atmosphere)
#
#func is_in_gravity_field(pos):
#	return gravityCenter.get_global_position().distance_to(pos) <= gravityField
#
#func enforce_neighbours(delta):
#	var nodes_list = boundarynode.get_children()
#	for i in count:
#		var this = nodes_list[i]
#		var next = nodes_list[(i+1)%count]
#		var distance = this.position.distance_to(next.position)
#		var change_dir = (this.position - next.position).normalized()
#
#		next.linear_velocity += change_dir * 0.5 * delta  * distance
#		this.linear_velocity -=change_dir * 0.5 * delta * distance
#
func enforce_anchors(delta):
	var nodes_list = springs
	for i in spring_number:
		var this = nodes_list[i]
		var anchor = this.start_position

		var distance = this.position.distance_to(anchor)
		var change_dir = (this.position - anchor).normalized()

		this.velocity -= change_dir.y * 0.5 * delta * 3000
#
#func enforce_boundary(delta):
#	var nodes_list = boundarynode.get_children()
#	var collision = get_node("Water")
#	print(collision)
#	var list = []
#	for i in count:
#		var this = nodes_list[i]
#		list.append(this.position)
#	print(list.size())
#	list = PoolVector2Array(list)
#	collision.set_polygon(list)
#
