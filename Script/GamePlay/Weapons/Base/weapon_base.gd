extends Node2D
class_name WeaponBase

signal bullet_fired(origin: Vector2, dir: Vector2, speed: float)
signal ammo_changed(current: int, mags: int)

@export_group("Ammo")
@export var mag_count: int = 4
@export var mag_size: int = 30
@export var current_ammo: int = 30

@export_group("Fire")
@export var bullet_speed: float = 800.0
@export var rounds_per_minute: float = 500.0

var can_fire := true
var is_reloading := false
@onready var fire_timer: Timer = Timer.new()

func _ready() -> void:
	add_child(fire_timer)
	fire_timer.one_shot = true
	fire_timer.timeout.connect(func(): can_fire = true)

func try_fire(dir: Vector2) -> void:
	if not can_fire or is_reloading or current_ammo <= 0:
		return
	current_ammo -= 1
	ammo_changed.emit(current_ammo, mag_count)
	bullet_fired.emit(global_position, dir, bullet_speed)
	can_fire = false
	fire_timer.start(_get_fire_interval())

func start_reload(reload_time: float = 2.0) -> void:
	if mag_count <= 0 or is_reloading or current_ammo >= mag_size:
		return
	is_reloading = true
	await get_tree().create_timer(reload_time).timeout
	mag_count -= 1
	current_ammo = mag_size
	is_reloading = false
	ammo_changed.emit(current_ammo, mag_count)

func _get_fire_interval() -> float:
	if rounds_per_minute > 0.0:
		return max(60.0 / rounds_per_minute, 0.001)
	return 0.1
