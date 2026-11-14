extends Button

func _on_pressed() -> void:
	Global.is_exploring = false
	AudioManager.play_click()
	print("Button pressed! Returning to Basecamp...")
	get_tree().change_scene_to_file("res://scenes/levels/base_lobby.tscn")
