extends Node
var all_player_stats = load("user://data/all_player_stats.res") as AllPlayerStats


func _on_save_button_pressed() -> void:
	all_player_stats = AllPlayerStats.new()
	if %FullnameLineEdit.text != "":
		all_player_stats.user_fullname = %FullnameLineEdit.text.strip_edges()
		ResourceSaver.save(all_player_stats, "user://data/all_player_stats.res")
		get_tree().change_scene_to_file("res://scenes/play_quiz/play_quiz.tscn")
	else:
		%AcceptDialog.title = "WARNING"
		%AcceptDialog.dialog_text = "USER FULL NAME IS EMPTY"
		%AcceptDialog.popup_centered()
