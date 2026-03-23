extends Node

var quiz_file: Questions
var quiz_items: Array[QuestionItem] = []
var total_questions = 0
var current = 0
var score = 0
var GRACE_POINT = 0.5
var player_life = 100
var boss_life = 100
var defeat_boss_point = 0.0
var failed_questions_indexes = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	quiz_file = load(QuizData.quiz_path) as Questions
	quiz_items = quiz_file.questions
	total_questions = quiz_items.size()
	display_question()


func set_defeat_boss_point():
	# set defeat boss point with remaining player life after
	# boss is defeated
	if boss_life == 0.0:
		defeat_boss_point = player_life
		print(defeat_boss_point)
	%DefeatBossPoint.text = "Defeat Boss Point: %d" % defeat_boss_point

func display_question():
	if current < total_questions:
		var q = quiz_items[current]
		var question_text = "[b]%d: %s[/b] \n\n" % [current + 1, q.text]
		var options_text = ""  
		
		if q.question_type == QuestionItem.QuestionType.MULTIPLE_CHOICE:
			options_text += "A: %s\n" %q.options[0]
			options_text += "B: %s\n" %q.options[1]
			options_text += "C: %s\n" %q.options[2]
			options_text += "D: %s\n" %q.options[3]
			%OptionsText.text = options_text
			%IdentificationAnswerBox.hide()
			%MultipleChoiceOptionsBox.show()
			%OptionsText.show()
		elif q.question_type == QuestionItem.QuestionType.IDENTIFICATION:
			%IdentificationAnswerBox.show()
			%MultipleChoiceOptionsBox.hide()
			%OptionsText.hide()
		%QuestionText.text = question_text
		%QuizTimer.start(q.time_limit)
	else:
		save_quiz_data()
		get_tree().change_scene_to_file("res://scenes/quiz_result/quiz_result.tscn")


func check_multiple_choice_answer(ans: int):
	var failed_quiz = {}
	var q = quiz_items[current]
	if q.question_type == QuestionItem.QuestionType.MULTIPLE_CHOICE:
		if q.correct_option == ans:
			score += 1
			deal_boss_damage()
		else:
			deal_player_damage()
			failed_quiz = {"id": current, "choice": ans}
			QuizData.failed_questions.append(failed_quiz)
	set_defeat_boss_point()


func check_identification_answer(ans: String):
	var failed_quiz = {}
	var q = quiz_items[current]
	if q.question_type == QuestionItem.QuestionType.IDENTIFICATION:
		if ans.to_upper() in q.correct_answer:
			score += 1
			deal_boss_damage()
		else:
			deal_player_damage()
			failed_quiz = {"id": current, "choice": ans.to_upper()}
			QuizData.failed_questions.append(failed_quiz)
	set_defeat_boss_point()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	%TimerLabel.text = "TIME: %d" % %QuizTimer.time_left
	%ScoreLabel.text = "SCORE: %d/%d" % [score,total_questions]
	timer_label_change_color_timer_stopped()


func deal_damage() -> float:
	var result = 0
	if !%QuizTimer.is_stopped():
		var time_left = %QuizTimer.time_left + 1
		var damage_point = 100 / (total_questions - GRACE_POINT)
		result = damage_point + time_left
	return result

func timer_label_change_color_timer_stopped():
	if %QuizTimer.is_stopped():
		%TimerLabel.add_theme_color_override("font_color",Color.RED)
	else:
		%TimerLabel.add_theme_color_override("font_color",Color.YELLOW)

func deal_boss_damage():
	boss_life -= deal_damage()
	%BossLifeBar.value = boss_life

func deal_player_damage():
	player_life -= deal_damage()
	%PlayerLifeBar.value = player_life

func save_quiz_data():
	var path = "user://data/all_player_stats.res"
	var all_player_stats = load(path) as AllPlayerStats
	var player_stats = PlayerStats.new()
	player_stats.quiz_title = QuizData.quiz_title
	player_stats.score = score
	player_stats.dbp = defeat_boss_point
	all_player_stats.all_stats.append(player_stats)
	
	ResourceSaver.save(all_player_stats, path)

func save_data_globals():
	QuizData.total_questions = total_questions
	QuizData.score = score
	QuizData.defeat_boss_point = defeat_boss_point


func _on_option_a_pressed() -> void:
	if current < total_questions:
		check_multiple_choice_answer(1)
		current += 1
		save_data_globals()
		display_question()


func _on_option_b_pressed() -> void:
	if current < total_questions:
		check_multiple_choice_answer(2)
		current += 1
		save_data_globals()
		display_question()


func _on_option_c_pressed() -> void:
	if current < total_questions:
		check_multiple_choice_answer(3)
		current += 1
		save_data_globals()
		display_question()


func _on_option_d_pressed() -> void:
	if current < total_questions:
		check_multiple_choice_answer(4)
		current += 1
		save_data_globals()
		display_question()


func _on_identification_answer_line_edit_text_submitted(new_text: String) -> void:
	if current < total_questions:
		check_identification_answer(new_text)
		current += 1
		save_data_globals()
		display_question()
		%IdentificationAnswerLineEdit.clear()
