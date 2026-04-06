extends Control

const DATA_DIR = "user://"
const FILE_PATH = DATA_DIR + "all_students_data.res"
@onready var username_input:LineEdit = %UsernameInput
@onready var password_input: LineEdit = %PasswordInput
@onready var pc_number_input: SpinBox = %PCNumberInput
@onready var fullname_input:LineEdit = %FullnameInput
@onready var itemlist: ItemList = %ItemList
@onready var accept_dialog:AcceptDialog = $AcceptDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DirAccess.make_dir_absolute(DATA_DIR)
	prepare_file()
	refresh_itemlist()

func prepare_file():
	if !FileAccess.file_exists(FILE_PATH):
		var all_students = AllStudents.new()
		ResourceSaver.save(all_students, FILE_PATH)

func clear_inputs():
	username_input.clear()
	password_input.clear()
	fullname_input.clear()

func refresh_itemlist():
	itemlist.clear()
	var all_students = load(FILE_PATH)
	var items = all_students.all_students
	for i in items.size():
		itemlist.add_item(items[i].username)
		itemlist.set_item_metadata(i, 
		{"username":items[i].username, 
		"password":items[i].password,
		"pc_number": items[i].pc_number,
		"fullname": items[i].fullname}
		)

func _on_add_button_pressed() -> void:
	var username = username_input.text.strip_edges()
	var password = password_input.text.strip_edges()
	var pc_number = pc_number_input.value
	var fullname = fullname_input.text.strip_edges()
	var student = Student.new()
	student.username = username
	student.password = password
	student.pc_number = pc_number
	student.fullname = fullname
	var all_students = load(FILE_PATH)
	all_students.all_students.append(student)
	ResourceSaver.save(all_students, FILE_PATH)
	refresh_itemlist()
	clear_inputs()


func _on_delete_button_pressed() -> void:
	if itemlist.is_anything_selected():
		var all_students = load(FILE_PATH) as AllStudents
		var idx = itemlist.get_selected_items()[0]
		print(idx)
		var username = itemlist.get_item_metadata(idx)["username"]
		var password = itemlist.get_item_metadata(idx)["password"]
		for i in all_students.all_students:
			if username == i.username and password == i.password:
				all_students.all_students.remove_at(idx)
				ResourceSaver.save(all_students, FILE_PATH)
				refresh_itemlist()
				clear_inputs()


func _on_item_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	var selected = itemlist.get_item_metadata(index)
	var username = selected["username"]
	var password = selected["password"]
	var pc_number = selected["pc_number"]
	var fullname = selected["fullname"]
	username_input.text = username
	password_input.text = password
	pc_number_input.value = pc_number
	fullname_input.text = fullname


func _on_return_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_update_button_pressed() -> void:
	if itemlist.is_anything_selected():
		var selected = itemlist.get_selected_items()[0]
		var username = username_input.text.strip_edges()
		var password = password_input.text.strip_edges()
		var pc_number = pc_number_input.value
		var fullname = fullname_input.text.strip_edges()
		var student = Student.new()
		student.username = username
		student.password = password
		student.pc_number = pc_number
		student.fullname = fullname
		var all_students = load(FILE_PATH) as AllStudents
		all_students.all_students[selected] = student
		ResourceSaver.save(all_students, FILE_PATH)
		refresh_itemlist()
		clear_inputs()
	else:
		accept_dialog.dialog_text = "Select a student"
		accept_dialog.popup_centered()


func _on_clear_btn_pressed() -> void:
	clear_inputs()
