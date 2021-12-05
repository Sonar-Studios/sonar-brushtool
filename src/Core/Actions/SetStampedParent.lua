local Action = require(script.Parent.Action)

return Action("StampedParentSet", function(stampedParent)
	return {
		stampedParent = stampedParent
	}
end)