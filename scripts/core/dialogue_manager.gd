extends Node

# DialogueManager: Coordinates character interactions, dialogue flows,
# and tracks character trust/suspicion matrices dynamically.

signal dialogue_started(npc_name)
signal dialogue_updated(speaker, text, choices)
signal dialogue_ended()
signal trust_changed(character_name, new_value, delta)

# Trust/Suspicion values (range: -100 to +100)
var npc_trust: Dictionary = {
	"Dara": 20,
	"Sable": 0,
	"Dr. Ashfield": 10,
	"Leon": -20 # Leon's trust is low, indicating high initial suspicion of Maya
}

# Current conversation state variables
var current_dialogue_tree: Dictionary = {}
var current_node_id: String = ""
var current_npc_name: String = ""
var is_in_dialogue: bool = false

func _ready():
	_initialize_dialogue_database()
	print("[DialogueManager] Dialogue & Trust systems online.")

# Modifies NPC relationships and notifies UI overlays
func modify_trust(character_name: String, amount: int):
	if not npc_trust.has(character_name):
		npc_trust[character_name] = 0
		
	var old_val = npc_trust[character_name]
	var new_val = clamp(old_val + amount, -100, 100)
	npc_trust[character_name] = new_val
	
	emit_signal("trust_changed", character_name, new_val, amount)
	print("[DialogueManager] Trust change for %s: %d -> %d (%+d)" % [character_name, old_val, new_val, amount])

func get_trust(character_name: String) -> int:
	if npc_trust.has(character_name):
		return npc_trust[character_name]
	return 0

# Dialogue Database containing the test conversation structures
var dialogue_db: Dictionary = {}

func _initialize_dialogue_database():
	# Dara Osei Conversation Tree
	dialogue_db["Dara"] = {
		"start": {
			"speaker": "Dara Osei",
			"text": "Maya. You shouldn't be wandering the arrival terraces. Leon's patrols are twice as frequent today. What are you looking for?",
			"choices": [
				{
					"text": "Just getting my bearings. Solaris Isle is beautiful.",
					"next": "terrace_beauty",
					"trust_mods": {}
				},
				{
					"text": "I'm checking local relays. The Foundation's subnet has an odd packet delay.",
					"next": "cyber_delay",
					"trust_mods": {"Dara": 15, "Leon": -10} # +15 Dara, -10 Leon (increased suspicion)
				},
				{
					"text": "None of your concern, Dara. Keep your head down.",
					"next": "terrace_hostile",
					"trust_mods": {"Dara": -15} # -15 Dara
				}
			]
		},
		"terrace_beauty": {
			"speaker": "Dara Osei",
			"text": "It is designed to look beautiful. It keeps the visitors calm. But be careful—they are watching the cameras, even out here.",
			"choices": [
				{
					"text": "Thanks for the warning. I'll stay alert.",
					"next": "exit",
					"trust_mods": {}
				}
			]
		},
		"cyber_delay": {
			"speaker": "Dara Osei",
			"text": "You noticed it too? It's the Nexus mainframe. They've been backing up the entire clinical archive since midnight. I want to help, but... I don't know who is listening.",
			"choices": [
				{
					"text": "We'll figure this out, Dara. Keep in touch.",
					"next": "exit_cyber",
					"trust_mods": {}
				}
			]
		},
		"terrace_hostile": {
			"speaker": "Dara Osei",
			"text": "Fine. Be reckless. Just don't drag my research team into whatever game you're playing.",
			"choices": [
				{
					"text": "Leave.",
					"next": "exit",
					"trust_mods": {}
				}
			]
		}
	}

# --- Dialogue Running API ---

func start_dialogue(npc_name: String) -> bool:
	if not dialogue_db.has(npc_name):
		push_error("[DialogueManager] Dialogue not found for NPC: %s" % npc_name)
		return false
		
	is_in_dialogue = true
	current_npc_name = npc_name
	current_dialogue_tree = dialogue_db[npc_name]
	current_node_id = "start"
	
	emit_signal("dialogue_started", npc_name)
	_push_current_node()
	return true

func select_choice(choice_index: int):
	if not is_in_dialogue:
		return
		
	var node = current_dialogue_tree[current_node_id]
	if choice_index < 0 or choice_index >= node.choices.size():
		return
		
	var chosen = node.choices[choice_index]
	
	# Apply trust modifications
	for char_name in chosen.trust_mods.keys():
		modify_trust(char_name, chosen.trust_mods[char_name])
		
	var next_node = chosen.next
	if next_node == "exit":
		end_dialogue()
	elif next_node == "exit_cyber":
		# Narrative progression triggers
		EvidenceManager.collect_evidence("solarium_terminal_hack")
		end_dialogue()
	else:
		current_node_id = next_node
		_push_current_node()

func end_dialogue():
	if not is_in_dialogue:
		return
	is_in_dialogue = false
	emit_signal("dialogue_ended")
	print("[DialogueManager] Dialogue ended.")

func _push_current_node():
	var node = current_dialogue_tree[current_node_id]
	emit_signal("dialogue_updated", node.speaker, node.text, node.choices)
