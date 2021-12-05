local Plugin = script.Parent.Parent.Parent

local createSignal = require(Plugin.Core.Util.createSignal)

local ModalStatus = {}
ModalStatus.__index = ModalStatus

function ModalStatus.new()
	return setmetatable({
		_signal = createSignal(),
		_isDropdownShown = false,
		_pressedButton = nil
	}, ModalStatus)
end

function ModalStatus:subscribe(...)
	return self._signal:subscribe(...)
end

function ModalStatus:isShowingModal()
	return self._isDropdownShown
end

function ModalStatus:onDropdownToggled(shown)
	if shown ~= self._isDropdownShown then
		self._isDropdownShown = shown
	
		self._signal:fire()
	end
end

function ModalStatus:onButtonPressed(button)
	assert(button)
	if button ~= self._pressedButton then
		self._pressedButton = button
		
		self._signal:fire()
	end
end

function ModalStatus:onButtonReleased()
	if self._pressedButton ~= nil then
		self._pressedButton = nil
		
		self._signal:fire()
	end
end

function ModalStatus:isAnyButtonPressed()
	return self._pressedButton ~= nil
end

function ModalStatus:isButtonPressed(button)
	assert(button)
	return self._pressedButton == button
end

return ModalStatus
