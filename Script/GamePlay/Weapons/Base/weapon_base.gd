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
@export var is_full_auto: bool = true
@export var bullet_scene: PackedScene
@export var pellets_per_shot: int = 1

@export_group("Spread")
@export var min_spread_degrees: float = 0.0
@export var max_spread_degrees: float = 0.0
@export var spread_increase_per_shot_degrees: float = 0.0
@export var spread_recovery_per_second_degrees: float = 0.0
@export var current_spread_degrees: float = 0.0

@export_group("Reload")
@export var reload_time: float = 2.0

@export_group("Muzzle Flash")
@export var flash_peak_energy: float = 1.5
@export var flash_fade_time: float = 0.08

var can_fire := true
var is_reloading := false
var flash_tween: Tween
var _fired_this_frame := false
@onready var fire_timer: Timer = Timer.new()
@onready var muzzle: Node2D = get_node_or_null("Muzzle")
@onready var muzzle_flash: PointLight2D = get_node_or_null("Muzzle/PointLight2D")

func _ready() -> void:
	_sanitize_exports()
	current_spread_degrees = min_spread_degrees
	add_child(fire_timer)
	fire_timer.one_shot = true
	fire_timer.timeout.connect(func(): can_fire = true)
	if muzzle_flash:
		muzzle_flash.enabled = false
		muzzle_flash.energy = 0.0

func _process(delta: float) -> void:
	if _fired_this_frame:
		_fired_this_frame = false
		return
	current_spread_degrees = move_toward(
		current_spread_degrees,
		min_spread_degrees,
		spread_recovery_per_second_degrees * delta
	)

func try_fire(dir: Vector2) -> void:
	if not can_fire or is_reloading or current_ammo <= 0:
		return
	var base_dir := dir.normalized()
	if base_dir == Vector2.ZERO:
		base_dir = Vector2.RIGHT
	current_ammo -= 1
	ammo_changed.emit(current_ammo, mag_count)
	var fire_origin := global_position
	if muzzle:
		fire_origin = muzzle.global_position
	for projectile_dir in _build_projectile_directions(base_dir):
		bullet_fired.emit(fire_origin, projectile_dir, bullet_speed)
	_play_muzzle_flash()
	_play_weapon_animation("shoot")
	current_spread_degrees = clampf(
		current_spread_degrees + spread_increase_per_shot_degrees,
		min_spread_degrees,
		max_spread_degrees
	)
	can_fire = false
	_fired_this_frame = true
	fire_timer.start(_get_fire_interval())

func start_reload() -> void:
	if mag_count <= 0 or is_reloading or current_ammo >= mag_size:
		return
	is_reloading = true
	_play_weapon_animation("reload")
	await get_tree().create_timer(reload_time).timeout
	mag_count -= 1
	current_ammo = mag_size
	is_reloading = false
	_play_weapon_animation("idle")
	ammo_changed.emit(current_ammo, mag_count)

func get_bullet_scene() -> PackedScene:
	return bullet_scene

func _get_fire_interval() -> float:
	if rounds_per_minute > 0.0:
		return max(60.0 / rounds_per_minute, 0.001)
	return 0.1

func _build_projectile_directions(base_dir: Vector2) -> Array[Vector2]:
	var directions: Array[Vector2] = []
	for _i in range(pellets_per_shot):
		var spread_offset := randf_range(-current_spread_degrees, current_spread_degrees)
		directions.append(base_dir.rotated(deg_to_rad(spread_offset)).normalized())
	return directions

func _sanitize_exports() -> void:
	pellets_per_shot = max(1, pellets_per_shot)
	min_spread_degrees = maxf(0.0, min_spread_degrees)
	max_spread_degrees = maxf(min_spread_degrees, max_spread_degrees)
	spread_increase_per_shot_degrees = maxf(0.0, spread_increase_per_shot_degrees)
	spread_recovery_per_second_degrees = maxf(0.0, spread_recovery_per_second_degrees)

func _play_muzzle_flash() -> void:
	if muzzle_flash == null:
		return
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()
	muzzle_flash.enabled = true
	muzzle_flash.energy = flash_peak_energy
	flash_tween = create_tween()
	flash_tween.tween_property(muzzle_flash, "energy", 0.0, flash_fade_time)
	flash_tween.finished.connect(func():
		if is_instance_valid(muzzle_flash):
			muzzle_flash.enabled = false
	)

func _play_weapon_animation(anim_name: String) -> void:
	var animated_sprite := get_node_or_null("AnimatedSprite2D")
	if animated_sprite and animated_sprite is AnimatedSprite2D:
		var sprite := animated_sprite as AnimatedSprite2D
		if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
			sprite.play(anim_name)
