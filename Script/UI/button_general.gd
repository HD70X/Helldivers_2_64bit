extends MarginContainer
class_name GeneralGameButton

@onready var layout_label: Label = $MarginContainer/LayoutLabel
@onready var button: Button = $Button

var _button_text_value := ""
var _button_disabled_value := false

@export var normal_text_color := Color(0.9413647, 0.9413647, 0.94136465, 1.0)
@export var normal_shadow_color := Color(0.18359056, 0.18359041, 0.18359044, 1.0)
@export var normal_outline_color := Color(0.0, 0.0, 0.0, 1.0)

@export var disabled_text_color := Color(0.72, 0.72, 0.72, 1.0)
@export var disabled_shadow_color := Color(0.12, 0.12, 0.12, 1.0)
@export var disabled_outline_color := Color(0.0, 0.0, 0.0, 1.0)

@export var _button_text: String = "":
	set(value):
		_button_text_value = value
		_refresh_visuals()
	get:
		return _button_text_value

@export var _button_disabled: bool = false:
	set(value):
		_button_disabled_value = value
		_refresh_visuals()
	get:
		return _button_disabled_value

@export var label_transform := Vector2.ZERO

signal button_pressed

var is_pointed := false
var is_pressed := false

func _ready() -> void:
	button.button_down.connect(_on_button_down)
	button.button_up.connect(_on_button_up)
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)
	_refresh_visuals()

func _refresh_visuals() -> void:
	if not is_node_ready():
		return

	button.disabled = _button_disabled_value
	layout_label.text = _button_text_value
	layout_label.modulate = Color(1.0, 1.0, 1.0, 1.0)

	if _button_disabled_value:
		layout_label.add_theme_color_override("font_color", disabled_text_color)
		layout_label.add_theme_color_override("font_shadow_color", disabled_shadow_color)
		layout_label.add_theme_color_override("font_outline_color", disabled_outline_color)
	else:
		layout_label.add_theme_color_override("font_color", normal_text_color)
		layout_label.add_theme_color_override("font_shadow_color", normal_shadow_color)
		layout_label.add_theme_color_override("font_outline_color", normal_outline_color)

func _on_button_down() -> void:
	is_pressed = true
	if is_pointed:
		layout_label.position += label_transform

func _on_button_up() -> void:
	if is_pressed and is_pointed:
		layout_label.position -= label_transform
		button_pressed.emit()
	is_pressed = false

func _on_mouse_entered() -> void:
	is_pointed = true
	if is_pressed:
		layout_label.position += label_transform

func _on_mouse_exited() -> void:
	if is_pressed:
		layout_label.position -= label_transform
	is_pointed = false

func disable_button() -> void:
	_button_disabled = true

func enable_button() -> void:
	_button_disabled = false
