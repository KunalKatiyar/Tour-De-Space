extends Node2D

var dir = Vector2(1,0)
export var bullet_speed = 200
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position += dir * delta * bullet_speed
	if($RayCast2D.is_colliding()):
		var collid = $RayCast2D.get_collider()
		if(collid.type == "PLAYER"):
			collid.health-=1

func screen_exited():
	queue_free()
