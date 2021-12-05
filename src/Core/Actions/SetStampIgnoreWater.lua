local Action = require(script.Parent.Action)

return Action("StampIgnoreWaterSet", function(ignoreWater)
	return {
		ignoreWater = ignoreWater
	}
end)