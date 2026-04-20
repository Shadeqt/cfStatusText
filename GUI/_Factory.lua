local addon = cfStatusText

addon.GUI = addon.GUI or {}

function addon.GUI.MakeSettingsPanelDraggable()
	if not SettingsPanel or SettingsPanel.cfDragEnabled then return end
	SettingsPanel.cfDragEnabled = true
	SettingsPanel:SetMovable(true)
	SettingsPanel:EnableMouse(true)
	SettingsPanel:RegisterForDrag("LeftButton")
	SettingsPanel:HookScript("OnDragStart", function(self)
		self:StartMoving()
	end)
	SettingsPanel:HookScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)
end

function addon.GUI.CreateCheckbox(panel, anchor, label, key, onEnable, onDisable, offsetY)
	local checkbox = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
	checkbox:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, offsetY)
	checkbox.Text:SetText(label)
	checkbox:SetScript("OnShow", function(self)
		self:SetChecked(addon.db[key])
	end)
	checkbox:SetScript("OnClick", function(self)
		local enabled = self:GetChecked() and true or false
		addon.db[key] = enabled
		if enabled then
			if onEnable then onEnable() end
		else
			if onDisable then onDisable() end
		end
	end)
	return checkbox
end
