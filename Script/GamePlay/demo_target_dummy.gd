extends StaticBody2D
class_name DemoTargetDummy

signal destroyed
signal hp_changed(current_hp: float, max_hp: float)

@export var max_hp: float = 30.0

var current_hp: float


func _ready() -> void:
	current_hp = max_hp
	hp_changed.emit(current_hp, max_hp)


func apply_damage(amount: float) -> void:
	if amount <= 0.0:
		return
	current_hp = maxf(0.0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)
	if current_hp <= 0.0:
		destroyed.emit()
		queue_free()

