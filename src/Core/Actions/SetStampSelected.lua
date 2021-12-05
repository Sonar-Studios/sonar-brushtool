local Action = require(script.Parent.Action)

return Action("StampSelectedSet", function(guid)
	return {
		guid = guid
	}
end)