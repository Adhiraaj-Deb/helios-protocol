extends Node

# EvidenceManager: The centralized data store for Maya's investigations
# Stores clues, logs, network captures, and hypotheses.

signal evidence_collected(evidence_id)

# Evidence Structure definition
class EvidenceItem:
	var id: String
	var title: String
	var description: String
	var category: String  # "fragments", "links", "questions"
	var revealed: bool = false
	var timestamp: String = ""

	func _init(p_id: String, p_title: String, p_desc: String, p_cat: String, p_revealed: bool = false):
		self.id = p_id
		self.title = p_title
		self.description = p_desc
		self.category = p_cat
		self.revealed = p_revealed

# All registered evidence templates
var evidence_db: Dictionary = {}

# Player's current inventory of collected evidence
var collected_evidence_ids: Array = []

func _ready():
	_register_base_evidence()
	print("[EvidenceManager] Database initialized.")

func _register_base_evidence():
	# Fragments (physical or text evidence)
	_add_template(EvidenceItem.new(
		"maya_briefing",
		"Solaris Isle Operations Overview",
		"A encrypted text file stored on Maya's Node device. Detailing the island schedule and VIP guest coordinates. The arrival was scheduled for May 24th, 09:00.",
		"fragments",
		true # Starter item
	))
	
	_add_template(EvidenceItem.new(
		"directive_12",
		"Foundation Directive 12 (Hardcopy)",
		"Recovered from a concrete terrace bench. Instructs security staff to bypass standard protocols for guest area surveillance, noting 'unauthorized access to Solarium terminals must be met with immediate compromise protocols.' Signed by Leon Hargrove.",
		"fragments",
		false
	))

	# Links (network surveillance or personnel connections)
	_add_template(EvidenceItem.new(
		"dara_connection",
		"Dara Osei - Research Lead",
		"A communication wireframe between Research Lead Dara Osei and an offsite server. Flags multiple outgoing encrypted packets containing chemical research details.",
		"links",
		true # Starter item
	))
	
	_add_template(EvidenceItem.new(
		"solarium_terminal_hack",
		"Terminal Access Logs",
		"A screenshot of a Helios local server terminal showing repeated attempts to pull raw biometric data. The IP address traces back to a terminal inside the Solarium guest suite.",
		"links",
		false
	))

	# Questions (Maya's active investigations)
	_add_template(EvidenceItem.new(
		"ashfield_involvement",
		"Why did Dr. Ashfield authorize Leon's protocol?",
		"The Foundation's medical director authorized a sweep on May 22nd. Maya needs to determine if Ashfield is complicit or under surveillance himself.",
		"questions",
		true # Starter item
	))

	# Add starter evidence to collected inventory
	for ev_id in evidence_db.keys():
		if evidence_db[ev_id].revealed:
			collected_evidence_ids.append(ev_id)

func _add_template(item: EvidenceItem):
	evidence_db[item.id] = item

# --- Public API ---

func collect_evidence(evidence_id: String) -> bool:
	if not evidence_db.has(evidence_id):
		push_error("[EvidenceManager] Attempted to collect unregistered evidence: %s" % evidence_id)
		return false
		
	if collected_evidence_ids.has(evidence_id):
		# Already collected
		return false
		
	collected_evidence_ids.append(evidence_id)
	evidence_db[evidence_id].revealed = true
	
	# Notify systems (HUD, Node UI)
	emit_signal("evidence_collected", evidence_id)
	AudioManager.play_evidence_collected()
	print("[EvidenceManager] Successfully collected clue: %s" % evidence_id)
	return true

func is_collected(evidence_id: String) -> bool:
	return collected_evidence_ids.has(evidence_id)

func get_evidence_by_id(evidence_id: String) -> EvidenceItem:
	if evidence_db.has(evidence_id):
		return evidence_db[evidence_id]
	return null

func get_collected_by_category(category: String) -> Array:
	var items = []
	for ev_id in collected_evidence_ids:
		var item = evidence_db[ev_id]
		if item.category.to_lower() == category.to_lower():
			items.append(item)
	return items
