extends Node

# Player Status
var player_hp: int = 100
var max_hp: int = 100
var current_sp: int = 50
var max_sp: int = 100

var player_level: int = 1
var current_exp: int = 0
var total_exp: int = 0
var exp_needed: int = 100
var coins: int = 0

# Exploration & Battle State
var is_in_battle: bool = false
var is_exploring: bool = false
var next_battle_tier: String = "Common"
var invisible_duration: int = 0
var wind_duration: int = 0
var poison_stack: int = 0
var is_reflecting_shield: bool = false
var is_poison_protected: bool = false

var sp_regen_time: float = 60.0 # GDD Bab 5.4: +1 SP per 60 detik di kondisi aman (Basecamp)
var regen_timer: float = 0.0

# Inventory & Quests
var enemies_defeated: int = 0
var chest_inventory: Dictionary = {}

var consumable_inventory: Dictionary = {
	"invisible_potion": 5, "wind_potion": 5, "stamina_potion": 5, "heal_potion": 5,
	"spiral_scope": 5, "attack_viexir": 10, "defense_viexir": 5, "neutralize_viexir": 5
}

var material_inventory: Dictionary = {
	"stone": 10, "iron": 10, "glass": 10, "leather": 10,
	"viex": 0, "scope": 0,
	"red_crystal": 10, "blue_crystal": 10, "green_crystal": 10, "gold_crystal": 10,
	"red_azer": 10, "white_azer": 10, "blue_azer": 10, "green_azer": 10, "yellow_azer": 10
}

func transfer_to_chest(item_name: String, amount: int = 1) -> bool:
	if use_item(item_name, amount):
		chest_inventory[item_name] = chest_inventory.get(item_name, 0) + amount
		return true
	return false

func transfer_from_chest(item_name: String, amount: int = 1) -> bool:
	if chest_inventory.get(item_name, 0) >= amount:
		chest_inventory[item_name] -= amount
		if chest_inventory[item_name] <= 0:
			chest_inventory.erase(item_name)
		add_item(item_name, amount)
		return true
	return false

# Core Functions
func _process(delta: float) -> void:
	# GDD Bab 5.3: Tidak ada regenerasi SP saat eksplorasi atau battle
	if is_in_battle or is_exploring:
		regen_timer = 0.0
		return
		
	if current_sp < max_sp:
		regen_timer += delta
		if regen_timer >= sp_regen_time:
			current_sp += 1
			regen_timer = 0.0

func reset_battle_effects() -> void:
	is_in_battle = false
	poison_stack = 0
	invisible_duration = 0
	wind_duration = 0
	is_reflecting_shield = false
	is_poison_protected = false

func rest_at_base() -> void:
	player_hp = max_hp
	current_sp = max_sp
	reset_battle_effects()
	print("🛌 Resting at Basecamp: HP & SP fully restored!")

func get_exp_required(level: int) -> int:
	# Formula GDD Bab 1 Halaman 3: EXP_next = 100 + 50(L - 1)
	return 100 + (50 * (level - 1))

func gain_exp(amount: int) -> void:
	if amount <= 0:
		return
	current_exp += amount
	total_exp += amount
	print("Gained %d EXP! Current EXP: %d / %d" % [amount, current_exp, exp_needed])
	while current_exp >= exp_needed:
		level_up()

func level_up() -> void:
	player_level += 1
	current_exp -= exp_needed
	exp_needed = get_exp_required(player_level)
	
	max_hp += 20
	player_hp = max_hp
	max_sp += 10
	current_sp = max_sp
	
	# Hadiah Level Up sesuai GDD Bab 1 Halaman 5
	if player_level == 2:
		add_coins(25)
		print("🎁 Level Up Reward (Lv.2): +25 Coins!")
	elif player_level == 3:
		add_item("stone", 5)
		add_item("iron", 3)
		add_item("leather", 3)
		print("🎁 Level Up Reward (Lv.3): +5 Stone, +3 Iron, +3 Leather!")
	elif player_level == 5:
		add_coins(50)
		add_item("gold_crystal", 1)
		print("🎁 Special Level Up Reward (Lv.5): +50 Coins & +1 Gold Crystal!")
	
	print("LEVEL UP! Lvl: %d | HP: %d | SP: %d | EXP Next: %d" % [player_level, max_hp, max_sp, exp_needed])

func add_coins(amount: int) -> void:
	coins += amount
	print("Coins gained: +%d | Total: %d" % [amount, coins])

func use_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		print("Coins spent: -%d | Remaining: %d" % [amount, coins])
		return true
	return false

func add_item(item_name: String, amount: int) -> void:
	if consumable_inventory.has(item_name):
		consumable_inventory[item_name] += amount
	elif material_inventory.has(item_name):
		material_inventory[item_name] += amount

func use_item(item_name: String, amount: int) -> bool:
	if consumable_inventory.has(item_name) and consumable_inventory[item_name] >= amount:
		consumable_inventory[item_name] -= amount
		return true
	return false
