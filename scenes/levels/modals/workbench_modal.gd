extends Control

signal modal_closed

@onready var btn_viex: Button = $Card/RecipeSelectors/BtnViex
@onready var btn_scope: Button = $Card/RecipeSelectors/BtnScope
@onready var btn_buat: Button = $Card/BtnBuat
@onready var btn_kembali: Button = $Card/BtnKembali
@onready var notice_label: Label = $Card/NoticeLabel
@onready var bahan_container: GridContainer = $Card/BahanSlots
@onready var hasil_label: Label = $Card/HasilSlot/Label

var selected_recipe: String = "viex"

const RECIPES: Dictionary = {
	"viex": {"glass": 1, "stone": 1, "iron": 1, "leather": 1, "output": "Viex Container\n(x1)"},
	"scope": {"glass": 1, "stone": 1, "iron": 2, "leather": 1, "output": "Scope Container\n(x1)"}
}

func _ready() -> void:
	btn_viex.pressed.connect(func(): _select_recipe("viex"))
	btn_scope.pressed.connect(func(): _select_recipe("scope"))
	btn_buat.pressed.connect(_craft)
	btn_kembali.pressed.connect(close)

func open() -> void:
	visible = true
	_select_recipe("viex")
	_set_notice("", Color.WHITE)

func close() -> void:
	visible = false
	AudioManager.play_click()
	modal_closed.emit()

func _select_recipe(recipe_id: String) -> void:
	selected_recipe = recipe_id
	AudioManager.play_click()
	_update_ui()

func _update_ui() -> void:
	if not is_instance_valid(bahan_container): return
	btn_viex.disabled = (selected_recipe == "viex")
	btn_scope.disabled = (selected_recipe == "scope")
	
	var data = RECIPES.get(selected_recipe, RECIPES["viex"])
	if is_instance_valid(hasil_label):
		hasil_label.text = data.output
		
	var mats = data.duplicate()
	mats.erase("output")
	
	var idx = 0
	for child in bahan_container.get_children():
		if idx < mats.keys().size():
			var mat_key = mats.keys()[idx]
			var req = mats[mat_key]
			var cur = Global.material_inventory.get(mat_key, 0)
			var info = ItemData.get_info(mat_key)
			var lbl = child.get_node_or_null("Label")
			if lbl:
				lbl.text = "%s\n%s\n(%d/%d)" % [info.icon, info.title, cur, req]
				lbl.set("theme_override_colors/font_color", Color.WHITE if cur >= req else Color(1, 0.4, 0.4))
			child.visible = true
		else:
			child.visible = false
		idx += 1

func _craft() -> void:
	var data = RECIPES.get(selected_recipe, RECIPES["viex"])
	var mats = data.duplicate()
	mats.erase("output")
	
	for mat in mats.keys():
		if Global.material_inventory.get(mat, 0) < mats[mat]:
			var info = ItemData.get_info(mat)
			_set_notice("❌ Insufficient materials: %s requires %d!" % [info.title, mats[mat]], Color(1, 0.4, 0.4))
			AudioManager.play_click()
			return
			
	for mat in mats.keys():
		Global.material_inventory[mat] -= mats[mat]
	Global.add_item(selected_recipe, 1)
	Global.gain_exp(15)
	AudioManager.play_coin()
	
	var out_info = ItemData.get_info(selected_recipe)
	_set_notice("✅ Successfully crafted 1 %s! (+15 EXP)" % out_info.title, Color(0.3, 1, 0.4))
	_update_ui()

func _set_notice(msg: String, col: Color) -> void:
	if is_instance_valid(notice_label):
		notice_label.text = msg
		notice_label.set("theme_override_colors/font_color", col)
