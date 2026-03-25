extends Node

@onready var tree: Tree = %Tree
@onready var file_dialog: FileDialog = $FileDialog
@onready var folder_dialog: ConfirmationDialog = $NewFolderDialog
@onready var folder_input: LineEdit = $NewFolderDialog/FolderNameInput
@onready var richtext_label: RichTextLabel = %RichTextLabel	

# The base directory your tree will display
var root_path: String = "user://all_players_stats/"

## Step 1: Open the dialog when the "New Folder" button is pressed
func _on_create_folder_button_pressed():
	folder_input.text = "New_Folder" # Default name
	folder_dialog.popup_centered()
	folder_input.grab_focus() # So they can start typing immediately
	folder_input.select_all()

## Step 2: Handle the actual creation once they click "OK"
func _on_new_folder_dialog_confirmed():
	var new_name = folder_input.text.strip_edges()
	
	# Basic validation: No empty names or illegal characters
	if new_name == "" or new_name.contains("/") or new_name.contains("\\"):
		print("Invalid folder name!")
		return
		
	var parent_path = get_selected_path()
	
	# Ensure we create the folder inside a directory, not inside a file
	if not DirAccess.dir_exists_absolute(parent_path):
		parent_path = parent_path.get_base_dir()
		
	var full_path = parent_path.path_join(new_name)
	
	# Check if folder already exists to avoid overwriting
	if DirAccess.dir_exists_absolute(full_path):
		print("Folder already exists!")
		return
		
	var err = DirAccess.make_dir_recursive_absolute(full_path)
	
	if err == OK:
		print("Created: ", full_path)
		refresh_tree() # Refresh the Tree UI
	else:
		print("Error creating folder: ", err)

func _ready():
	DirAccess.make_dir_recursive_absolute(root_path)
	# Configure Tree
	tree.hide_root = false
	refresh_tree()

## --- Tree Logic ---

func refresh_tree():
	tree.clear()
	var root_item = tree.create_item()
	root_item.set_text(0, "Root")
	root_item.set_metadata(0, root_path)
	_populate_tree(root_path, root_item)

func _populate_tree(path: String, parent_item: TreeItem):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var item_name = dir.get_next()
		
		while item_name != "":
			if item_name != "." and item_name != "..":
				var full_path = path.path_join(item_name)
				var new_item = tree.create_item(parent_item)
				new_item.set_text(0, item_name)
				new_item.set_metadata(0, full_path)
				
				if dir.current_is_dir():
					_populate_tree(full_path, new_item)
					
			item_name = dir.get_next()

func get_selected_path() -> String:
	var selected = tree.get_selected()
	if selected:
		return selected.get_metadata(0)
	return root_path

func _on_import_file_pressed():
	# Opens a FileDialog to pick a file from your OS
	file_dialog.popup_centered()

func _on_file_dialog_file_selected(source_file_path: String):
	var target_dir = get_selected_path()
	
	# Logic to ensure target is a directory
	if not DirAccess.dir_exists_absolute(target_dir):
		target_dir = target_dir.get_base_dir()
		
	var file_name = source_file_path.get_file()
	var destination = target_dir.path_join(file_name)
	
	var err = DirAccess.copy_absolute(source_file_path, destination)
	if err == OK:
		print("Imported: ", destination)
		refresh_tree()
	else:
		print("Error importing file: ", err)

func delete_selected_item():
	var selected = tree.get_selected()
	if not selected:
		print("No item selected in the tree.")
		return
		
	var target_path = selected.get_metadata(0)
	
	# Safety check: Prevent deleting your main data folder
	if target_path == root_path:
		print("Action denied: Cannot delete the root directory.")
		return

	# Internal helper for recursive folder deletion
	var delete_recursive = func(path: String, callable_ref: Callable) -> Error:
		var dir = DirAccess.open(path)
		if not dir: return ERR_CANT_OPEN
		
		dir.list_dir_begin()
		var item = dir.get_next()
		while item != "":
			if item != "." and item != "..":
				var full_item_path = path.path_join(item)
				if dir.current_is_dir():
					var err = callable_ref.call(full_item_path, callable_ref)
					if err != OK: return err
				else:
					var err = DirAccess.remove_absolute(full_item_path)
					if err != OK: return err
			item = dir.get_next()
		return DirAccess.remove_absolute(path)

	# Execute deletion
	var result: Error
	if DirAccess.dir_exists_absolute(target_path):
		result = delete_recursive.call(target_path, delete_recursive)
	else:
		result = DirAccess.remove_absolute(target_path)

	# Final UI Update
	if result == OK:
		print("Successfully deleted: ", target_path)
		refresh_tree() # Refresh your Tree node to reflect the change
	else:
		print("Failed to delete. Error code: ", result)


func _on_delete_button_pressed() -> void:
	delete_selected_item()


func _on_create_folder_pressed() -> void:
	pass # Replace with function body.


func _on_go_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func _on_tree_item_selected():
	var selected = tree.get_selected()
	if not selected:
		return
		
	# Retrieve the file path we stored earlier
	var file_path = selected.get_metadata(0)
	
	# Safety check: Is it actually a file and a .res resource?
	if FileAccess.file_exists(file_path) and file_path.ends_with(".res"):
		display_resource_content(file_path)
	else:
		richtext_label.text = "[color=gray]Select a valid .res file to view stats...[/color]"


func display_resource_content(path: String):
	# Check if the file exists before trying to load
	if not FileAccess.file_exists(path):
		richtext_label.text = "Error: File not found."
		return
	
	# Load the resource natively
	var resource = ResourceLoader.load(path)
	
	# Verify it's the correct type of data
	if resource is PlayerStats:
		var data = resource as PlayerStats
		
		# Build the BBCode display
		var bbcode = "[b]Quiz Info:[/b] %s\n" % data.quiz_title
		bbcode += "-------------------\n"
		bbcode += "Player Name: %s\n" % data.username
		bbcode += "Quiz Title: %s\n" % data.quiz_title
		bbcode += "Score: [color=yellow]%d[/color]\n" % data.score
		
		if data.defeated_boss:
			bbcode += "Status: [color=green]Boss Defeated[/color]"
		else:
			bbcode += "Status: [color=red]Boss Active[/color]"
			
		richtext_label.text = bbcode
	else:
		richtext_label.text = "Error: File is not a valid File resource."
