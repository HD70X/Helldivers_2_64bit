# base_game_save.gd
extends Node
class_name GameSave

# 该脚本提供基础的存档读取和写入功能，可通过与之配套的脚本定义具体项目中的存储规则
const PASSWORD = "IDIDNOTCHANGEPASSWORD" # 加密密码

# 保存
static func save_game(data: Dictionary, save_path: String):
	var config = ConfigFile.new()
	var dir = save_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		var err = DirAccess.make_dir_recursive_absolute(dir)
		if err != OK:
			return
	# 利用 ConfigFile 特性：自动分区块存储
	for section in data.keys():
		for key in data[section].keys():
			config.set_value(section, key, data[section][key])
	
	var err = config.save_encrypted_pass(save_path, PASSWORD)
	# 详细的错误码说明
	match err:
		OK:
			print("✓ 文件保存成功: ", save_path)
		ERR_FILE_CANT_OPEN:
			push_error("无法打开文件进行写入，可能是权限问题")
		ERR_FILE_CANT_WRITE:
			push_error("无法写入文件")
		ERR_CANT_CREATE:
			push_error("无法创建文件")
		_:
			push_error("保存文件失败，错误码: " + str(err))
	

# 读取
static func load_game(save_path: String) -> Dictionary:
	var config = ConfigFile.new()
	if config.load_encrypted_pass(save_path, PASSWORD) != OK:
		print("未能正确加载存档")
		return {}
	
	var data = {}
	for section in config.get_sections():
		data[section] = {}
		for key in config.get_section_keys(section):
			data[section][key] = config.get_value(section, key)
	print("加载存档：", data)
	return data
