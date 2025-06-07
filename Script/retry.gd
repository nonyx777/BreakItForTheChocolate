extends Control


func _on_retry_pressed() -> void:
	"""
	# This delay reduces the possiblity of smashed objects still existing after retry
	# I think It gives the STM plugn time to clean stuff up
	"""
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file("res://Scene/living_room.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
