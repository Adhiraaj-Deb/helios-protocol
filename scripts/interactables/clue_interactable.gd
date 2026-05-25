extends Interactable
class_name ClueInteractable

# ClueInteractable: Coordinates investigative clue reading, keypads, and terminals.
# Registers gathered intelligence with the central EvidenceManager database.

@export var evidence_id: String = "directive_12"
@export var inspect_title: String = "CLASSIFIED PAPERWORK"
@export var inspect_body: String = "A document stamped with the Helios Foundation seal."

func interact(player: CharacterBody3D):
	super.interact(player)
	
	AudioManager.play_document_turn()
	
	# Attempt to register with the evidence tracking database
	var was_new = EvidenceManager.collect_evidence(evidence_id)
	
	# Display detailed overlay message on HUD toast
	UIManager.show_toast(inspect_title, inspect_body)
	
	# If this is a special terminal, trigger access behaviors
	if interaction_type == "terminal":
		print("[ClueInteractable] Terminal console accessed. Processing hack data...")
		# Example: collecting another connection log
		EvidenceManager.collect_evidence("solarium_terminal_hack")
		
	# Notify systems
	var feedback = "RECOVERED INTEL: " + inspect_title
	if not was_new:
		feedback += " (ALREADY IN LOGS)"
	print("[ClueInteractable] Player accessed clue: %s. %s" % [name, feedback])

func inspect(player: CharacterBody3D):
	super.inspect(player)
	print("[ClueInteractable] Closer inspection of clue %s requested." % name)
	# Trigger HUD toast as inspection detail
	UIManager.show_toast(inspect_title, "Maya examines the item closely: " + inspect_body)
