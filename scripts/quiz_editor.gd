extends Control

@onready var question_input = $MarginContainer/HSplitContainer/VBoxContainer/Question 
@onready var option_1_input = $MarginContainer/HSplitContainer/VBoxContainer/Option1 
@onready var option_2_input = $MarginContainer/HSplitContainer/VBoxContainer/Option2
@onready var option_3_input = $MarginContainer/HSplitContainer/VBoxContainer/Option3
@onready var option_4_input = $MarginContainer/HSplitContainer/VBoxContainer/Option4
@onready var identification_answer_input = $MarginContainer/HSplitContainer/VBoxContainer/IdentificationAnswer
@onready var multiple_choice_answer_input = $MarginContainer/HSplitContainer/VBoxContainer/MultipleChoiceAnswer
@onready var multiple_choice_checkbutton = $MarginContainer/HSplitContainer/VBoxContainer/MultipleChoice  
@onready var questions_item_list = $MarginContainer/HSplitContainer/VBoxContainer2/QuestionsList
@onready var add_update_button = $MarginContainer/HSplitContainer/VBoxContainer/HBoxContainer/AddUpdate
@onready var clear_inputs_button = $MarginContainer/HSplitContainer/VBoxContainer/HBoxContainer/ClearInputs
@onready var delete_question_button = $MarginContainer/HSplitContainer/VBoxContainer2/DeleteQuestionButton
@onready var question_error_label = $MarginContainer/HSplitContainer/VBoxContainer/QuestionError
@onready var option_1_error_label = $MarginContainer/HSplitContainer/VBoxContainer/Option1Error
@onready var option_2_error_label = $MarginContainer/HSplitContainer/VBoxContainer/Option2Error
@onready var option_3_error_label = $MarginContainer/HSplitContainer/VBoxContainer/Option3Error
@onready var option_4_error_label = $MarginContainer/HSplitContainer/VBoxContainer/Option4Error
@onready var answer_error_label = $MarginContainer/HSplitContainer/VBoxContainer/AnswerError
@onready var multiple_choice_answer_label = $MarginContainer/HSplitContainer/VBoxContainer/MultipleChoiceAnswerLabel
@onready var overwrite_dialog = $OverwriteDialog


var questions = []
var updating_question = false
var file_name = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_multiple_choice()
	multiple_choice_checkbutton.connect("toggled", toggle_multiple_choice)
	add_update_button.connect("pressed",add_update_question)
	clear_inputs_button.connect("pressed", clear_inputs)
	delete_question_button.connect("pressed", delete_question)

# remove selected question
func delete_question():
	if questions_item_list.is_anything_selected():
		var index = questions_item_list.get_selected_items()[0]
		questions.remove_at(index)
		refresh_questions()

# clear all text inputs
func clear_inputs():
	updating_question = false
	questions_item_list.deselect_all()
	question_input.clear()
	option_1_input.clear()
	option_2_input.clear()
	option_3_input.clear()
	option_4_input.clear()
	identification_answer_input.clear()
	multiple_choice_answer_input.value = 1.0

# add new question or update existing question
func add_update_question():
	if multiple_choice_checkbutton.button_pressed:
		add_multiple_choice()
	else:
		add_identification()

# refresh item list for new questions
func refresh_questions():
	questions_item_list.clear()
	for q in questions:
		questions_item_list.add_item(q["question"])

# Both answer in identification and multiple choice are
# in lowercase
func add_identification():
	var duration = 5.0
	var question = question_input.text.strip_edges()
	var answer = identification_answer_input.text.strip_edges()
	# validate question and answer inputs
	if question != "" and answer != "":
		var question_item = {
				"type": "identification",
				"question": question.to_lower(),
				"answer": answer.to_lower()
		}
		if updating_question:
			var selected_index = questions_item_list.get_selected_items()[0]
			questions[selected_index] = question_item
			updating_question = false
		else:
			questions.append(question_item)
		clear_inputs()
		refresh_questions()
	else:
		if question == "":
			question_error_label.show()
			question_error_label.text = "question can't be empty"
		if answer == "":
			answer_error_label.show()
			answer_error_label.text = "answer can't be empty"
		await get_tree().create_timer(duration).timeout
		question_error_label.hide()
		answer_error_label.hide()

