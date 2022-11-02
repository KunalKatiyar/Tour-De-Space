extends Popup


func _ready():
	pass


func _on_Restart():
	get_tree().reload_current_scene()


func _on_Quit():
	get_tree().quit()


func _on_MainMenu():
	get_tree().change_scene("res://scenes/Level/Main Menu.tscn")
