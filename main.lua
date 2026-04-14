local dir_path = arg[1]
local dir_list = ""
local season_format = arg[2]
local episode_format = arg[3]
local data = {}
local database_path = dir_path .. "/.database.json"
local episode_comma_flag = false
local season_comma_flag = false

local comma_handler = function(database, comma_flag)
	if comma_flag then
		database:write(",")
	end
	return true
end

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
-- TODO: save data in a hidden file
-- TODO: if metadata file presents =>
-- take the data from there, needed to
-- handle things on format inserted or not
-- and overwrite or not
-- TODO: Check how to know what length of video
-- does watched automatically
local tb = {}
for match in string.gmatch(dir_list, "%s*E03%s*") do
	table.insert(tb, match)
end

for _, v in ipairs(tb) do
	print(v)
end
-- end
-- print(string.match(dir_list, "^Mm%s*"))
