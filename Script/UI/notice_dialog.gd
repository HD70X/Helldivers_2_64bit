extends CustomConfirmDialog

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
	self.visible = false

func _on_right_button_pressed():
	right_pressed.emit()
	self.visible = false
