extends VBoxContainer

@onready var label_level: Label = get_node_or_null("LabelLevel")
@onready var label_hp: Label = $LabelHP
@onready var label_sp: Label = $LabelSP
@onready var label_material: Label = $LabelMaterial
@onready var label_coins: Label = get_node_or_null("LabelCoins")

func _process(_delta: float) -> void:
	if is_instance_valid(label_level):
		label_level.text = "LVL: %d (EXP: %d / %d)" % [Global.player_level, Global.current_exp, Global.exp_needed]
	label_hp.text = "HP: %d / %d" % [Global.player_hp, Global.max_hp]
	label_sp.text = "SP: %d / %d" % [Global.current_sp, Global.max_sp]
	
	if is_instance_valid(label_coins):
		label_coins.text = "Koin: %d" % Global.coins
	
	# Total Materials
	var total_materials: int = 0
	for amount in Global.material_inventory.values():
		total_materials += amount
		
	label_material.text = "Material: %d" % total_materials
