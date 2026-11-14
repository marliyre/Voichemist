extends Area2D

@export_enum("red_azer", "white_azer", "blue_azer", "green_azer", "yellow_azer")
var azer_type: String = "green_azer"
@export var amount: int = 1

@onready var sprite: Sprite2D = $Sprite2D

var color_map: Dictionary = {
	"red_azer": Color(1.0, 0.25, 0.25),
	"white_azer": Color(1.0, 1.0, 1.0),
	"blue_azer": Color(0.25, 0.6, 1.0),
	"green_azer": Color(0.2, 1.0, 0.3),
	"yellow_azer": Color(1.0, 0.9, 0.15)
}

func _ready() -> void:
	if is_instance_valid(sprite) and color_map.has(azer_type):
		sprite.modulate = color_map[azer_type]

func collect_azer() -> void:
	var col = get_node_or_null("CollisionShape2D")
	if is_instance_valid(col):
		col.set_deferred("disabled", true)
		
	var pretty_name = azer_type.replace("_", " ").capitalize()
	print("🌿 Alchemy leaf obtained: %s (+%d)" % [pretty_name, amount])
	Global.add_item(azer_type, amount)
	Global.gain_exp(2) # GDD Bab 1 Halaman 3: Mengumpulkan material eksplorasi = 2 EXP
	AudioManager.play_leaf()
	
	_show_floating_text("+%d %s (+2 EXP)" % [amount, pretty_name])
	if is_instance_valid(sprite):
		sprite.visible = false
	await get_tree().create_timer(0.6).timeout
	queue_free()

func _show_floating_text(text: String) -> void:
	var lbl = Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.set("theme_override_colors/font_color", color_map.get(azer_type, Color.WHITE))
	lbl.set("theme_override_font_sizes/font_size", 10)
	lbl.z_index = 50
	lbl.position = Vector2(-75, -28)
	lbl.size = Vector2(150, 20)
	add_child(lbl)
	
	var tween = create_tween()
	tween.parallel().tween_property(lbl, "position:y", lbl.position.y - 25, 0.6)
	tween.parallel().tween_property(lbl, "modulate:a", 0.0, 0.6)
	tween.tween_callback(lbl.queue_free)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "PlayerExplorer":
		collect_azer()
