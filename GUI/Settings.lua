local addon = cfStatusText
local K = addon.KEYS
local F = addon.GUI

function addon.InitSettings()
	local panel = CreateFrame("Frame", "cfStatusTextSettingsPanel")
	panel.name = "cfStatusText"
	panel:Hide()

	local title = F.Title(panel, "cfStatusText")

	local target = F.Checkbox(panel, title, "Enable target text", K.TARGET, {
		onEnable = addon.EnableTarget, onDisable = addon.DisableTarget,
	})
	local nameplates = F.Checkbox(panel, target, "Enable nameplate text", K.NAMEPLATES, {
		onEnable = addon.EnableNameplates, onDisable = addon.DisableNameplates,
	})
	F.Checkbox(panel, nameplates, "Enable XP / reputation text", K.WATCHED_BAR, {
		onEnable = addon.EnableWatchedBar, onDisable = addon.DisableWatchedBar,
	})

	panel:SetScript("OnShow", F.MakeSettingsPanelDraggable)

	local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
	Settings.RegisterAddOnCategory(category)
end
