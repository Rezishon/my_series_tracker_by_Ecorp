Repository = {}

Repository.database_path = function(dir_path, prefix)
	if prifix then
		return dir_path .. "/." .. prefix .. ".database.ini"
	end
	return dir_path .. "/.database.ini"
end

Repository.metadata_path = function(dir_path)
	return dir_path .. "/.metadata.ini"
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
	local seasons = {}
	local episodes = {}
	local first_season_flag = true
	local add_access_flag = true

	for season_match in string.gmatch(dir_list, season_pattern) do
		if first_season_flag then
			table.insert(seasons, season_match)
			first_season_flag = false
		end

		for _, v in ipairs(seasons) do
			if v == season_match then
				add_access_flag = false
			else
				add_access_flag = true
			end
		end

		if add_access_flag then
			table.insert(seasons, season_match)
		end
	end

	for _, season in ipairs(seasons) do
		for full_match in string.gmatch(dir_list, season .. episode_pattern) do
			for episode_match in string.gmatch(full_match, episode_pattern) do
				table.insert(episodes, episode_match)
			end
		end
		table.insert(episodes, "end")
	end

	table.remove(episodes, #episodes)

	return seasons, episodes
end

Repository.comma_handler = function(database, comma_flag)
	if comma_flag then
		database:write(",")
Repository.season_and_episode_structure_writer = function(database, seasons, episodes)
	local episodes_items = Repository.table_splitter(episodes, "end")
	for i, v in ipairs(seasons) do
		database:write("[season]\n")

		database:write(v .. "=false\n")

		database:write("[episode]\n")

		for _, vv in ipairs(episodes_items[i]) do
			database:write(vv .. "=false,0\n")
		end
		database:write("\n")
	end
end

Repository.metadata_structure_writer = function(metadata, season_pattern, episode_pattern)
	metadata:write("[pattern]\n")
	metadata:write("season=" .. season_pattern .. "\n")
	metadata:write("episode=" .. episode_pattern)
end

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

Repository.metadata_file_organizer = function(file, metadata_path)
	local json_file = io.popen("jq 'to_entries | sort_by(.key) | from_entries' " .. metadata_path)
	file:write(json_file:read("*a"))
	json_file:close()
end

return Repository
