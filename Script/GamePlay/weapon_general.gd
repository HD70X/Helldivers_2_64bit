extends Node2D

# --- 武器配置参数 ---
@export_group("Ammo System")
@export var mag_count: int = 4        # 备用弹匣数量
@export var mag_size: int = 30        # 每个弹匣弹药量
@export var current_ammo: int = 30    # 当前弹匣剩余

@export_group("Firing Specs")
@export var bullet_speed: float = 800.0
@export var fire_rate: float = 500.0    # 射速（RPM：每分钟发射数）
@export var is_full_auto: bool = true # 是否全自动
@export var bullet_scene: PackedScene

@export_group("Reload")
@export var reload_time: float = 2.0

@export_group("Muzzle Flash")
@export var flash_peak_energy: float = 1.5
@export var flash_fade_time: float = 0.08

# --- 内部状态 ---
var can_fire: bool = true
var is_reloading: bool = false
var flash_tween: Tween
@onready var fire_timer = Timer.new() # 控制连射频率
@onready var muzzle: Node2D = get_node_or_null("Muzzle")
@onready var muzzle_flash: PointLight2D = get_node_or_null("Muzzle/PointLight2D")

signal bullet_fired(pos, dir, speed)
signal ammo_changed(current, mags)

func _ready():
	add_child(fire_timer)
	fire_timer.one_shot = true
	fire_timer.timeout.connect(func(): can_fire = true)
	if muzzle_flash:
		muzzle_flash.enabled = false
		muzzle_flash.energy = 0.0

# 外部调用的开火尝试
func try_fire(dir: Vector2):
	if not can_fire or is_reloading or current_ammo <= 0:
		return
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT
	
	# 执行开火逻辑
	_execute_fire(dir.normalized())
	
	# 如果是半自动，执行一次后设为 false 直到松开按键（需配合输入逻辑）
	# 这里演示简单的连射频率控制
	can_fire = false
	fire_timer.start(_get_fire_interval())

func _execute_fire(dir: Vector2):
	current_ammo -= 1
	ammo_changed.emit(current_ammo, mag_count)
	
	_play_muzzle_flash()
	# _play_weapon_animation("shoot") # 播放射击动画
	var muzzle_pos := global_position
	if muzzle:
		muzzle_pos = muzzle.global_position
	bullet_fired.emit(muzzle_pos, dir, bullet_speed)

# 换弹逻辑：抛弃当前弹匣
func start_reload():
	if mag_count <= 0 or is_reloading or current_ammo == mag_size:
		return
		
	is_reloading = true
	# _play_weapon_animation("reload") # 播放换弹动画
	
	await get_tree().create_timer(reload_time).timeout 
	
	mag_count -= 1
	current_ammo = mag_size
	is_reloading = false
	_play_weapon_animation("idle") # 回到待机
	ammo_changed.emit(current_ammo, mag_count)

func get_bullet_scene() -> PackedScene:
	return bullet_scene

func _get_fire_interval() -> float:
	if fire_rate > 0.0:
		return max(60.0 / fire_rate, 0.001)
	return 0.1
	
func _play_muzzle_flash():
	if muzzle_flash == null:
		return
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()

	muzzle_flash.enabled = true
	muzzle_flash.energy = flash_peak_energy

	# 用光强做快速衰减，避免频繁改 visible 的突兀闪烁
	flash_tween = create_tween()
	flash_tween.tween_property(muzzle_flash, "energy", 0.0, flash_fade_time)
	flash_tween.finished.connect(func():
		if is_instance_valid(muzzle_flash):
			muzzle_flash.enabled = false
	)

# --- 动画控制接口 ---
func _play_weapon_animation(anim_name: String):
	if $AnimatedSprite2D.sprite_frames.has_animation(anim_name):
		$AnimatedSprite2D.play(anim_name)
