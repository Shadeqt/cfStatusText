local function Percent(current, max)
    return math.floor((current / max) * 100 + 0.5)
end

-- BOTH adds value+percent; other modes match Blizzard's native render.
local function OverrideXP()
    if GetCVar("statusTextDisplay") ~= "BOTH" then return end
    local current, max = UnitXP("player"), UnitXPMax("player")
    if max == 0 then return end
    MainMenuExpBar.TextString:SetText(string.format("%d / %d (%d%%)", current, max, Percent(current, max)))
end

-- Rep's native text is hardcoded "name value/max" for every mode. Override BOTH and PERCENT;
-- NUMERIC keeps the native; NONE is hidden by ApplyVisibility.
local function OverrideRep()
    if not ReputationWatchBar:IsShown() then return end
    local display = GetCVar("statusTextDisplay")
    if display ~= "BOTH" and display ~= "PERCENT" then return end
    local name, _, minBar, maxBar, value = GetWatchedFactionInfo()
    if not name then return end
    local current, max = value - minBar, maxBar - minBar
    if max == 0 then return end
    local pct = Percent(current, max)
    if display == "BOTH" then
        ReputationWatchBar.OverlayFrame.Text:SetText(string.format("%s %d / %d (%d%%)", name, current, max, pct))
    else
        ReputationWatchBar.OverlayFrame.Text:SetText(string.format("%s %d%%", name, pct))
    end
end

-- xpBarText gates Blizzard's XP text; ShowWatchBarText locks the rep text on (default is
-- hover-only). HideWatchBarText(_, true) clears the lock.
local function ApplyVisibility()
    local on = GetCVar("statusTextDisplay") ~= "NONE"
    SetCVar("xpBarText", on and "1" or "0")
    if on then ShowWatchBarText(ReputationWatchBar)
    else HideWatchBarText(ReputationWatchBar, true) end
end

ApplyVisibility()

-- Blizzard doesn't re-render rep on statusTextDisplay changes — trigger it ourselves;
-- the hook below picks up the rest.
local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(_, _, arg1)
    if arg1 == "statusTextDisplay" then MainMenuBar_UpdateExperienceBars() end
end)
frame:RegisterEvent("CVAR_UPDATE")

hooksecurefunc("TextStatusBar_UpdateTextString", function(bar)
    if bar == MainMenuExpBar then OverrideXP() end
end)
hooksecurefunc("MainMenuBar_UpdateExperienceBars", function()
    ApplyVisibility()
    OverrideRep()
end)
