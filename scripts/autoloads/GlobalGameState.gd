extends Node

# GlobalGameState AutoLoad Singleton
# Tracks core campaign variables, alert state, evidence, and trust levels.

# Core variables
var current_day: int = 1
var current_time_of_day: String = "DAY" # "DAY" or "NIGHT"
var alert_state: String = "UNNOTICED" # "UNNOTICED", "SUSPICIOUS", "COMPROMISED"
var evidence_collected: Array[String] = []
var trust_values: Dictionary = {
	"dara": 50,
	"sable": 50,
	"ashfield": 50,
	"leon": 50
}

const SAVE_PATH = "user://savegame.data"

func _ready():
	print("[GlobalGameState] Initialized.")

# Baseline save_game using Godot 4's FileAccess API
func save_game() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var save_data = {
			"current_day": current_day,
			"current_time_of_day": current_time_of_day,
			"alert_state": alert_state,
			"evidence_collected": evidence_collected,
			"trust_values": trust_values
		}
		file.store_var(save_data)
		file.close()
		print("[GlobalGameState] Game saved to: ", SAVE_PATH)
	else:
		push_error("[GlobalGameState] Failed to open save file for writing. Error code: %d" % FileAccess.get_open_error())

# Baseline load_game using Godot 4's FileAccess API
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("[GlobalGameState] Save file does not exist. Skipping load.")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		if save_data is Dictionary:
			if "current_day" in save_data:
				current_day = save_data["current_day"]
			if "current_time_of_day" in save_data:
				current_time_of_day = save_data["current_time_of_day"]
			if "alert_state" in save_data:
				alert_state = save_data["alert_state"]
			if "evidence_collected" in save_data:
				# Convert to Array[String]
				evidence_collected.clear()
				for item in save_data["evidence_collected"]:
					evidence_collected.append(str(item))
			if "trust_values" in save_data:
				trust_values = save_data["trust_values"]
		print("[GlobalGameState] Game loaded from: ", SAVE_PATH)
	else:
		push_error("[GlobalGameState] Failed to open save file for reading. Error code: %d" % FileAccess.get_open_error())
