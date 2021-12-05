local Action = require(script.Parent.Action)

return Action("StampObjectVerticalOffsetSet", function(guid, fixed)
	return {
		guid = guid,
		fixed = fixed
	}
end)