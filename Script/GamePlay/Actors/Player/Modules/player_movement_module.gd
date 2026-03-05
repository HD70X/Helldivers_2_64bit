extends Node
class_name PlayerMovementModule

@export var speed: float = 220.0
@export var friction: float = 900.0
@export var gravity: float = 980.0

func tick_physics(host: CharacterBody2D, delta: float) -> void:
	if not host.is_on_floor():
		host.velocity.y += gravity * delta

	var input_axis := Input.get_axis("move_left", "move_right")
	if input_axis != 0.0:
		host.velocity.x = input_axis * speed
	else:
		host.velocity.x = move_toward(host.velocity.x, 0.0, friction * delta)

	host.move_and_slide()
