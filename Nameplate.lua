local function GetHealthBar(unit)
    local plate = C_NamePlate.GetNamePlateForUnit(unit)
    if not plate or not plate.UnitFrame then return end
    local frame = plate.UnitFrame
    return frame.healthBar or (frame.HealthBarsContainer and frame.HealthBarsContainer.healthBar)
end

local function GetText(bar)
    if bar.cfStatusText then return bar.cfStatusText end
    local text = bar:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
    text:SetPoint("CENTER", bar, "CENTER", 0, 0)
    bar.cfStatusText = text
    return text
end

-- One mode: show current HP in the center when statusTextDisplay is not NONE.
local function UpdateNameplate(unit)
    local bar = GetHealthBar(unit)
    if not bar then return end
    local text = GetText(bar)
    if GetCVar("statusTextDisplay") == "NONE" then
        text:Hide()
    else
        text:SetText(UnitHealth(unit))
        text:Show()
    end
end

local function UpdateAll()
    for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
        local unit = plate.namePlateUnitToken or (plate.UnitFrame and plate.UnitFrame.unit)
        if unit then UpdateNameplate(unit) end
    end
end

local frame = CreateFrame("Frame")
frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "CVAR_UPDATE" then
        if arg1 == "statusTextDisplay" then UpdateAll() end
    else
        UpdateNameplate(arg1)
    end
end)
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("CVAR_UPDATE")
