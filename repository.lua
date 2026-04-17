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

return Repository
