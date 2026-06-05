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

local metadata_file = io.open(metadata_path, "r")
local metadata_data = repo.read_file_line_by_line(metadata_file)
metadata_file:close()

metadata.season_pattern, metadata.episode_pattern = repo.metadata_file_parser(
	metadata_data,
	metadata_key_patterns.season_key_pattern,
	metadata_key_patterns.episode_key_pattern
)

local tmp_file_metadata = {}
for match in string.gmatch(file_name, metadata.season_pattern .. metadata.episode_pattern) do
	tmp_file_metadata.season = string.match(match, metadata.season_pattern)
	tmp_file_metadata.episode = string.match(match, metadata.episode_pattern)
end

