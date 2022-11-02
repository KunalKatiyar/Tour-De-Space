extends KinematicBody2D

export (Color) var atmosphere = Color(0.37, 0.62, 0.9, 0.15)

const GRAVITY = 4000
var type = "PLANET"
var count = 100

onready var gravityCenter = get_node("GravityPoint")
onready var boundarynode = get_node("BoundaryNodes")
var gravityField = GRAVITY / 4
		
		
func _draw():
	draw_circle(gravityCenter.get_position(), gravityField, atmosphere)

func is_in_gravity_field(pos):
	return gravityCenter.get_global_position().distance_to(pos) <= gravityField
	
func enforce_neighbours(delta):
	var nodes_list = boundarynode.get_children()
	for i in count:
		var this = nodes_list[i]
		var next = nodes_list[(i+1)%count]
		var distance = this.position.distance_to(next.position)
		var change_dir = (this.position - next.position).normalized()
		
		next.linear_velocity += change_dir * 0.5 * delta  * distance
		this.linear_velocity -=change_dir * 0.5 * delta * distance
		
func enforce_anchors(delta):
	var nodes_list = boundarynode.get_children()
	for i in count:
		var this = nodes_list[i]
		var anchor = this.start_position
		
		var distance = this.position.distance_to(anchor)
		var change_dir = (this.position - anchor).normalized()
		
		this.linear_velocity -= change_dir * 0.5 * delta * 3000
		
func enforce_boundary(delta):
	var nodes_list = boundarynode.get_children()
	var collision = get_node("Water")
	print(collision)
	var list = []
	for i in count:
		var this = nodes_list[i]
		list.append(this.position)
	print(list.size())
	list = PoolVector2Array(list)
	collision.set_polygon(list)
		
