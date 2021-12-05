local Action = require(script.Parent.Action)

return Action("StampFilterSet", function(filter)
	return {
		filter = filter
	}
end)