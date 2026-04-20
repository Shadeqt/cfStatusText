local addon = cfStatusText
local K = addon.KEYS
local factory = addon.GUI

EventUtil.ContinueOnAddOnLoaded("cfStatusText", function()
	local panel = CreateFrame("Frame", "cfStatusTextSettingsPanel")
	panel.name = "cfStatusText"
	panel:Hide()

	local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText("cfStatusText")

	local target = factory.CreateCheckbox(panel, title, "Enable target text", K.TARGET, addon.EnableTarget, addon.DisableTarget, -24)
	local nameplates = factory.CreateCheckbox(panel, target, "Enable nameplate text", K.NAMEPLATES, addon.EnableNameplates, addon.DisableNameplates, -8)
	local watchedBar = factory.CreateCheckbox(panel, nameplates, "Enable XP / reputation text", K.WATCHED_BAR, addon.EnableWatchedBar, addon.DisableWatchedBar, -8)

	panel:SetScript("OnShow", function(self)
		factory.MakeSettingsPanelDraggable()
		self.target:SetChecked(addon.db[K.TARGET])
		self.nameplates:SetChecked(addon.db[K.NAMEPLATES])
		self.watchedBar:SetChecked(addon.db[K.WATCHED_BAR])
	end)

	panel.target = target
	panel.nameplates = nameplates
	panel.watchedBar = watchedBar

	local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
	Settings.RegisterAddOnCategory(category)
end)
