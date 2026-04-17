Repository = {}

Repository.database_path = function(dir_path)
	return dir_path .. "/.database.json"
end

Repository.path_fixer = function(path)
	return path:gsub("%s*//%s*", "/")
end

return Repository
