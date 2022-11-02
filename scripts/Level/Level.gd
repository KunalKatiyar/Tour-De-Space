extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_node("Player")
var start
var dead = 0

# Called when the node enters the scene tree for the first time.
#	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _ready():
	start = OS.get_ticks_msec()

func _process(delta):
	if (player.health <=0 and !dead):
		player.get_node("Camera2D").current = false
		get_node("Camera2D").offset.x = player.position.x + 20 
		get_node("Camera2D").offset.y = player.position.y - 20 
		get_node("Popup").rect_position.x = player.position.x - 200 
		get_node("Popup").rect_position.y = player.position.y - 100
		get_node("Camera2D").current = true
		get_node("Popup/ColorRect/Label2").text = "Your Score is " + str((OS.get_ticks_msec()-start)/1000)
		player.hide()
		$Popup.popup()
		dead = 1
