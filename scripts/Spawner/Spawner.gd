extends StaticBody2D

var type = "ENEMY"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_parent().get_parent().get_node("Player")
var bullet_scn = load("res://scenes/Spawner/Bullet.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.set_wait_time(.5)
	$Timer.start()
	var target = Vector2(self.position.x, self.position.y + 100)
	$Move_Tween.interpolate_property(self, "position", position, target, 4, Tween.TRANS_QUINT, Tween.EASE_OUT)
	$Move_Tween.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate(0.5 * delta)
	position.y += 20*delta
	
	if(position.y > get_viewport_rect().size.y + 20):
		get_parent().remove_child(self)
		queue_free()

func spawn_bullets():
	var b1 = bullet_scn.instance()
	
	b1.position = self.position
	b1.rotation = Vector2(player.position.x-self.position.x,player.position.y-self.position.y).normalized().angle() + 1.5708
#	b1.rotation = self.rotation
	b1.dir = Vector2(player.position.x-self.position.x,player.position.y-self.position.y).normalized()
	get_parent().add_child(b1)
#	var b2 = bullet_scn.instance()
#	b2.position = self.position
#	b2.rotation = self.rotation
#	b2.dir = Vector2(0,1)
#
#	var b3 = bullet_scn.instance()
#	b3.position = self.position
#	b3.rotation = self.rotation
#	b3.dir = Vector2(-1,0)
#
#	var b4 = bullet_scn.instance()
#	b4.position = self.position
#	b4.rotation = self.rotation
#	b4.dir = Vector2(0,-1)
#
#	get_parent().add_child(b1)
#	get_parent().add_child(b2)
#	get_parent().add_child(b3)
#	get_parent().add_child(b4)


func timeout():
	spawn_bullets()
