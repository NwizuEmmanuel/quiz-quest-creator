extends Control

@onready var question_input = $MarginContainer/HSplitContainer/VBoxContainer/Question 
@onready var option_1_input = $MarginContainer/HSplitContainer/VBoxContainer/Option1 
@onready var option_2_input = $MarginContainer/HSplitContainer/VBoxContainer/Option2
@onready var option_3_input = $MarginContainer/HSplitContainer/VBoxContainer/Option3
@onready var option_4_input = $MarginContainer/HSplitContainer/VBoxContainer/Option4
@onready var answer_input = $MarginContainer/HSplitContainer/VBoxContainer/Answer
@onready var multiple_choice_checkbutton = $MarginContainer/HSplitContainer/VBoxContainer/MultipleChoice  
@onready var questions_item_list = $MarginContainer/HSplitContainer/VBoxContainer2/QuestionsList
@onready var add_update_button = $MarginContainer/HSplitContainer/VBoxContainer/HBoxContainer/AddUpdate
@onready var clear_inputs_button = $MarginContainer/HSplitContainer/VBoxContainer/HBoxContainer/ClearInputs
@onready var delete_button = $MarginContainer/HSplitContainer/VBoxContainer2/HBoxContainer/Delete
@onready var clear_selections_button = $MarginContainer/HSplitContainer/VBoxContainer2/HBoxContainer/ClearSelections
@onready var question_error_label = $MarginContainer/HSplitContainer/VBoxContainer/QuestionError
@onready var option_1_error_label = $MarginContainer/HSplitContainer/VBoxContainer/Option1Error
@onready var option_2_error_label = $MarginContainer/HSplitContainer/VBoxContainer/Option2Error
@onready var option_3_error_label = $MarginContainer/HSplitContainer/VBoxContainer/Option3Error
@onready var option_4_error_label = $MarginContainer/HSplitContainer/VBoxContainer/Option4Error
@onready var answer_error_label = $MarginContainer/HSplitContainer/VBoxContainer/AnswerError
@onready var answer_label = $MarginContainer/HSplitContainer/VBoxContainer/AnswerLabel

var questions = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_multiple_choice()
	multiple_choice_checkbutton.connect("toggled", toggle_multiple_choice)
	add_update_button.connect("pressed",add_update_question)
	clear_inputs_button.connect("pressed", clear_inputs)
	delete_button.connect("pressed", delete_question)
	clear_selections_button.connect("pressed", clear_questions_item_list_selections)
	answer_input.connect("text_changed", multiple_choice_answer_text_change)


func multiple_choice_answer_text_change(new_text):
	if multiple_choice_checkbutton.button_pressed:
		if new_text.length() > 1 and !["1","2","3","4"].has(new_text):
			answer_input.text = ""


# deselect all selections
func clear_questions_item_list_selections():
	questions_item_list.deselect_all()

# remove selected question
func delete_question():
	if questions_item_list.is_anything_selected():
		var index = questions_item_list.get_selected_items()[0]
		questions.remove_at(index)
		refresh_questions()

# clear all text inputs
func clear_inputs():
	question_input.clear()
	option_1_input.clear()
	option_2_input.clear()
	option_3_input.clear()
	option_4_input.clear()
	answer_input.clear()

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
	var answer = answer_input.text.strip_edges()
	# validate question and answer inputs
	if question != "" and answer != "":
		var question_item = {
			"type": "identification",
			"question": question.to_lower(),
			"answer": answer.to_lower()
		}
		questions.append(question_item)
		
		clear_inputs()
		refresh_questions()
	else:
		if question_input.text == "":
			question_error_label.show()
			question_error_label.text = "question can't be empty"
		if answer_input.text == "":
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
	var answer = answer_input.text.strip_edges().to_lower()
	if option1 != "" and option2 != "" and option3 != "" and option4 != "" and question != "" and answer != "":
		var question_item = {
			"type": "multiple_choice",
			"question": question,
			"options": [option1, option2, option3, option4],
			"answer": answer
		}
		questions.append(question_item)
		
		clear_inputs()
		refresh_questions()
	else:
		if question_input.text == "":
			question_error_label.show()
			question_error_label.text = "question can't be empty"
		if option_1_input.text == "":
			option_1_error_label.show()
			option_1_error_label.text = "option 1 can't be empty"
		if option_2_input.text == "":
			option_2_error_label.show()
			option_2_error_label.text = "option 2 can't be empty"
		if option_3_input.text == "":
			option_3_error_label.show()
			option_3_error_label.text = "option 3 can't be empty"
		if option_4_input.text == "":
			option_4_error_label.show()
			option_4_error_label.text = "option 4 can't be empty"
		if answer_input.text == "":
			answer_error_label.show()
			answer_error_label.text = "answer can't be empty"
		await get_tree().create_timer(duration).timeout
		question_error_label.hide()
		option_1_error_label.hide()
		option_2_error_label.hide()
		option_3_error_label.hide()
		option_4_error_label.hide()
		answer_error_label.hide()

# hide text inputs related to multiple choice
func hide_multiple_choice():
	answer_input.show()
	option_1_input.hide()
	option_2_input.hide()
	option_3_input.hide()
	option_4_input.hide()

# toggle text inputs for multiple choice or identification
func toggle_multiple_choice(toggled_on: bool):
	if toggled_on:
		answer_input.show()
		answer_label.show()
		option_1_input.show()
		option_2_input.show()
		option_3_input.show()
		option_4_input.show()
	else:
		option_1_input.hide()
		option_2_input.hide()
		option_3_input.hide()
		option_4_input.hide()
		answer_label.hide()
	question_error_label.hide()
	option_1_error_label.hide()
	option_2_error_label.hide()
	option_3_error_label.hide()
	option_4_error_label.hide()
	answer_error_label.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
