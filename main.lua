local repo = require("repository")

local dir_path = arg[1]
repo.dir_path_validator(dir_path)
local season_pattern = arg[2]
local episode_pattern = arg[3]
local database_path = repo.path_fixer(repo.database_path(dir_path))
local metadata_path = repo.path_fixer(repo.metadata_path(dir_path))
local dir_list = ""
local seasons = {}
local episodes = {}


dir_list = repo.list_of_dir(dir_path)

seasons, episodes = repo.season_and_episode_structure_builder(dir_list, season_pattern, episode_pattern)

local database = io.open(database_path, "w")
repo.season_and_episode_structure_writer(database, seasons, episodes)
database:close()

local metadata = io.open(metadata_path, "w")
repo.metadata_structure_writer(metadata, season_pattern, episode_pattern)

metadata:close()
