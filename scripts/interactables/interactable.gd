extends Area3D
class_name Interactable

# Interactable: Reusable base Area3D class for objects in Solaris Isle.
# Ensures decoupled communication between player raycasts and scene actions.

signal interacted(player)

@export var prompt_name: String = "Interact"
@export var interaction_type: String = "general" # "clue", "door", "terminal", "npc"
@export var is_locked: bool = false
@export var required_evidence_id: String = ""
@export var custom_data: Dictionary = {}

func _ready():
	# Ensure Area3D collision layers are properly configured for interaction raycasting
	# Layer 3 (value 4) is reserved for interactables
	collision_layer = 4
	collision_mask = 0 # Raycast only scans, Area itself doesn't need to scan
	
	print("[Interactable] Registered trigger on Area: %s (Type: %s)" % [name, interaction_type])

# Virtual method: Override in child class implementations
func interact(player: CharacterBody3D):
	emit_signal("interacted", player)
	print("[Interactable] Virtual interact() triggered on Area %s." % name)

# Virtual method: Override in child class implementations for closer look
func inspect(player: CharacterBody3D):
	print("[Interactable] Virtual inspect() triggered on Area %s." % name)
