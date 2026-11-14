extends CanvasLayer

@onready var btn_base: Button = $BtnBase
@onready var label: Label = $Label

func _ready() -> void:
	hide()
	btn_base.pressed.connect(_on_base_pressed)

func show_victory(exp_gained: int = 20, drop_summary: String = "+1 Red Crystal, +10 Coins") -> void:
	if is_instance_valid(label):
		label.text = "ANOMALY DEFEATED!\n+%d EXP | %s" % [exp_gained, drop_summary]
	show()

func _on_base_pressed() -> void:
	Global.reset_battle_effects()
	print("Victory! Returning to Basecamp...")
	get_tree().change_scene_to_file("res://scenes/levels/base_lobby.tscn")
