extends KinematicBody2D

export var fire_rate = 0.6

var p_bullet = load("res://scenes/Player/P_Bullet.tscn")
export var health = 12
var closestPlanet
export var type = "PLAYER"
const ACC = 0
const MOVE_SPEED = 500
const GRAVITY = 10
const MAX_FALL_SPEED = 1000
const FRICTION = 0.25
const AIR_RESIST = 0.05
var JUMPED = 0
var motion = 0
var y_velo = 0
var direction = 1
var NUMOFJUMPS = 2
var facing_right = false
var dead = false
var can_fire = true
var speed = Vector2()
var velocity = Vector2()

var MAX_SPEED = 9000
const JUMP_FORCE = 10000


func _process(_delta):
	if (Input.is_action_just_pressed("Shoot")):
		var b = p_bullet.instance()
		get_parent().add_child(b)
		b.position = self.position
		var playerRot = get_player_rotation() + 1.5708
		b.dir = (Vector2(cos(playerRot), sin(playerRot))).normalized()

func _ready():
	set_physics_process(true)
	closestPlanet = get_closest_planet()

func _physics_process(delta):
	var nextPlanet = get_closest_planet()

	if (nextPlanet != closestPlanet && nextPlanet.is_in_gravity_field(get_global_position())):
		closestPlanet = nextPlanet
		
	applyMovement(delta)
	applyGravity(delta)
	applyJump(delta)
	
	var playerRot = get_player_rotation()
	
	velocity = Vector2(speed.x * delta, speed.y * delta)
	velocity = velocity.rotated(playerRot)
	
	var _val = move_and_slide(velocity)
	set_rotation(playerRot)

func applyMovement(delta):
	if Input.is_action_pressed("Slow"):
		MAX_SPEED = 4000
		if Input.is_action_pressed("ui_left"):
			direction = -1
			speed.x = MAX_SPEED * direction
		elif Input.is_action_pressed("ui_right"):
			direction = 1
			speed.x = MAX_SPEED * direction
		
		elif(abs(speed.x) > 0 && abs(speed.x) < 2000):
			speed.x = 0
		elif(abs(speed.x) > 0):
			speed.x += MAX_SPEED * delta * direction * -1
	else:
		MAX_SPEED = 9000
		if Input.is_action_pressed("ui_left"):
			direction = -1
			speed.x = MAX_SPEED * direction
		elif Input.is_action_pressed("ui_right"):
			direction = 1
			speed.x = MAX_SPEED * direction
		
		elif(abs(speed.x) > 0 && abs(speed.x) < 2000):
			speed.x = 0
		elif(abs(speed.x) > 0):
			speed.x += MAX_SPEED * delta * direction * -1
#	speed = speed.normalized() * MAX_SPEED
#	speed.x = clamp(speed.x, -MAX_SPEED, MAX_SPEED)

func applyGravity(_delta):
	if(closestPlanet.is_in_gravity_field(get_global_position())):
		speed.y += closestPlanet.GRAVITY

func applyJump(delta):
	if Input.is_action_pressed("ui_up"):
		speed.y -=JUMP_FORCE
	else:
		speed.y += JUMP_FORCE*delta
	
	speed.y = clamp(speed.y, -JUMP_FORCE, JUMP_FORCE*2)
	
func get_player_rotation():
	var downVector = Vector2(0,1)
	if(closestPlanet):
		return downVector.angle_to(get_gravity_vector(closestPlanet))
	else:
		return get_rotation()

func get_gravity_vector(planet):
	return (planet.get_global_position() - get_global_position()).normalized()


func get_closest_planet():
	var distance = -1
	var foundPlanet = null
	for planet in get_tree().get_nodes_in_group("Planet"):
		if(planet):
			if(distance < 0):
				foundPlanet = planet
				distance = planet.position.distance_to(get_global_position())
			elif(distance > planet.position.distance_to(get_global_position())):
				foundPlanet = planet
				distance = planet.position.distance_to(get_global_position())
				
	return foundPlanet
