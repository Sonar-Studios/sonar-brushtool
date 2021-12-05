local Action = require(script.Parent.Action)

return Action("StampObjectStampCenterModeSet", function(guid, stampCenterMode)
	return {
		guid = guid,
		stampCenterMode = stampCenterMode
	}
end)