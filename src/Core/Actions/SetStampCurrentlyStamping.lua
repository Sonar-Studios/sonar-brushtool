local Action = require(script.Parent.Action)

return Action("StampCurrentlyStampingSet", function(guid)
	return {
		guid = guid
	}
end)