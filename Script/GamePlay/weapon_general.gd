extends Node2D

# --- 武器配置参数 ---
@export_group("Ammo System")
@export var mag_count: int = 4        # 备用弹匣数量
@export var mag_size: int = 30        # 每个弹匣弹药量
@export var current_ammo: int = 30    # 当前弹匣剩余

@export_group("Firing Specs")
@export var bullet_speed: float = 800.0
@export var fire_rate: float = 0.1    # 连射间隔（秒）
@export var is_full_auto: bool = true # 是否全自动

# --- 内部状态 ---
var can_fire: bool = true
var is_reloading: bool = false
@onready var fire_timer = Timer.new() # 控制连射频率

signal bullet_fired(pos, dir, speed)
signal ammo_changed(current, mags)

func _ready():
	add_child(fire_timer)
	fire_timer.one_shot = true
	fire_timer.timeout.connect(func(): can_fire = true)

# 外部调用的开火尝试
func try_fire(dir: Vector2):
	if not can_fire or is_reloading or current_ammo <= 0:
		return
	
	# 执行开火逻辑
	_execute_fire(dir)
	
	# 如果是半自动，执行一次后设为 false 直到松开按键（需配合输入逻辑）
	# 这里演示简单的连射频率控制
	can_fire = false
	fire_timer.start(fire_rate)

func _execute_fire(dir: Vector2):
	current_ammo -= 1
	ammo_changed.emit(current_ammo, mag_count)
	
	_play_muzzle_flash()
	# _play_weapon_animation("shoot") # 播放射击动画
	
	bullet_fired.emit($Muzzle.global_position, dir, bullet_speed)

# 换弹逻辑：抛弃当前弹匣
func start_reload():
	if mag_count <= 0 or is_reloading or current_ammo == mag_size:
		return
		
	is_reloading = true
	# _play_weapon_animation("reload") # 播放换弹动画
	
	await get_tree().create_timer(2.0).timeout 
	
	mag_count -= 1
	current_ammo = mag_size
	is_reloading = false
	_play_weapon_animation("idle") # 回到待机
	ammo_changed.emit(current_ammo, mag_count)
	
func _play_muzzle_flash():
	if not $Muzzle/PointLight2D: return
	
	var flash = $Muzzle/PointLight2D
	flash.enabled = true
	flash.energy = 1.5 # 初始亮度
	
	# 使用 Tween 实现极速衰减，模拟火药燃爆
	var tween = create_tween()
	tween.tween_property(flash, "energy", 0.0, 0.1) # 0.1秒内熄灭
	tween.finished.connect(func(): flash.enabled = false)

# --- 动画控制接口 ---
func _play_weapon_animation(anim_name: String):
	if $AnimatedSprite2D.sprite_frames.has_animation(anim_name):
		$AnimatedSprite2D.play(anim_name)
