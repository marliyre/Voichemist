extends CanvasLayer

@onready var btn_retry: Button = $BtnRetry
@onready var btn_base: Button = $BtnBase

func _ready() -> void:
	hide()
	btn_retry.pressed.connect(_on_retry_pressed)
	btn_base.pressed.connect(_on_base_pressed)

func show_game_over() -> void:
	show()
	# get_tree().paused = true

func _on_retry_pressed() -> void:
	Global.player_hp = Global.max_hp
	Global.reset_battle_effects()
	Global.is_in_battle = true
	get_tree().reload_current_scene()

func _on_base_pressed() -> void:
	Global.player_hp = 10 # Penalty
	Global.reset_battle_effects()
	print("Returning to Basecamp...")
	get_tree().change_scene_to_file("res://scenes/levels/base_lobby.tscn")
