package.path = package.path .. ";/your/absolute/directory/to/repository.lua"
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

local database_file = io.open(database_path, "r")
local database_line_by_line = repo.read_file_line_by_line(database_file)
local season_validation_flag = true
local episode_validation_flag = true

for _, v in ipairs(database_line_by_line) do
	if string.match(v, metadata_key_patterns.season_key_pattern) then
		print("found season")
		season_validation_flag = false
	elseif string.match(v, metadata_key_patterns.episode_key_pattern) then
		print("found episode")
		episode_validation_flag = false
	end
end

print(season_validation_flag, episode_validation_flag)
if season_validation_flag == false or episode_validation_flag == false then
	io.stderr:write("\n\27[31mThe given file didn't found!\n")
	os.exit(1, true)
end

database_file = io.open(database_path, "r")
local database_data = {}

while true do
	table.insert(database_data, database_file:read("*l"))
	if database_data[#database_data] == "[season]" then
		table.insert(database_data, database_file:read("*l"))

		local tmp_value = repo.string_splitter(database_data[#database_data], "=")

		if tmp_file_metadata.season == tmp_value[1] then
			break
		end
	end
end

table.insert(database_data, database_file:read("*l"))
if database_data[#database_data] == "[episode]" then
	while true do
		table.insert(database_data, database_file:read("*l"))
		local tmp_value = repo.string_splitter(database_data[#database_data], "=")

		if tmp_file_metadata.episode == tmp_value[1] then
			if string.match(database_data[#database_data], "false") then
				database_data[#database_data] = string.gsub(database_data[#database_data], "false", watch_status)
			elseif string.match(database_data[#database_data], "true") then
				database_data[#database_data] = string.gsub(database_data[#database_data], "true", watch_status)
			end
			database_data[#database_data] = string.gsub(database_data[#database_data], ",%d+.*", "," .. watched_time)

			break
		elseif tmp_value[1] == nil then
			io.stderr:write("\n\27[31mThe given file didn't found!\n")
			break
		end
	end
end

for i = #database_data + 1, #database_line_by_line do
	table.insert(database_data, database_line_by_line[i])
end

database_file = io.open(database_path, "w+")
for _, v in ipairs(database_data) do
	database_file:write(v .. "\n")
end

database_file:close()
