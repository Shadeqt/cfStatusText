local addon = cfStatusText

local repText
local eventFrame = CreateFrame("Frame")
local enabled

local function GetRepTextString()
	if repText then return repText end
	if not ReputationWatchBar then return end
	for _, child in ipairs({ReputationWatchBar:GetChildren()}) do
		if child:GetObjectType() == "Frame" then
			for _, region in ipairs({child:GetRegions()}) do
				if region:GetObjectType() == "FontString" then
					repText = region
					return repText
				end
			end
		end
	end
end

local function GetRepBarText()
	local name, _, minBar, maxBar, value = GetWatchedFactionInfo()
	if not name then return nil end

	local maxValue = maxBar - minBar
	local currentValue = value - minBar
	local percent = maxValue > 0 and floor((currentValue / maxValue) * 100 + 0.5) or 0
	local display = GetCVar("statusTextDisplay")

	if display == "NONE" then
		return ""
	elseif display == "PERCENT" then
		return name .. " " .. percent .. "%"
	elseif display == "BOTH" then
		return string.format("%s (%d%%) %d / %d", name, percent, currentValue, maxValue)
	else
		return string.format("%s %d / %d", name, currentValue, maxValue)
	end
end

local function SyncWatchedBars()
	local shouldShow = GetCVar("statusTextDisplay") ~= "NONE"
	if MainMenuExpBar then
		SetCVar("xpBarText", shouldShow and "1" or "0")
		TextStatusBar_UpdateTextString(MainMenuExpBar)
	end

	local textObj = GetRepTextString()
	if not textObj then return end

	local text = GetRepBarText()
	if text == nil then
		textObj:SetText(nil)
		return
	end

	textObj:SetText(text)
	textObj:SetShown(text ~= "")
end

local function HideWatchedBars()
	if MainMenuExpBar then
		SetCVar("xpBarText", "0")
		TextStatusBar_UpdateTextString(MainMenuExpBar)
	end

	local textObj = GetRepTextString()
	if textObj then
		textObj:Hide()
	end
end

function addon.EnableWatchedBar()
	if enabled then return end
	enabled = true
	eventFrame:RegisterEvent("CVAR_UPDATE")
	eventFrame:RegisterEvent("UPDATE_FACTION")
	eventFrame:SetScript("OnEvent", function(_, event, cvar)
		if event == "UPDATE_FACTION" or cvar == "xpBarText" or cvar == "statusTextDisplay" then
			SyncWatchedBars()
			return
		end
		if cvar == "statusText" then
			SyncWatchedBars()
		end
	end)

	SyncWatchedBars()
end

function addon.DisableWatchedBar()
	if not enabled then return end
	enabled = false
	eventFrame:UnregisterAllEvents()
	eventFrame:SetScript("OnEvent", nil)
	HideWatchedBars()
end

EventUtil.ContinueOnAddOnLoaded("cfStatusText", function()
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:SetScript("OnEvent", function(self)
		self:UnregisterAllEvents()
		if enabled then
			SyncWatchedBars()
		end
	end)
end)
