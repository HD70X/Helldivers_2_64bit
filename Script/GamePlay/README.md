# GamePlay 脚本分层（角色/武器）

本目录先建立可扩展骨架，避免直接移动旧脚本导致场景引用失效。

## 目录建议

- `Actors/Player/`
  - `player_character.gd`：玩家角色聚合根（组合移动/生命/装备模块）
  - `Modules/player_movement_module.gd`
  - `Modules/player_health_module.gd`
  - `Modules/player_equipment_module.gd`
- `Weapons/Base/`
  - `weapon_base.gd`：武器通用逻辑（开火节流、弹药、换弹）
- `Weapons/Projectiles/`
  - `projectile_base.gd`：投射物通用逻辑（速度、伤害、寿命、命中回调）
- `Networking/`
  - `network_sync_bridge.gd`：网络层桥接（输入快照/状态同步，不耦合核心玩法）

## 为什么先不直接移动旧脚本

Godot 场景和资源通常通过 `res://...` 路径引用脚本。直接在文件系统中移动会导致路径失效。
建议使用 Godot 编辑器内置重命名/移动，或在迁移期间保留旧入口做转发。

## 迁移步骤（安全）

1. 新功能只写入新目录结构。
2. 旧脚本逐步改为调用新模块。
3. 在编辑器中移动并让 Godot 更新依赖路径。
4. 最后删除旧脚本。
