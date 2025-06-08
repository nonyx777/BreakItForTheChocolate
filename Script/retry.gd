extends Control


func _on_retry_pressed() -> void:
	call_deferred("changeScene")

func _on_quit_pressed() -> void:
	get_tree().quit()

func changeScene():
	get_tree().change_scene_to_file("res://Scene/living_room.tscn")
