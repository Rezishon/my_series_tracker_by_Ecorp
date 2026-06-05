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

