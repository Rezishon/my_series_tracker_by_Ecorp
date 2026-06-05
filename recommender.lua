local repo = require("repository")

local dir_path = arg[1]
repo.dir_path_validator(dir_path)
local database_path = repo.path_fixer(repo.database_path(dir_path))
local metadata_path = repo.path_fixer(repo.metadata_path(dir_path))
local database_data_line_by_line = {}
local recommend_item = { season = "", episode = "" }
local current_season = ""


local database_file = io.open(database_path, "r")
database_data_line_by_line = repo.read_file_line_by_line(database_file)
database_file = io.open(database_path, "r")

local database_data = {}

::find_new_season::
while true do
	table.insert(database_data, database_file:read("*l"))
	if database_data[#database_data] == "[season]" then
		table.insert(database_data, database_file:read("*l"))

		local tmp_value = repo.string_splitter(database_data[#database_data], "=")

		if tmp_value[2] == "false" then
			recommend_item.season = tmp_value[1]
			break
    elseif tmp_value[2] == "true" then
      goto find_new_season
		end
	elseif database_data[#database_data] == '' and #database_data == #database_data_line_by_line then
		io.stderr:write("\n\27[31mNo video found to watch :(\n")
		os.exit(1, true)
	end
end

table.insert(database_data, database_file:read("*l"))
if database_data[#database_data] == "[episode]" then
	while true do
		table.insert(database_data, database_file:read("*l"))
		local tmp_value = repo.string_splitter(database_data[#database_data], "=")

		if tmp_value[1] == nil then
      goto find_new_season
		elseif string.match(tmp_value[2], "false") == "false" then
			recommend_item.episode = tmp_value[1]
			break
		end
	end
end

local dir_list = repo.list_of_dir(dir_path)
dir_list = repo.string_splitter(dir_list, '\n')
local file_name = ''
for _,v in ipairs(dir_list) do
  if string.match(v, recommend_item.season) and string.match(v, recommend_item.episode) then
    file_name = v
  end
end

print("Do you want to watch?\tY/n")
print("Season: " .. recommend_item.season  )
print("Episode: " .. recommend_item.episode)
local input = io.read(1)
if input == 'y' or input == 'Y' or input == '\n'  then
  print("xdg-open " .. dir_path .."/" .. file_name)
  local exec = io.popen("xdg-open " .. dir_path .."/" .. file_name)
  exec:close()
  os.exit(0, true)
else
  print("Maybe we will watch it next time :)")
end


database_file:close()
