local Action = require(script.Parent.Action)

return Action("StampObjectVerticalOffsetSet", function(guid, min)
	return {
		guid = guid,
		min = min
	}
end)