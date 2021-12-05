local Action = require(script.Parent.Action)

return Action("StampObjectVerticalOffsetSet", function(guid, max)
	return {
		guid = guid,
		max = max
	}
end)