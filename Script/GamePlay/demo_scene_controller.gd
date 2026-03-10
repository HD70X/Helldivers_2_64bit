extends Node

const MAIN_MENU_SCENE := "res://Scene/UI/main_menu.tscn"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file(MAIN_MENU_SCENE)
