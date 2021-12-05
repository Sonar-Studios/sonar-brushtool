local Action = require(script.Parent.Action)

return Action("BrushSelectedSet", function(guid)
	return {
		guid = guid
	}
end)