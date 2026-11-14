extends Control

signal modal_closed

@onready var tab_markas: Button = $Card/TabHeader/BtnMarkas
@onready var tab_eksplor: Button = $Card/TabHeader/BtnEksplor
@onready var tab_bertarung: Button = $Card/TabHeader/BtnBertarung
@onready var title_label: Label = $Card/Content/TitleLabel
@onready var body_label: Label = $Card/Content/BodyLabel
@onready var btn_tutup: Button = $Card/BtnTutup

const GUIDE_TEXTS: Dictionary = {
	"markas": {
		"title": "Guidebook: Basecamp Facilities",
		"body": "1. Container Workbench: Craft empty Viex and Scope containers from Stone, Iron, Glass, and Leather.\n2. Alchemy Lab (Cauldron): Brew herbal potions and infuse containers with crystal formulas.\n3. Shop: Purchase supplies and sell surplus materials for Coins.\n4. Chest & Bag: Store extra items in the 30-slot Chest to free up space in your 15-slot Bag.\n5. Rest: Fully restore HP and SP before heading out on expeditions."
	},
	"eksplor": {
		"title": "Guidebook: Grid Exploration Map",
		"body": "1. Movement: Navigate the 13x6 grid map using Arrow keys, WASD, or click.\n2. Azer Leaves: Gather 5 color variants of Azer Leaves on the ground for potion brewing (+2 EXP).\n3. Treasure Chests: Open chests to acquire Stone, Iron, Leather, Coins, and +5 EXP.\n4. Combat Encounter: Approach Anomalies to enter turn-based tactical artillery combat."
	},
	"bertarung": {
		"title": "Guidebook: Artillery Combat Tactics",
		"body": "1. 60-Second Turns: Use turn time to reposition and calibrate your trajectory.\n2. Throwing Gauge: Hold [SPACE] to charge power (0-100%), release to throw.\n3. Alchemy Belt: Press keys [1-8] or scroll to select Viexirs and potions.\n4. Dodge [SHIFT]: Evade incoming enemy attacks at the cost of 5 SP.\n5. Spiral Scope: Analyze target weak points (Head, Arms, Body) to trigger CRITICAL HITS (+50% Damage)!"
	}
}

func _ready() -> void:
	tab_markas.pressed.connect(func(): _select_tab("markas"))
	tab_eksplor.pressed.connect(func(): _select_tab("eksplor"))
	tab_bertarung.pressed.connect(func(): _select_tab("bertarung"))
	btn_tutup.pressed.connect(close)

func open() -> void:
	visible = true
	_select_tab("markas")

func close() -> void:
	visible = false
	AudioManager.play_click()
	modal_closed.emit()

func _select_tab(tab_name: String) -> void:
	AudioManager.play_click()
	tab_markas.disabled = (tab_name == "markas")
	tab_eksplor.disabled = (tab_name == "eksplor")
	tab_bertarung.disabled = (tab_name == "bertarung")
	
	var data = GUIDE_TEXTS.get(tab_name, GUIDE_TEXTS["markas"])
	title_label.text = data.title
	body_label.text = data.body
