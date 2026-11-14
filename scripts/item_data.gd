extends Node

const DB: Dictionary = {
	"attack_viexir": {
		"title": "Attack Viexir",
		"desc": "Volatile alchemical projectile serving as the primary damage weapon to eliminate anomalies.",
		"type": "Consumable", "price_buy": 15, "price_sell": 8, "icon": "💥"
	},
	"neutralize_viexir": {
		"title": "Neutralize Viexir",
		"desc": "Reduces enemy ATK by 40% for 2 rounds and completely purges poison stacks.",
		"type": "Consumable", "price_buy": 25, "price_sell": 12, "icon": "🧪"
	},
	"defense_viexir": {
		"title": "Defense Viexir",
		"desc": "Creates a spectral reflective shield that deflects 100% of physical damage back to attacker.",
		"type": "Consumable", "price_buy": 25, "price_sell": 12, "icon": "🛡️"
	},
	"spiral_scope": {
		"title": "Spiral Scope",
		"desc": "Optical alchemical device to scan enemy threat data and target weak points (Head, Arms, Body).",
		"type": "Consumable", "price_buy": 35, "price_sell": 18, "icon": "🔍"
	},
	"heal_potion": {
		"title": "Health Potion",
		"desc": "Concentrated herbal potion instantly restoring 30% Max HP during battle.",
		"type": "Consumable", "price_buy": 20, "price_sell": 10, "icon": "💚"
	},
	"stamina_potion": {
		"title": "Stamina Potion",
		"desc": "Energy-restoring brew that instantly replenishes +30 SP for actions and throws.",
		"type": "Consumable", "price_buy": 20, "price_sell": 10, "icon": "⚡"
	},
	"invisible_potion": {
		"title": "Invisibility Potion",
		"desc": "Cloaks the alchemist in stealth, rendering them invulnerable to all damage for 2 rounds.",
		"type": "Consumable", "price_buy": 30, "price_sell": 15, "icon": "👻"
	},
	"wind_potion": {
		"title": "Wind Potion",
		"desc": "Summons a swirling air barrier that deflects incoming enemy projectiles.",
		"type": "Consumable", "price_buy": 30, "price_sell": 15, "icon": "💨"
	},
	"stone": {
		"title": "Stone", "desc": "Solid mineral base material for crafting alchemical container structures.",
		"type": "Material", "price_buy": 10, "price_sell": 3, "icon": "🪨"
	},
	"iron": {
		"title": "Iron", "desc": "Hardened metal forged into container frames and optical scope barrels.",
		"type": "Material", "price_buy": 15, "price_sell": 5, "icon": "🔩"
	},
	"glass": {
		"title": "Glass", "desc": "High-clarity alchemical glassware designed to hold volatile fluids safely.",
		"type": "Material", "price_buy": 12, "price_sell": 4, "icon": "🫙"
	},
	"leather": {
		"title": "Leather", "desc": "Supple leather straps used for bottle holsters and impact dampening.",
		"type": "Material", "price_buy": 12, "price_sell": 4, "icon": "📜"
	},
	"viex": {
		"title": "Viex Container", "desc": "Empty alchemical vial crafted and prepared to hold volatile Viexir formulas.",
		"type": "Material", "price_buy": 20, "price_sell": 10, "icon": "🍶"
	},
	"scope": {
		"title": "Scope Container", "desc": "Precision lens and barrel assembly ready to be assembled into a Spiral Scope.",
		"type": "Material", "price_buy": 25, "price_sell": 12, "icon": "🔭"
	},
	"red_crystal": {
		"title": "Red Crystal", "desc": "Volatile fire-charged mineral harvested from hostile anomalies.",
		"type": "Material", "price_buy": 30, "price_sell": 10, "icon": "🔴"
	},
	"blue_crystal": {
		"title": "Blue Crystal", "desc": "Resonant mineral radiating protective energy and physical reflection.",
		"type": "Material", "price_buy": 40, "price_sell": 15, "icon": "🔵"
	},
	"green_crystal": {
		"title": "Green Crystal", "desc": "Restorative mineral infused with poison neutralization and cellular mending.",
		"type": "Material", "price_buy": 35, "price_sell": 12, "icon": "🟢"
	},
	"gold_crystal": {
		"title": "Gold Crystal", "desc": "Rare high-frequency crystal used for advanced anomaly spectrum scanning.",
		"type": "Material", "price_buy": 60, "price_sell": 25, "icon": "🟡"
	},
	"red_azer": {
		"title": "Red Azer Leaf", "desc": "Fiery alchemical foliage rich in catalytic essence.",
		"type": "Material", "price_buy": 15, "price_sell": 6, "icon": "🍁"
	},
	"white_azer": {
		"title": "White Azer Leaf", "desc": "Luminescent flora containing light-bending optical pigments.",
		"type": "Material", "price_buy": 20, "price_sell": 8, "icon": "🍃"
	},
	"blue_azer": {
		"title": "Blue Azer Leaf", "desc": "Cool-scented botanical specimen with natural aerodynamic properties.",
		"type": "Material", "price_buy": 15, "price_sell": 6, "icon": "🌿"
	},
	"green_azer": {
		"title": "Green Azer Leaf", "desc": "Vital leaf renowned for rapid biological regeneration.",
		"type": "Material", "price_buy": 15, "price_sell": 6, "icon": "🌱"
	},
	"yellow_azer": {
		"title": "Yellow Azer Leaf", "desc": "Energizing leaf that invigorates stamina and alchemical flow.",
		"type": "Material", "price_buy": 15, "price_sell": 6, "icon": "🌾"
	}
}

static func get_info(item_id: String) -> Dictionary:
	return DB.get(item_id, {
		"title": item_id.capitalize(),
		"desc": "Alchemical item.",
		"type": "Misc",
		"price_buy": 10,
		"price_sell": 5,
		"icon": "📦"
	})
