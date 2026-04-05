extends Control

@onready var from_input: LineEdit = %FromInput
@onready var to_input: LineEdit = %ToInput
@onready var accept_dialog: AcceptDialog = $AcceptDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

func show_dialog(mssg: String):
	accept_dialog.dialog_text = mssg
	accept_dialog.popup_centered()

func _on_schedule_btn_pressed() -> void:
	var from = from_input.text.strip_edges()
	var to = to_input.text.strip_edges()
	if from != "" and to != "":
		Global.schedule_time_from = from
		Global.schedule_time_to = to
		Global.schedule_date = Time.get_date_string_from_system()
		print(Global.schedule_date)
		show_dialog("Time have been scheduled.")
		get_tree().change_scene_to_file("res://scenes/add_quiz.tscn")
	else:
		show_dialog("Nothing happened.")


func _on_return_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/add_quiz.tscn")
