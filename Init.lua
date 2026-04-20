cfStatusText = cfStatusText or {}
local addon = cfStatusText

addon.KEYS = {
	TARGET = "target",
	NAMEPLATES = "nameplates",
	WATCHED_BAR = "watchedBar",
}

local defaults = {
	[addon.KEYS.TARGET] = true,
	[addon.KEYS.NAMEPLATES] = true,
	[addon.KEYS.WATCHED_BAR] = true,
}

cfStatusTextDB = cfStatusTextDB or {}
for key, value in pairs(defaults) do
	if cfStatusTextDB[key] == nil then
		cfStatusTextDB[key] = value
	end
end
for key in pairs(cfStatusTextDB) do
	if defaults[key] == nil then
		cfStatusTextDB[key] = nil
	end
end
addon.db = cfStatusTextDB

EventUtil.ContinueOnAddOnLoaded("cfStatusText", function()
	if addon.db[addon.KEYS.TARGET] then
		addon.EnableTarget()
	end
	if addon.db[addon.KEYS.NAMEPLATES] then
		addon.EnableNameplates()
	end
	if addon.db[addon.KEYS.WATCHED_BAR] then
		addon.EnableWatchedBar()
	end
end)
