extends CanvasLayer
class_name DemoHUD

@onready var step_label: Label = $Control/MarginContainer/VBoxContainer/StepLabel
@onready var hint_label: Label = $Control/MarginContainer/VBoxContainer/HintLabel
@onready var hints_container: VBoxContainer = $Control/MarginContainer/VBoxContainer/HintsContainer
@onready var complete_panel: Control = $Control/CompletePanel
@onready var complete_title_label: Label = $Control/CompletePanel/VBoxContainer/CompleteTitleLabel
@onready var complete_hint_label: Label = $Control/CompletePanel/VBoxContainer/CompleteHintLabel


func _ready() -> void:
	hide_complete()


func set_step_text(text: String) -> void:
	step_label.text = text


func set_hint_text(text: String) -> void:
	hint_label.text = text


func set_hint_row_text(row_name: StringName, action_text: String, key_text: String = "") -> void:
	var row := hints_container.get_node_or_null(NodePath(row_name))
	if row == null:
		return
	var action_label := row.get_node_or_null("ActionLabel")
	var key_label := row.get_node_or_null("KeyTextLabel")
	if action_label and action_label is Label:
		(action_label as Label).text = action_text
	if key_label and key_label is Label:
		(key_label as Label).text = key_text


func show_complete(title_text: String = "Demo Complete", hint_text: String = "") -> void:
	complete_title_label.text = title_text
	complete_hint_label.text = hint_text
	complete_panel.visible = true


func hide_complete() -> void:
	complete_panel.visible = false
