local function file_name_finder()
	local item = vlc.input.item()
	if not item then
		return nil
	end
	local tmp_value = string.gsub(item:uri(), "file:///%w*/user", "~")
	return string.match(tmp_value, "([^/]+)$")
end

local function path_finder(item_url)
	local fixed_item_url = ""
	fixed_item_url = string.gsub(item_url, "file:///%w*/user", "~")
	fixed_item_url = string.gsub(fixed_item_url, file_name_finder(), "")

	return fixed_item_url
end

local function command_builder(item, title, status, time)
	return "lua"
		.. " "
		.. "/your/absolute/directory/to/watch_tracker.lua"
		.. " "
		.. path_finder(item:uri())
		.. " "
		.. title
		.. " "
		.. tostring(status)
		.. " "
		.. math.floor(math.floor(math.floor(time) / 1000000) / 60)
end

local function executer(status)
	local item = vlc.input.item()
	local input = vlc.object.input()
	local time = vlc.var.get(input, "time")
	local title = file_name_finder()

	local exec = io.popen(command_builder(item, title, status, time))
	vlc.msg.info("==========================================")
	vlc.msg.info(command_builder(item, title, status, time))
	vlc.msg.info(exec:read("*a"))
	exec:close()
end

function descriptor()
	return {
		title = "Series Tracker",
		version = "0.16.2",
		author = "Rezishon",
		description = "This is a series tracker from Rezishon",
	}
end

function activate()
	executer(true)
end

function deactivate()
	executer(false)
end
