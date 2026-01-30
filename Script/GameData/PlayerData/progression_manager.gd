extends Node
class_name ProgressionManager

var unlocked_season: Array = []
var unlocked_level: Dictionary = {}
var default_next_level: Dictionary = {}

func add_level_record(level_id: String, season_id: String, completed: bool, secondary_1: bool, secondary_2:bool, stars: int):
	if unlocked_level.has(level_id):
		var old = unlocked_level[level_id]
		unlocked_level[level_id] = {
			"season_id" : season_id,
			"completed" : completed or old.get("completed", false),
			"secondary_1" : secondary_1 or old.get("secondary_1", false),
			"secondary_2" : secondary_2 or old.get("secondary_2", false),
			"stars" : max(stars, old.get("stars", 0))
		}
	else:
		unlocked_level[level_id] = {
			"season_id" : season_id, "completed" : completed, "secondary_1" : secondary_1, "secondary_2" : secondary_2, "stars" : stars
			}

func is_season_onlocked(season_id: String) -> bool:
	return season_id in unlocked_season
	
func get_season_status(season_id: String) -> int:
	var own_stars = 0
	if season_id in unlocked_season:
		for level in unlocked_level:
			if unlocked_level.get(level).get("season_id") == season_id:
				own_stars += unlocked_level.get(level).get("stars")
	return own_stars

func to_dict() -> Dictionary:
	return {"unlocked_season" : unlocked_season, "unlocked_level" : unlocked_level, "default_next_level" : default_next_level}

func from_dict(_data: Dictionary):
	unlocked_season = _data.get("unlocked_season", ["S1"])
	unlocked_level = _data.get("unlocked_level", {})
	default_next_level = _data.get("default_next_level", {})

func unlock_season(_season_id: String):
	if _season_id in unlocked_season:
		pass
	else:
		unlocked_season.append(_season_id)

func record_default_level(_season_id: String, _level_id: String):
	default_next_level = {
		"season_id" : _season_id,
		"level_id" : _level_id
	}
