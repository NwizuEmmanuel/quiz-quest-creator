extends Node

@onready var tree: Tree = %Tree
@onready var file_dialog: FileDialog = $FileDialog

# The base directory your tree will display
var root_path: String = "res://game_data/"

func _ready():
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

## --- Actions ---

func _on_create_folder_pressed():
	var parent_path = get_selected_path()
	# Ensure we are adding to a directory, not a file
	if not DirAccess.dir_exists_absolute(parent_path):
		parent_path = parent_path.get_base_dir()
		
	var new_folder_name = "NewFolder_" + str(Time.get_unix_time_from_system())
	var full_path = parent_path.path_join(new_folder_name)
	
	var err = DirAccess.make_dir_recursive_absolute(full_path)
	if err == OK:
		print("Folder created at: ", full_path)
		refresh_tree()

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

func _on_delete_pressed():
	var selected = tree.get_selected()
	if not selected:
		print("Nothing selected to delete.")
		return
	
	var path = selected.get_metadata(0)
	
	# Safety Check: Prevent deleting the root directory
	if path == root_path:
		print("Cannot delete the root directory!")
		return
	
	var err
	if DirAccess.dir_exists_absolute(path):
		# Option A: Move to Trash (Safer, works on most Desktops)
		# OS.move_to_trash(ProjectSettings.globalize_path(path))
		
		# Option B: Permanent Delete (Must be empty or handled recursively)
		err = _delete_directory_recursive(path)
	else:
		# Delete a single file
		err = DirAccess.remove_absolute(path)
	
	if err == OK:
		print("Deleted: ", path)
		refresh_tree()
	else:
		print("Error deleting: ", err)

## Helper function to delete a folder and everything inside it
func _delete_directory_recursive() -> Error:
	var dir = DirAccess.open(get_selected_path())
	if not dir:
		return ERR_CANT_OPEN
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name != "." and file_name != "..":
			var full_path = path.path_join(file_name)
			if dir.current_is_dir():
				var err = _delete_directory_recursive(full_path)
				if err != OK: return err
			else:
				var err = DirAccess.remove_absolute(full_path)
				if err != OK: return err
		file_name = dir.get_next()
	
	# Once the folder is empty, we can remove the folder itself
	return DirAccess.remove_absolute(path)
