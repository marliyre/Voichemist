extends Area2D

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.name == "PlayerExplorer":
		print("Player reached Basecamp exit door.")

func exit_to_basecamp() -> void:
	Global.is_exploring = false
	AudioManager.play_click()
	print("🚪 Returning to Basecamp...")
	get_tree().change_scene_to_file("res://scenes/levels/base_lobby.tscn")
