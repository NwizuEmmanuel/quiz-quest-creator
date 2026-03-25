extends Node
var player_stats = load("user://data/player_stats.res") as PlayerStats


func _on_save_button_pressed() -> void:
	if %FullnameLineEdit.text != "":
		player_stats.username = %FullnameLineEdit.text.strip_edges()
		ResourceSaver.save(player_stats, "user://data/player_stats.res")
		get_tree().change_scene_to_file("res://scenes/play_quiz/play_quiz.tscn")
	else:
		%AcceptDialog.title = "WARNING"
		%AcceptDialog.dialog_text = "USER FULL NAME IS EMPTY"
		%AcceptDialog.popup_centered()
