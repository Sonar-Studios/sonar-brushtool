local Action = require(script.Parent.Action)

return Action("BrushedParentSet", function(brushedParent)
	return {
		brushedParent = brushedParent
	}
end)