local _, addon = ...

local repText

local function GetRepText()
    if repText then return repText end
    if not ReputationWatchBar then return end
    for _, child in ipairs({ ReputationWatchBar:GetChildren() }) do
        if child:GetObjectType() == "Frame" then
            for _, region in ipairs({ child:GetRegions() }) do
                if region:GetObjectType() == "FontString" then
                    repText = region
                    return repText
                end
            end
        end
    end
end

local function FormatRepText()
    local name, _, minBar, maxBar, value = GetWatchedFactionInfo()
    if not name then return "" end
    local current, max = value - minBar, maxBar - minBar
    local percent = max > 0 and math.floor((current / max) * 100 + 0.5) or 0
    local display = GetCVar("statusTextDisplay")
    if display == "NONE" then return ""
    elseif display == "PERCENT" then return name .. " " .. percent .. "%"
    elseif display == "BOTH" then return string.format("%s (%d%%) %d / %d", name, percent, current, max)
    else return string.format("%s %d / %d", name, current, max) end
end

local function Update()
    -- XP bar: a Blizzard CVar (no Classic UI toggle for it); Blizzard renders the text.
    SetCVar("xpBarText", GetCVar("statusTextDisplay") ~= "NONE" and "1" or "0")
    TextStatusBar_UpdateTextString(MainMenuExpBar)

    -- Rep bar: write our own text into its FontString.
    local text = GetRepText()
    if not text then return end
    local value = FormatRepText()
    text:SetText(value)
    text:SetShown(value ~= "")
end

function addon.SetupWatchedBar()
    local frame = CreateFrame("Frame")
    frame:SetScript("OnEvent", function(_, event, arg1)
        if event == "CVAR_UPDATE" and arg1 ~= "statusText" and arg1 ~= "statusTextDisplay" then return end
        Update()
    end)
    frame:RegisterEvent("UPDATE_FACTION")
    frame:RegisterEvent("CVAR_UPDATE")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    Update()
end
