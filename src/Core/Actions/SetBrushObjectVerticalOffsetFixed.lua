local Action = require(script.Parent.Action)

return Action("BrushObjectVerticalOffsetSet", function(guid, fixed)
	return {
		guid = guid,
		fixed = fixed
	}
end)