extends MarginContainer
class_name CustomConfirmDialog 

@export var title_text: String
@export var massage_text: String
@export var left_button_text: String
@export var right_button_text: String

@onready var left_button = $Contents/VBoxContainer/HBoxContainer/LeftButton
@onready var right_button = $Contents/VBoxContainer/HBoxContainer/RightButton
@onready var title = $Contents/VBoxContainer/TitleLabel
@onready var massage = $Contents/VBoxContainer/MassageLabel

signal left_pressed
signal right_pressed

func _ready() -> void:
	left_button.button_pressed.connect(_on_left_button_pressed)
	right_button.button_pressed.connect(_on_right_button_pressed)
	_build_dialog()

func _build_dialog():
	title.text = title_text
	massage.text = massage_text
	left_button._button_text = left_button_text
	right_button._button_text = right_button_text

func _on_left_button_pressed():
	left_pressed.emit()

func _on_right_button_pressed():
	right_pressed.emit()
