local repo = require("repository")

local dir_path = arg[1]
repo.dir_path_validator(dir_path)
local season_pattern = arg[2]
local episode_pattern = arg[3]
local database_path = repo.path_fixer(repo.database_path(dir_path))
local metadata_path = repo.path_fixer(repo.metadata_path(dir_path))
local level_one_comma_flag = false
local level_two_comma_flag = false
local dir_list = ""
local data = {}


dir_list = repo.list_of_dir(dir_path)

data = repo.season_and_episode_structure_builder(dir_list, season_pattern, episode_pattern)

local database = io.open(database_path, "w")





database = io.open(database_path, "w+")
local tmp_json_file = io.popen(
	"jq 'to_entries | sort_by(.key) | from_entries | .[] |= (to_entries | sort_by(.key) | from_entries)' "
		.. database_path
)
database:write(tmp_json_file:read("*a"))

database:close()
tmp_json_file:close()
