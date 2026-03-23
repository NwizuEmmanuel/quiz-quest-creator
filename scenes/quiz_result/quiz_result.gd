extends Control

var quiz_items = load(QuizData.quiz_path) as Questions
var score = QuizData.score
var total_question = QuizData.total_questions
var defeat_boss_point = QuizData.defeat_boss_point
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	quiz_items = quiz_items.questions
	show_quiz_result()

func convert_multiple_choice_answer(ans: int) -> String:
	var result = ""
	if ans == 1:
		result = "A"
	elif ans == 2:
		result = "B"
	elif ans == 3:
		result = "C"
	elif ans == 4:
		result = "D"
	return result


func show_quiz_result():
	var result_text = ""
	result_text += "SCORE: %d/%d\n" % [score,total_question]
	result_text += "DEFEAT BOSS POINT: %d\n" % defeat_boss_point
	result_text += "[b]Quiz[/b]\n"
	for i in range(quiz_items.size()):
		if quiz_items[i].question_type == QuestionItem.QuestionType.MULTIPLE_CHOICE:
			result_text += str(i+1)+": "+quiz_items[i].text+"\n\n"
			result_text += "A: "+quiz_items[i].options[0]+"\n"
			result_text += "B: "+quiz_items[i].options[1]+"\n"
			result_text += "C: "+quiz_items[i].options[2]+"\n"
			result_text += "D: "+quiz_items[i].options[3]+"\n"
			for j in QuizData.failed_questions:				
				if j.id == i:
					result_text += "YOUR CHOICE: "+convert_multiple_choice_answer(j.choice)+"\n"
					result_text += "[color=red]You failed this question\n[/color]"
					break
			result_text += "CORRECT: "+convert_multiple_choice_answer(quiz_items[i].correct_option)+"\n\n"
		elif quiz_items[i].question_type == QuestionItem.QuestionType.IDENTIFICATION:
			result_text += str(i+1)+": "+quiz_items[i].text+"\n\n"
			for k in QuizData.failed_questions:
				if k.id == i:
					result_text += "YOUR CHOICE: "+k.choice+"\n"
					result_text += "[color=red]You failed this question\n[/color]"
					break
			result_text += "CORRECT: "+quiz_items[i].correct_answer+"\n\n"
	%ResultRichTextLabel.text = result_text


func _on_go_home_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func _on_restart_quiz_button_pressed() -> void:
	QuizData.score = 0
	QuizData.defeat_boss_point = 0
	QuizData.failed_questions.clear()
	get_tree().change_scene_to_file("res://scenes/play_quiz/play_quiz.tscn")


func _on_export_button_pressed() -> void:
	pass
