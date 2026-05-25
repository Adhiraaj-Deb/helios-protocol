extends Interactable
class_name DoorInteractable

# DoorInteractable: Security door with keypad lock systems linked to evidence databases.
# Demonstrates interactive mystery investigations opening physical gates.

@export var door_mesh_path: NodePath
var door_mesh: Node3D = null

var is_open: bool = false

func _ready():
	super._ready()
	if door_mesh_path:
		door_mesh = get_node(door_mesh_path)
	
	# Update prompt based on lock state
	if is_locked:
		prompt_name = "Unlock Keypad"
	else:
		prompt_name = "Open Security Door"

func interact(player: CharacterBody3D):
	super.interact(player)
	
	if is_locked:
		# Check if player has recovered the keycard passcode evidence
		if required_evidence_id != "" and EvidenceManager.is_collected(required_evidence_id):
			is_locked = false
			prompt_name = "Open Security Door"
			AudioManager.play_door_unlocked()
			UIManager.show_toast("KEYPAD AUTHORIZED", "Passcode verified from terminal logs. Security lock released.")
			print("[DoorInteractable] Security door unlocked using keycard code: %s." % required_evidence_id)
		else:
			AudioManager.play_door_locked()
			UIManager.show_toast("ACCESS DENIED", "Door is electronically locked. Requires biometric terminal passcode.")
			print("[DoorInteractable] Access Denied. Lacks keycard code: %s." % required_evidence_id)
		return

	# Toggle open/close state
	is_open = not is_open
	AudioManager.play_document_turn() # Fallback sound click
	
	if is_open:
		prompt_name = "Close Security Door"
		UIManager.show_toast("GATEWAY OPEN", "Maya opens the brutalist security barrier.")
		# Rotate or slide the door mesh out of the way programmatically
		if door_mesh:
			door_mesh.rotation.y = deg_to_rad(90.0) # Rotate open
			door_mesh.position.x = 1.5 # Slide open
		print("[DoorInteractable] Door opened.")
	else:
		prompt_name = "Open Security Door"
		UIManager.show_toast("GATEWAY CLOSED", "Maya closes the brutalist security barrier.")
		# Restore door mesh positions
		if door_mesh:
			door_mesh.rotation.y = 0.0
			door_mesh.position.x = 0.0
		print("[DoorInteractable] Door closed.")
