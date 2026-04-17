Repository = {}

Repository.database_path = function(dir_path)
	return dir_path .. "/.database.json"
end

return Repository
