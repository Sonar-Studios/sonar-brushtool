local Action = require(script.Parent.Action)

return Action("BrushIgnoreWaterSet", function(ignoreWater)
	return {
		ignoreWater = ignoreWater
	}
end)