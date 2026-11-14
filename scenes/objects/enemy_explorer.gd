extends Area2D

@export_enum("Common", "Rare", "Epic") var enemy_tier: String = "Common"

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var tier_label: Label = get_node_or_null("TierLabel")

func _ready() -> void:
	_apply_tier_styling()
	_start_idle_animation()

func _apply_tier_styling() -> void:
	if is_instance_valid(sprite):
		match enemy_tier:
			"Common":
				sprite.modulate = Color(1.0, 1.0, 1.0)
			"Rare":
				sprite.modulate = Color(0.4, 0.75, 1.0) # Bluish glow
			"Epic":
				sprite.modulate = Color(1.0, 0.35, 0.3) # Fiery crimson glow
				
	if is_instance_valid(tier_label):
		match enemy_tier:
			"Common":
				tier_label.text = "Common"
				tier_label.set("theme_override_colors/font_color", Color(0.85, 0.85, 0.85))
			"Rare":
				tier_label.text = "Rare"
				tier_label.set("theme_override_colors/font_color", Color(0.4, 0.8, 1.0))
			"Epic":
				tier_label.text = "Epic"
				tier_label.set("theme_override_colors/font_color", Color(1.0, 0.4, 0.3))

func _start_idle_animation() -> void:
	if is_instance_valid(sprite):
		var tw: Tween = create_tween().set_loops()
		tw.tween_property(sprite, "position:y", -3.0, 0.8).set_trans(Tween.TRANS_SINE)
		tw.tween_property(sprite, "position:y", 3.0, 0.8).set_trans(Tween.TRANS_SINE)

func enter_battle() -> void:
	print("Enemy encountered! (%s) Entering battle arena..." % enemy_tier)
	Global.next_battle_tier = enemy_tier
	get_tree().change_scene_to_file("res://scenes/levels/world.tscn")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "PlayerExplorer":
		enter_battle()
