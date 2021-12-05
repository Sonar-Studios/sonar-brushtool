local Action = require(script.Parent.Action)

return Action("BrushDeletingSet", function(guid)
	return {
		guid = guid
	}
end)