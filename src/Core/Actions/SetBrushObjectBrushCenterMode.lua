local Action = require(script.Parent.Action)

return Action("BrushObjectBrushCenterModeSet", function(guid, brushCenterMode)
	return {
		guid = guid,
		brushCenterMode = brushCenterMode
	}
end)