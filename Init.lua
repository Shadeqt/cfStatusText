local addonName, addon = ...

EventUtil.ContinueOnAddOnLoaded(addonName, function()
    addon.SetupNameplate()
    addon.SetupTargetFrame()
    addon.SetupWatchedBar()
end)
