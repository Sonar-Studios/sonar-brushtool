local Plugin = script.Parent.Parent.Parent

local Libs = Plugin.Libs
local Cryo = require(Libs.Cryo)

local Colors = require(Plugin.Core.Util.Colors)
local createSignal = require(Plugin.Core.Util.createSignal)
local Immutable = require(Plugin.Core.Util.Immutable)
local wrapStrictTable = require(Plugin.Core.Util.wrapStrictTable)

local BrushtoolTheme = {}
BrushtoolTheme.__index = BrushtoolTheme


--[[
	options:
		getTheme : function void -> Theme
		isDarkerTheme : function Theme -> bool
		themeChanged : RbxScriptSignal
]]
function BrushtoolTheme.new(options)
	local self = {
		_externalThemeGetter = options.getTheme or nil,
		_isDarkThemeGetter = options.isDarkerTheme or false,
		_externalThemeChangedSignal = options.themeChanged or nil,

		_externalThemeChangedConnection = nil,

		_values = {},

		_signal = createSignal(),
	}

	self.values = wrapStrictTable(self._values, "theme")

	setmetatable(self, BrushtoolTheme)

	if self._externalThemeChangedSignal then
		self._externalThemeChangedConnection = self._externalThemeChangedSignal:Connect(function()
			self:_recalculateTheme()
		end)
	end
	self:_recalculateTheme()

	return self
end

function BrushtoolTheme:subscribe(...)
	return self._signal:subscribe(...)
end

function BrushtoolTheme:destroy()
	if self._externalThemeChangedConnection then
		self._externalThemeChangedConnection:Disconnect()
	end
end

function BrushtoolTheme:_update(changedValues)
	self._values = Cryo.Dictionary.join(self._values, changedValues)
	self.values = wrapStrictTable(self._values, "theme")
	self._signal:fire(self.values)
end

function BrushtoolTheme:_getExternalTheme()
	local getter = self._externalThemeGetter

	if type(getter) == "function" then
		return getter()
	end

	return getter
end

function BrushtoolTheme:_isDarkerTheme()
	local getter = self._isDarkThemeGetter

	if type(getter) == "function" then
		return getter(self:_getExternalTheme())
	end

	return getter and true or false
end

