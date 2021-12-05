local HttpService = game:GetService("HttpService")

local Action = require(script.Parent.Action)

return Action("BrushObjectDelete", function(guid)
	return {
		guid = guid,
	}
end)