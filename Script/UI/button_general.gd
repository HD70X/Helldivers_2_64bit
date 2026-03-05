extends MarginContainer
class_name GeneralGameButton

# 指向 CanvasGroup，因为 Shader 应该挂在它上面才能解决截断
@onready var canvas_group = $CanvasGroup
@onready var label = $CanvasGroup/Label
@onready var layout_label = $MarginContainer/LayoutLabel
@onready var margin_container_2 = $MarginContainer
@onready var button = $Button

@export var _button_text: String = ""
@export var _button_disabled: bool = false
@export var label_transform = Vector2(0, 0)

# 预加载材质 (确保这些材质现在是 ShaderMaterial，且挂在 CanvasGroup 上)
var normal_material = preload("res://Art/Material/pixel_word_canvas.tres")
var disabled_material = preload("res://Art/Material/pixel_word_canvas(disable).tres")

signal button_pressed

var is_pointed = false
var is_pressed = false

func _ready() -> void:
	button.button_down.connect(_on_button_down)
	button.button_up.connect(_on_button_up)
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)
	label.position += Vector2(42,6)
	_update_text_and_sync()

func _update_text_and_sync() -> void:
	button.disabled = _button_disabled
	layout_label.text = _button_text
	label.text = _button_text
	
	# 1. 强制更新布局逻辑，确保本帧计算出正确的对齐位置
	layout_label.get_parent().queue_sort() 
	
	# 2. 关键：等待布局完成。
	# 只有在下一帧，或者 call_deferred 之后，layout_label 的真实位置才是准确的
	await get_tree().process_frame 
	
	# 3. 放弃手动加 Vector2(42, 6)，改用全域坐标同步
	# 这会无视 MarginContainer 的内部偏移、居中对齐带来的位移、以及字体差异
	if is_instance_valid(label) and is_instance_valid(layout_label):
		label.global_position = layout_label.global_position
		
	# 4. 更新材质
	canvas_group.material = disabled_material if _button_disabled else normal_material


func _on_button_down() -> void:
	is_pressed = true
	if is_pointed:
		layout_label.position += label_transform

func _on_button_up() -> void:
	is_pressed = false
	if is_pointed:
		layout_label.position -= label_transform
		button_pressed.emit()  # 转发信号

func _on_mouse_entered() -> void:
	is_pointed = true
	if is_pressed:
		layout_label.position += label_transform

func _on_mouse_exited() -> void:
	is_pointed = false
	if is_pressed:
		layout_label.position -= label_transform

func disable_button():
	_button_disabled = true
	_update_text_and_sync()

func enable_button():
	_button_disabled = false
	_update_text_and_sync()
