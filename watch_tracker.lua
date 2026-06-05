local repo = require("repository")

local dir_path = arg[1]
repo.dir_path_validator(dir_path)
local file_name = arg[2]
local watch_status = arg[3]
local watched_time = arg[4]
local database_path = repo.path_fixer(repo.database_path(dir_path))
local metadata_path = repo.path_fixer(repo.metadata_path(dir_path))
local metadata_key_patterns = {
	season_key_pattern = "^season=%s*",
	episode_key_pattern = "^episode=%s*",
}
local metadata = {}

