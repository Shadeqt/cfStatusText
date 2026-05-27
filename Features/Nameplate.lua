local _, addon = ...

local function GetHealthBar(unit)
    local plate = C_NamePlate.GetNamePlateForUnit(unit)
    if not plate or not plate.UnitFrame then return end
    local frame = plate.UnitFrame
    return frame.healthBar or (frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar)
end

local function UpdateNameplate(unit)
    local bar = GetHealthBar(unit)
    if not bar then return end
    local center, left, right = addon.CreateBarText(bar, bar, { center = {0, 0}, left = {2, 0}, right = {-2, 0} })
    local leftText, centerText, rightText =
        addon.FormatStatusText(UnitHealth(unit), UnitHealthMax(unit), addon.IsHealthKnown(unit))
    left:SetText(leftText);     left:SetShown(leftText ~= "")
    center:SetText(centerText); center:SetShown(centerText ~= "")
    right:SetText(rightText);   right:SetShown(rightText ~= "")
end

local function UpdateAll()
    for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
        local unit = plate.namePlateUnitToken or (plate.UnitFrame and plate.UnitFrame.unit)
        if unit then UpdateNameplate(unit) end
    end
end

function addon.SetupNameplate()
    local frame = CreateFrame("Frame")
    frame:SetScript("OnEvent", function(_, event, arg1)
        if event == "CVAR_UPDATE" then
            if arg1 == "statusText" or arg1 == "statusTextDisplay" then UpdateAll() end
        else
            UpdateNameplate(arg1)
        end
    end)
    frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    frame:RegisterEvent("UNIT_HEALTH")
    frame:RegisterEvent("UNIT_MAXHEALTH")
    frame:RegisterEvent("CVAR_UPDATE")
end
