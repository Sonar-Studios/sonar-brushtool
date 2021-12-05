local Action = require(script.Parent.Action)

return Action("EraseIgnoreWaterSet", function(ignoreWater)
	return {
		ignoreWater = ignoreWater
	}
end)