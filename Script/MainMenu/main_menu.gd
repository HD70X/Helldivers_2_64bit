extends Node2D

const TEST_MAP_SCENE := "res://Scene/TestMap.tscn"

@onready var start_button: GeneralGameButton = $CanvasLayer/Control/MarginContainer/VBoxContainer/VBoxContainer/StartButton
@onready var exit_button: GeneralGameButton = $CanvasLayer/Control/MarginContainer/VBoxContainer/VBoxContainer/ExitButton


func _ready() -> void:
	start_button.button_pressed.connect(_on_start_button_pressed)
	exit_button.button_pressed.connect(_on_exit_button_pressed)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(TEST_MAP_SCENE)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
