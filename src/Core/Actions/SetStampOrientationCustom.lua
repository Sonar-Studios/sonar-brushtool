local Action = require(script.Parent.Action)

return Action("StampOrientationSet", function(custom)
	return {
		custom = custom
	}
end)