function BrushtoolTheme:_recalculateTheme()
	local externalTheme = self:_getExternalTheme()
	local isDark = self:_isDarkerTheme()

	-- Shorthands for getting a color
	local c = Enum.StudioStyleGuideColor
	local m = Enum.StudioStyleGuideModifier

	local function color(...)
		return externalTheme:GetColor(...)
	end
	
	-- nice
	local mainTextColor = isDark and Color3.fromRGB(204, 204, 204) or Color3.fromRGB(51, 51, 51)
	local disabledTextColor = isDark and Color3.fromRGB(85, 85, 85) or Color3.fromRGB(120, 120, 120)
	local backgroundColor = isDark and Color3.fromRGB(46, 46, 46) or Color3.fromRGB(255, 255, 255)
	local foregroundColor = isDark and Color3.fromRGB(53, 53, 53) or Color3.fromRGB(242, 242, 242)
	local borderColor = isDark and Color3.fromRGB(34, 34, 34) or Color3.fromRGB(182, 182, 182)
	local highlightColor = isDark and Color3.fromRGB(66, 66, 66) or Color3.fromRGB(228, 238, 254)
	local accentColor = Color3.fromRGB(0, 162, 255)

	local fieldFillColor = isDark and Color3.fromRGB(37, 37, 37) or Color3.fromRGB(255, 255, 255)
	local fieldDisabledColor = isDark and Color3.fromRGB(53, 53, 53) or Color3.fromRGB(231, 231, 231)
	local fieldBorderDefaultColor = isDark and Color3.fromRGB(26, 26, 26) or Color3.fromRGB(200, 200, 200)
	local fieldBorderHoverColor = isDark and Color3.fromRGB(58, 58, 58) or Color3.fromRGB(168, 168, 168)
	local fieldBorderSelectedColor = isDark and Color3.fromRGB(53, 181, 255) or Color3.fromRGB(102, 146, 220)
	local fieldBorderDisabledColor = isDark and Color3.fromRGB(66, 66, 66) or Color3.fromRGB(182, 182, 182)
	local fieldaccentColor = isDark and Color3.fromRGB(53, 181, 255) or Color3.fromRGB(102, 146, 220)

	local scrollbarBackgroundColor = isDark and Color3.fromRGB(41, 41, 41) or Color3.fromRGB(238, 238, 238)

	local buttonDefaultColor = isDark and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(255, 255, 255)
	local buttonHoverColor = highlightColor
	local buttonPressedColor = isDark and Color3.fromRGB(28, 28, 28) or Color3.fromRGB(219, 219, 219)
	local buttonDisabledColor = backgroundColor
	
	local redButtonColor = isDark and Color3.fromRGB(198, 40, 40) or Color3.fromRGB(239, 154, 154)
	local greenButtonColor = isDark and Color3.fromRGB(46, 125, 50) or Color3.fromRGB(165, 214, 167)
	
	local buttonBorderDefaultColor = borderColor
	
	self:_update({
		isDarkerTheme = isDark,

		textField = {
			box = {
				borderColor = {
					Selected = fieldBorderSelectedColor,
					Hover = fieldBorderHoverColor,
					Default = fieldBorderDefaultColor
				},
				backgroundColor = {
					Selected = fieldFillColor,
					Hover = fieldFillColor,
					Default = fieldFillColor
				},
				textColor = mainTextColor,
				placeholderColor = disabledTextColor
			}
		},
		
		checkboxField = {
			box = {
				borderColor = {
					Default = fieldBorderDefaultColor,
					Hover = fieldBorderHoverColor,
				},
				backgroundColor = {
					Default = fieldFillColor,
					Hover = fieldFillColor,
				}
			},
			checkmarkColor = accentColor
		},
		
		labeledField = {
			textColor = {
				Enabled = mainTextColor,
				Disabled = disabledTextColor
			},
			arrowColor = mainTextColor
		},
		
		dropdownField = {
			box = {
				borderColor = {
					Open = fieldBorderSelectedColor,
					Hovered = fieldBorderHoverColor,
					Default = fieldBorderDefaultColor,
					Disabled = fieldBorderDisabledColor
				},
				backgroundColor = {
					Open = fieldFillColor,
					Hovered = fieldFillColor,
					Default = fieldFillColor,
					Disabled = fieldDisabledColor
				},
				textColor = {
					Default = mainTextColor,
					Inactive = disabledTextColor,
					Disabled = disabledTextColor
				},
				arrowColor = mainTextColor,
			},
			dropdown = {
				backgroundColor = backgroundColor,
				borderColor = borderColor,
				highlightColor = highlightColor,
				textColor = {
					Default = mainTextColor,
					Inactive = disabledTextColor,
					Disabled = disabledTextColor
				}
			}
		},
		
		scrollbar = {
			backgroundColor = scrollbarBackgroundColor,
			borderColor = borderColor,
			scrollbarColor = {
				Default  = buttonDefaultColor,
				Hover = buttonHoverColor,
				Pressed = buttonPressedColor
			},
			arrowColor = mainTextColor -- Odds are text will contrast with the scrollbar.
		},
		
		tabber = {
			content = {
				backgroundColor = backgroundColor
			},
			tabBar = {
				backgroundColor = foregroundColor,
				borderColor = borderColor,
			},
			tabButton = {
				backgroundColor = {
					Default = foregroundColor,
					Hover = highlightColor,
					Selected = backgroundColor
				},
				textColor = {
					Default = mainTextColor,
					Selected = mainTextColor
				},
				underlineColor = accentColor
			}
		},
		
		button = {
			box = {
				backgroundColor = {
					Default = {
						Default = buttonDefaultColor,
						PressedInside = buttonPressedColor,
						PressedOutside = buttonHoverColor,
						Hovered = buttonHoverColor,
						Selected = buttonPressedColor,
						Disabled = buttonDisabledColor,
						SelectedHovered = buttonPressedColor:lerp(buttonDefaultColor, 0.4),
						SelectedPressedInside = buttonPressedColor:lerp(buttonDefaultColor, 0.1),
						SelectedPressedOutside = buttonPressedColor:lerp(buttonDefaultColor, 0.4)
					},
					Delete = {
						Default = redButtonColor,
						PressedInside = isDark and Color3.fromRGB(183, 28, 28) or Color3.fromRGB(229, 115, 115),
						PressedOutside = isDark and Color3.fromRGB(229, 57, 57) or Color3.fromRGB(255, 235, 238),
						Hovered = isDark and Color3.fromRGB(229, 57, 57) or Color3.fromRGB(255, 235, 238),
					},
					Add = {
						Default = greenButtonColor,
						PressedInside = isDark and Color3.fromRGB(27, 94, 32) or Color3.fromRGB(129, 199, 132),
						PressedOutside = isDark and Color3.fromRGB(67, 160, 71) or Color3.fromRGB(232, 245, 233),
						Hovered = isDark and Color3.fromRGB(67, 160, 71) or Color3.fromRGB(232, 245, 233), 
					}
				},
				borderColor = {
					Default = {
						Default = buttonBorderDefaultColor,
						PressedInside = buttonBorderDefaultColor,
						PressedOutside = buttonBorderDefaultColor,
						Hovered = buttonBorderDefaultColor,
						Selected = buttonBorderDefaultColor,
						Disabled = buttonBorderDefaultColor,
						SelectedHovered = buttonBorderDefaultColor,
						SelectedPressedInside = buttonBorderDefaultColor,
						SelectedPressedOutside = buttonBorderDefaultColor
					},
					Delete = {
						Default = buttonBorderDefaultColor,
						PressedInside = buttonBorderDefaultColor,
						PressedOutside = buttonBorderDefaultColor,
						Hovered = buttonBorderDefaultColor,
						Selected = buttonBorderDefaultColor,
						Disabled = buttonBorderDefaultColor,
						SelectedHovered = buttonBorderDefaultColor,
						SelectedPressedInside = buttonBorderDefaultColor,
						SelectedPressedOutside = buttonBorderDefaultColor
					},
					Add = {
						Default = buttonBorderDefaultColor,
						PressedInside = buttonBorderDefaultColor,
						PressedOutside = buttonBorderDefaultColor,
						Hovered = buttonBorderDefaultColor,
						Selected = buttonBorderDefaultColor,
						Disabled = buttonBorderDefaultColor,
						SelectedHovered = buttonBorderDefaultColor,
						SelectedPressedInside = buttonBorderDefaultColor,
						SelectedPressedOutside = buttonBorderDefaultColor
					}
				},
			},
			textColor = {
				Default = mainTextColor,
				Delete = mainTextColor,
				Add = mainTextColor,
				Disabled = color(c.ButtonText, m.Disabled)
			}
		},
		
		collapsibleTitledSection = {
			textColor = mainTextColor,
			hoverColor = highlightColor,
			defaultColor = foregroundColor,
			borderColor = borderColor,
			contentColor = foregroundColor:lerp(backgroundColor, 0.8)
		},
		
		separator = {
			color = borderColor
		},
		
		numericalSliderField = {
			barBackgroundColor = borderColor,
			barFillColor = accentColor
		},
		
		mainTextColor = mainTextColor,
		warningTextColor = isDark and Color3.new(1, 0.4, 0.4) or Color3.new(1, 0, 0),
		positiveTextColor = isDark and Color3.new(0.4, 1, 0.4) or Color3.new(0, 0.6, 0),
		mainBackgroundColor = color(c.MainBackground),
		borderColor = color(c.Border),
		
		app = {
			backgroundColor = backgroundColor,
			borderColor = borderColor,
			textColor = mainTextColor,
			noColor = Color3.new(1, 0.4, 0.4),
		},
		
		objectGrid = {
			backgroundColor = backgroundColor,
			borderColor = borderColor,
			noResultsColor = mainTextColor
		},
		
		objectGridEntry = {
			textColorEnabled = mainTextColor,
			textColorDisabled = disabledTextColor,
			borderColor = {
				Default = buttonBorderDefaultColor,
				PressedInside = buttonBorderDefaultColor,
				PressedOutside = buttonBorderDefaultColor,
				Hovered = buttonBorderDefaultColor,
				Selected = buttonBorderDefaultColor,
				SelectedHovered = buttonBorderDefaultColor,
				SelectedPressedInside = buttonBorderDefaultColor,
				SelectedPressedOutside = buttonBorderDefaultColor
			},
			backgroundColor = {
				Default = buttonDefaultColor,
				PressedInside = buttonPressedColor,
				PressedOutside = buttonHoverColor,
				Hovered = buttonHoverColor,
				Selected = accentColor,
				SelectedHovered = accentColor:lerp(buttonDefaultColor, 0.3),
				SelectedPressedInside = accentColor:lerp(buttonDefaultColor, 0.6),
				SelectedPressedOutside = accentColor:lerp(buttonDefaultColor, 0.3)
			}
		},
		
		objectGridAddEntry = {
			textColor = mainTextColor,
			backgroundColor = {
				Hovered = backgroundColor,
				Default = backgroundColor,
			}
		},
		
		noteEntry = {
			backgroundColor = backgroundColor,
			textColor = mainTextColor,
		},
		
		filterBox = {
			clearButtonColor = {
				Default = mainTextColor,
				Hovered = accentColor
			}
		},
				
		shaderColor = isDark and Color3.new(0, 0, 0) or Color3.new(1, 1, 1),
		saveBorderColor = isDark and Color3.new(0.4, 1, 0.4),
		saveButtonColor = isDark and Color3.new(0.4, 1, 0.4)
	})
end

return BrushtoolTheme
