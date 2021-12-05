local Action = require(script.Parent.Action)

return Action("StampObjectVerticalOffsetSet", function(guid, mode)
	return {
		guid = guid,
		mode = mode
	}
end)