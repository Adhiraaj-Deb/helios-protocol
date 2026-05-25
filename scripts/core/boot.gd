extends Node

# Boot: Small, robust initialization node.
# Triggers the title menu load upon entering the tree.

func _ready():
	print("[Boot] System loading...")
	# Small delay to ensure all autoloads have completed their respective _ready() calls
	await get_tree().process_frame
	UIManager.show_main_menu()
	print("[Boot] Main menu displayed. Boot finished.")
