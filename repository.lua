Repository = {}

Repository.database_path = function(dir_path)
	return dir_path .. "/.database.json"
end

Repository.metadata_path = function(dir_path)
	return dir_path .. "/.metadata.json"
end

Repository.dir_path_validator = function(dir_path)
	if dir_path == nil then
		io.stderr:write(
			"\n\27[31mPlease give the series directory path as an argument\nUse -h or --help for mor info\n\n"
		)
		os.exit(1, true)
	elseif dir_path:match("--help=") or dir_path:match("-h") then
		io.stdout:write("\nargs:\n1: series directory path\n2: Season pattern\n3: Episode pattern\n\n")
		os.exit(1, true)
	end

	if io.open(dir_path, "r") == nil then
		io.stderr:write("\n\27[31mInvalid directory path given: " .. dir_path .. "\n\n")
		os.exit(1, true)
	end
end

Repository.path_fixer = function(path)
	return path:gsub("%s*//%s*", "/")
end

Repository.list_of_dir = function(dir_path)
	local dir_listing = io.popen("ls " .. dir_path)
	local dir_list = dir_listing:read("*a")
	dir_listing:close()

	return dir_list
end

Repository.season_and_episode_structure_builder = function(dir_list, season_pattern, episode_pattern)
	local data = {}
	for season_match in string.gmatch(dir_list, season_pattern) do
		for full_match in string.gmatch(dir_list, season_match .. episode_pattern) do
			for episode_match in string.gmatch(full_match, episode_pattern) do
				if data[season_match] == nil then
					data[season_match] = {}
				end
				data[season_match][episode_match] = false
			end
		end
	end
	return data
end

Repository.comma_handler = function(database, comma_flag)
	if comma_flag then
		database:write(",")
	end
	return true
end

Repository.season_and_episode_structure_writer = function(database, data, level_one_comma_flag, level_two_comma_flag)
	database:write("{\n")
	for i, v in pairs(data) do
		level_one_comma_flag = Repository.comma_handler(database, level_one_comma_flag)

		database:write('"' .. i .. '"' .. ":{" .. "\n")

		for ii, vv in pairs(v) do
			level_two_comma_flag = Repository.comma_handler(database, level_two_comma_flag)

			database:write('"' .. ii .. '"' .. ":")
			database:write('{ "watched" : false, "timeOfWatch" : "00:00" }')
		end
		level_two_comma_flag = false

		database:write("\n}")
	end
	database:write("\n}")
end

Repository.metadata_structure_writer = function(metadata, data, level_one_comma_flag)
	metadata:write("{\n")
	for i, v in pairs(data) do
		level_one_comma_flag = Repository.comma_handler(metadata, level_one_comma_flag)

		metadata:write('"' .. i .. '"' .. ":" .. '"' .. v .. '"')
	end
	metadata:write("\n}")
end

Repository.database_file_organizer = function(file, database_path)
	local json_file = io.popen(
		"jq 'to_entries | sort_by(.key) | from_entries | .[] |= (to_entries | sort_by(.key) | from_entries)' "
			.. database_path
	)
	file:write(json_file:read("*a"))
	json_file:close()
end

return Repository
