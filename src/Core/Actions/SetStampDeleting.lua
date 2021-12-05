local Action = require(script.Parent.Action)

return Action("StampDeletingSet", function(guid)
	return {
		guid = guid
	}
end)