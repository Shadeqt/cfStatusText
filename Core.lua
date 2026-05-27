local _, addon = ...

-- True when we know the unit's real values (self/pet/party/raid/NPCs); false for other
-- players, whose health/power we only know as a percentage.
function addon.IsHealthKnown(unit)
    local guid = UnitGUID(unit)
    local guidType = guid and guid:match("^(.-)%-")
    if guidType ~= "Player" and guidType ~= "Pet" then return true end
    if UnitIsUnit(unit, "player") or UnitIsUnit(unit, "pet") then return true end
    if UnitPlayerOrPetInParty(unit) or UnitPlayerOrPetInRaid(unit) then return true end
    return false
end

local function CreateText(parent, point, offset)
    local text = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
    text:SetPoint(point, parent, point, offset[1], offset[2])
    return text
end

-- Create the three status-text regions on a bar (idempotent). offsets = {center=, left=, right=}.
function addon.CreateBarText(bar, parent, offsets)
    if bar.TextString and bar.LeftText and bar.RightText then
        return bar.TextString, bar.LeftText, bar.RightText
    end
    bar.TextString = CreateText(parent, "CENTER", offsets.center)
    bar.LeftText   = CreateText(parent, "LEFT",   offsets.left)
    bar.RightText  = CreateText(parent, "RIGHT",  offsets.right)
    return bar.TextString, bar.LeftText, bar.RightText
end

-- Format a value/max into (left, center, right) per the statusText display CVars.
-- Percent-only when the value isn't known (other players).
function addon.FormatStatusText(current, max, isKnown)
    if not GetCVarBool("statusText") or max == 0 then return "", "", "" end
    local display = GetCVar("statusTextDisplay")
    if display == "NONE" then return "", "", "" end

    local percent = math.floor((current / max) * 100 + 0.5)
    if not isKnown or display == "PERCENT" then
        return "", percent .. "%", ""
    elseif display == "BOTH" then
        return percent .. "%", "", tostring(current)
    end
    return "", string.format("%d / %d", current, max), ""
end
