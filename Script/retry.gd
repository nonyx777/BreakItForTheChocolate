extends Control


func _on_retry_pressed() -> void:
	call_deferred("changeScene")

func _on_quit_pressed() -> void:
	call_deferred("quitScene")

func changeScene():
	get_tree().change_scene_to_file("res://Scene/living_room.tscn")

func quitScene():
	get_tree().quit()
