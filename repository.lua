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

Repository.table_splitter = function(t, delimiter)
	local result = {}
	local tmp_result = {}

	for _, value in ipairs(t) do
		if value ~= delimiter then
			table.insert(tmp_result, value)
		else
			table.insert(result, tmp_result)
			tmp_result = {}
		end
	end
	table.insert(result, tmp_result)
	tmp_result = {}

	return result
end

Repository.table_joiner = function(t, delimiter)
	local result = {}

	for _, v in ipairs(t) do
		for _, vv in ipairs(v) do
			table.insert(result, vv)
		end
		table.insert(result, delimiter)
	end

	table.remove(result, #result)

	return result
end

Repository.string_splitter = function(s, delimiter)
	local result = {}
	for match in string.gmatch(s, "[^" .. delimiter .. "]+") do
		table.insert(result, match)
	end
	return result
end

Repository.read_file_line_by_line = function(file)
	local result = {}
	local tmp_data
	while true do
		tmp_data = file:read("*l")

		if not tmp_data then
			break
		end

		table.insert(result, tmp_data)
	end

	return result
end

Repository.metadata_file_parser = function(metadata_line_by_line, season_key_pattern, episode_key_patterna)
	local validation_flag = false
	local season_pattern = ""
	local episode_pattern = ""

	for _, v in ipairs(metadata_line_by_line) do
		if not validation_flag and v == "[pattern]" then
			validation_flag = true
			goto continue
		end

		if "season=" == string.match(v, season_key_pattern) then
			local _, season_end_index = string.find(v, season_key_pattern)
			season_pattern = string.sub(v, season_end_index + 1, #v)
		elseif "episode=" == string.match(v, episode_key_patterna) then
			local _, episode_end_index = string.find(v, episode_key_patterna)
			episode_pattern = string.sub(v, episode_end_index + 1, #v)
		end

		::continue::
	end

	return season_pattern, episode_pattern
end

return Repository
