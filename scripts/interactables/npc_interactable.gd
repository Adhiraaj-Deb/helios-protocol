extends Interactable
class_name NPCInteractable

# NPCInteractable: Triggers conversation branch trees when interacting with personnel.

@export var npc_id: String = "Dara"

var _animation_time: float = 0.0
@onready var placeholder_body = get_node_or_null("PlaceholderBody")
@onready var left_arm_pivot = get_node_or_null("PlaceholderBody/LeftArmPivot")
@onready var right_arm_pivot = get_node_or_null("PlaceholderBody/RightArmPivot")

func _process(delta: float):
	if placeholder_body and left_arm_pivot and right_arm_pivot:
		_animation_time += delta * 1.5
		var breathe = sin(_animation_time) * 0.015
		placeholder_body.position.y = 0.825 + breathe
		left_arm_pivot.rotation.z = 0.05 + breathe * 0.5
		right_arm_pivot.rotation.z = -0.05 - breathe * 0.5

func interact(player: CharacterBody3D):
	super.interact(player)
	
	if DialogueManager.is_in_dialogue:
		return
		
	print("[NPCInteractable] Maya initiated contact with %s." % npc_id)
	
	# Launch dialogue tree
	var success = DialogueManager.start_dialogue(npc_id)
	if success:
		# Temporarily release mouse capturing
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		push_error("[NPCInteractable] Failed to initialize contact with %s." % npc_id)
