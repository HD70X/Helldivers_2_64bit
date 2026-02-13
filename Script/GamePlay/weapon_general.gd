# weapon_general
extends Node2D

@export var bullet_scene: PackedScene # 可配置的子弹场景
@onready var muzzle = $Muzzle
@onready var muzzle_light = $Muzzle/PointLight2D
@onready var anim = $AnimatedSprite2D

# 这是一个信号：告诉外界我发射了子弹，并把位置和方向传出去
signal bullet_fired(scene, position, direction)

# 开火方法：这个方法只负责“表演”和“触发信号”
func fire(dir: Vector2):
	# 表演部分：枪口闪光逻辑
	_play_muzzle_flash()
	anim.play("shoot")
	
	# 逻辑部分：发出信号，让更高层级去创建子弹
	# 这样做的好处是：武器不负责“实例化”，所以不用担心生命周期管理
	bullet_fired.emit(bullet_scene, muzzle.global_position, dir)

func _play_muzzle_flash():
	muzzle_light.enabled = true
	var tween = create_tween()
	tween.tween_property(muzzle_light, "energy", 0.0, 0.1)
	tween.finished.connect(func(): muzzle_light.enabled = false)
