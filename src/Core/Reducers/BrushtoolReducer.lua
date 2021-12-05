local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Rodux = require(Libs.Rodux)

local Brush = require(script.Parent.Brush)
local BrushObjects = require(script.Parent.BrushObjects)
local Stamp = require(script.Parent.Stamp)
local StampObjects = require(script.Parent.StampObjects)
local Erase = require(script.Parent.Erase)

local BrushtoolReducer = Rodux.combineReducers{
	brushObjects = BrushObjects,
	brush = Brush,
	erase = Erase,
	stamp = Stamp,
	stampObjects = StampObjects,
	stateCopied = function(state, action)
		if action.type == "@@INIT" then
			return false
		elseif action.type == "_CopyFromState" then
			return true
		else
			return state
		end
	end
}

return BrushtoolReducer

--	local savedState = {}
--	local objectFolder = pluginFolder:FindFirstChild("ObjectStorage")
--	if not objectFolder then
--		objectFolder = Instance.new("Folder")
--		objectFolder.Name = "ObjectStorage"
--		objectFolder.Parent = pluginFolder
--	end
--	
--	local brushFolder = pluginFolder:FindFirstChild("BrushStorage")
--	if not brushFolder then
--		brushFolder = Instance.new("Folder")
--		brushFolder.Name = "BrushStorage"
--		brushFolder.Parent = pluginFolder	
--	end
--	
--	local brushState = Cryo.Dictionary.join(InitialBrushState)
--	local objectsState = Cryo.Dictionary.join(InitialObjectsState)
--	savedState.brush = brushState
--	savedState.objects = objectsState