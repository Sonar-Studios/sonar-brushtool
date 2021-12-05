local Action = require(script.Parent.Action)

return Action("BrushOrientationSet", function(custom)
	return {
		custom = custom
	}
end)