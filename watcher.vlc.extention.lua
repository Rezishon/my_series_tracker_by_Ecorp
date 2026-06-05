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
