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
