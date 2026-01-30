# item_library.gd
@tool
extends Resource
class_name ItemLibrary

@export var item_resources_folder: String = "res://Resources/Items/"
@export var items: Dictionary = {}
@export_tool_button("刷新道具总表", "Play")
var my_button = _refresh_items

func _refresh_items():
	items.clear()  # 清空旧数据
	_load_all_items_from_directory(item_resources_folder)
	if Engine.is_editor_hint():
		emit_changed()

func _load_all_items_from_directory(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			var full_path = path + file_name
			
			# 子目录递归扫描
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				_load_all_items_from_directory(full_path + "/")
			elif file_name.ends_with(".tres"):
				var resource = load(full_path)
				if resource is ItemData:
					if items.has(resource.item_id):
						push_warning("道具 ID 重复: " + resource.item_id)
					items[resource.item_id] = [full_path, resource.item_type]
				else:
					push_warning("文件不是 ItemData 类型: " + full_path)
					
			file_name = dir.get_next()
			
		dir.list_dir_begin()
	else:
		push_error("无法打开目录: " + path)
