extends Node

# AudioManager: Coordinates all sound layers in HELIOS PROTOCOL
# This is a robust architectural scaffold with built-in asset failsafes.

var ui_player: AudioStreamPlayer
var amb_player: AudioStreamPlayer
var music_player: AudioStreamPlayer

func _ready():
	# Instantiate players programmatically so they are guaranteed to exist
	ui_player = AudioStreamPlayer.new()
	ui_player.name = "UIPlayer"
	add_child(ui_player)
	
	amb_player = AudioStreamPlayer.new()
	amb_player.name = "AmbPlayer"
	add_child(amb_player)
	
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	add_child(music_player)
	
	print("[AudioManager] Scaffold initialized. Safe fallbacks enabled.")

# --- UI SFX Hooks ---
func play_ui_click():
	# Safe placeholder for clicking UI buttons
	print("[AudioManager] Play SFX: UI Click")

func play_ui_node_toggle(is_open: bool):
	# Safe placeholder for Tablet open/close slide sounds
	print("[AudioManager] Play SFX: Node UI (Open: %s)" % is_open)

func play_evidence_collected():
	# Investigative notification chime
	print("[AudioManager] Play SFX: Clue Recovered Chime")

func play_document_turn():
	# Page rustle
	print("[AudioManager] Play SFX: Document Page Turn")

func play_door_locked():
	# Access denied beep
	print("[AudioManager] Play SFX: Security Door Access Denied")

func play_door_unlocked():
	# Access granted chime
	print("[AudioManager] Play SFX: Security Door Unlocked")

# --- Music & Ambience Hooks ---
func play_ambience(is_night: bool):
	if is_night:
		print("[AudioManager] Ambient Loop: Solaris Isle Terraces (Night - Cool Fog & Crickets)")
	else:
		print("[AudioManager] Ambient Loop: Solaris Isle Terraces (Day - Gentle Warm Wind & Sea Swell)")

func play_stealth_music(suspicion_level: float):
	# Allows scaling synth tension layers dynamically based on detection metrics
	if suspicion_level >= 1.0:
		print("[AudioManager] Music State: COMPROMISED (High alert percussion)")
	elif suspicion_level >= 0.5:
		print("[AudioManager] Music State: SUSPICIOUS (Tense atmospheric hum)")
	else:
		print("[AudioManager] Music State: UNNOTICED (Calm background synth)")

func stop_all():
	ui_player.stop()
	amb_player.stop()
	music_player.stop()
	print("[AudioManager] Stopped all channels.")