func add_multiple_choice():
	var duration = 5.0
	var option1 = option_1_input.text.strip_edges().to_lower()
	var option2 = option_2_input.text.strip_edges().to_lower()
	var option3 = option_3_input.text.strip_edges().to_lower()
	var option4 = option_4_input.text.strip_edges().to_lower()
	var question = question_input.text.strip_edges().to_lower()
	var answer = multiple_choice_answer_input.value
	if option1 != "" and option2 != "" and option3 != "" and option4 != "" and question != "" and (answer > 0 or answer < 5):
		var question_item = {
			"type": "multiple_choice",
			"question": question,
			"options": [option1, option2, option3, option4],
			"answer": str(answer)
		}
		if updating_question:
			var selected_index = questions_item_list.get_selected_items()[0]
			questions[selected_index] = question_item
			updating_question = false
		else:
			questions.append(question_item)
		clear_inputs()
		refresh_questions()
	else:
		if question == "":
			question_error_label.show()
			question_error_label.text = "question can't be empty"
		if option1 == "":
			option_1_error_label.show()
			option_1_error_label.text = "option 1 can't be empty"
		if option2 == "":
			option_2_error_label.show()
			option_2_error_label.text = "option 2 can't be empty"
		if option3 == "":
			option_3_error_label.show()
			option_3_error_label.text = "option 3 can't be empty"
		if option4 == "":
			option_4_error_label.show()
			option_4_error_label.text = "option 4 can't be empty"
		if answer < 1 or answer > 4:
			answer_error_label.show()
			answer_error_label.text = "answer be between 1-4"
		await get_tree().create_timer(duration).timeout
		question_error_label.hide()
		option_1_error_label.hide()
		option_2_error_label.hide()
		option_3_error_label.hide()
		option_4_error_label.hide()
		answer_error_label.hide()

# hide text inputs related to multiple choice
func hide_multiple_choice():
	multiple_choice_answer_label.hide()
	multiple_choice_answer_input.hide()
	option_1_input.hide()
	option_2_input.hide()
	option_3_input.hide()
	option_4_input.hide()

# show text inputs related to multiple choice
func show_multiple_choice():
	multiple_choice_answer_input.show()
	multiple_choice_answer_label.show()
	option_1_input.show()
	option_2_input.show()
	option_3_input.show()
	option_4_input.show()


# hide text inputs related to identification
func hide_identification():
	identification_answer_input.hide()

# show text inputs related to identification
func show_identification():
	identification_answer_input.show()

# toggle text inputs for multiple choice or identification
func toggle_multiple_choice(toggled_on: bool):
	if toggled_on:
		show_multiple_choice()
		hide_identification()
	else:
		show_identification()
		hide_multiple_choice()
	question_error_label.hide()
	option_1_error_label.hide()
	option_2_error_label.hide()
	option_3_error_label.hide()
	option_4_error_label.hide()
	answer_error_label.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_questions_list_item_activated(index: int) -> void:
	updating_question = true
	var question_type = questions[index]["type"]
	question_input.text = questions[index]["question"]
	if question_type == "multiple_choice":
		multiple_choice_checkbutton.button_pressed = true
		option_1_input.text = questions[index]["options"][0]
		option_2_input.text = questions[index]["options"][1]
		option_3_input.text = questions[index]["options"][2]
		option_4_input.text = questions[index]["options"][3]
		multiple_choice_answer_input.value = int(questions[index]["answer"])
	else:
		multiple_choice_checkbutton.button_pressed = false
		identification_answer_input.text = questions[index]["answer"]

func save_to_file():
	var folder_path = "user://quizzes"
	if not DirAccess.dir_exists_absolute(folder_path):
		DirAccess.make_dir_absolute(folder_path)
	
	var json_string = JSON.stringify(questions, "\t")
	var file_path = folder_path + file_name + ".qf"
	
	if FileAccess.file_exists(file_path):
		overwrite_dialog.popup_centered()
		
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if file:
		file.store_string(json_string)
		file.close()
	
func _on_file_name_save_button_pressed() -> void:
	var file_name_line_edit = $MarginContainer/HSplitContainer/VBoxContainer/HBoxContainer2/FileNameLineEdit
	file_name = file_name_line_edit.text


func _on_overwrite_dialog_confirmed() -> void:
	save_to_file()
