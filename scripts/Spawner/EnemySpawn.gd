extends Node2D

var enemy_spawn = load("res://scenes/Spawner/Spawner.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.set_wait_time(5)
	$Timer.start()
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func timeout():
	var enemy = enemy_spawn.instance()
	randomize()
	enemy.position.x = rand_range(100,1000)
#	enemy.position.y = -50
	add_child(enemy)
