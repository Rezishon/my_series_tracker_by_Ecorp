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
local database_path = dir_path .. "/.database.json"

local comma_handler = function(database, comma_flag)
	if comma_flag then
		database:write(",")
	end
	return true
end

-- NOTE: This is a path fixer
database_path = database_path:gsub("%s*//%s*", "/")

if dir_path == nil then
	io.stderr:write("\n\27[31mPlease give the series directory path as an argument\nUse -h or --help for mor info\n\n")
	os.exit(1, true)
end

if dir_path:match("--help=") or dir_path:match("-h") then
	io.stdout:write("\nargs:\n1: series directory path\n2(optional): files name format\n\n")
	os.exit(1, true)
end

if io.open(dir_path, "r") == nil then
	io.stderr:write("\n\27[31mInvalid directory path given: " .. dir_path .. "\n\n")
	os.exit(1, true)
end

local tmp_dir_list = io.popen("ls " .. dir_path)
dir_list = tmp_dir_list:read("*a")
tmp_dir_list:close()

-- TODO: check if files format inserted =>
-- place it in the following gmatch
-- TODO: if metadata file presents =>
-- take the data from there, needed to
-- handle things on format inserted or not
-- and overwrite or not
-- TODO: Check how to know what length of video
-- does watched automatically
--
for season_match in string.gmatch(dir_list, season_format) do
	for full_match in string.gmatch(dir_list, season_match .. episode_format) do
		for episode_match in string.gmatch(full_match, episode_format) do
			if data[season_match] == nil then
				data[season_match] = {}
			end
			data[season_match][episode_match] = false
		end
	end
end
data = repo.season_and_episode_structure_builder(dir_list, season_pattern, episode_pattern)

local database = io.open(database_path, "w")
database:write("{\n")
for i, v in pairs(data) do
	season_comma_flag = comma_handler(database, season_comma_flag)

	database:write('"' .. i .. '"' .. ":{" .. "\n")

	for ii, vv in pairs(v) do
		episode_comma_flag = comma_handler(database, episode_comma_flag)

		database:write('"' .. ii .. '"' .. ":")
		database:write('{ "watched" : false, "timeOfWatch" : "00:00" }')
	end
	episode_comma_flag = false

	database:write("\n}")
end
database:write("\n}")

database = io.open(database_path, "w+")
local tmp_json_file = io.popen(
	"jq 'to_entries | sort_by(.key) | from_entries | .[] |= (to_entries | sort_by(.key) | from_entries)' "
		.. database_path
)
database:write(tmp_json_file:read("*a"))

database:close()
tmp_json_file:close()
