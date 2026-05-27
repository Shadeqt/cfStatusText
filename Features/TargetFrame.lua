local _, addon = ...

local healthBar, manaBar

-- Target frame mirrors the player frame: negate x, swap left<->right.
local function MirrorOffsets(playerBar)
    local _, _, _, cx, cy = playerBar.TextString:GetPoint(1)
    local _, _, _, lx, ly = playerBar.LeftText:GetPoint(1)
    local _, _, _, rx, ry = playerBar.RightText:GetPoint(1)
    return { center = {-cx, cy}, left = {-rx, ry}, right = {-lx, ly} }
end

-- Re-mirror target text when the player text moves (e.g. cfFrames BiggerHealthbar).
local function MirrorOnMove(playerText, targetText)
    hooksecurefunc(playerText, "SetPoint", function(self)
        local _, _, _, px, py = self:GetPoint(1)
        local point, rel, relPoint = targetText:GetPoint(1)
        targetText:SetPoint(point, rel, relPoint, -px, py)
    end)
end

local function UpdateBar(bar, current, max, isKnown)
    local left, center, right = addon.FormatStatusText(current, max, isKnown)
    bar.LeftText:SetText(left);     bar.LeftText:SetShown(left ~= "")
    bar.TextString:SetText(center); bar.TextString:SetShown(center ~= "")
    bar.RightText:SetText(right);   bar.RightText:SetShown(right ~= "")
end

local function Update()
    if not UnitExists("target") then return end
    local known = addon.IsHealthKnown("target")
    UpdateBar(healthBar, UnitHealth("target"), UnitHealthMax("target"), known)
    UpdateBar(manaBar, UnitPower("target"), UnitPowerMax("target"), known)
end

function addon.SetupTargetFrame()
    healthBar, manaBar = TargetFrameHealthBar, TargetFrameManaBar
    local parent = TargetFrameTextureFrame
    addon.CreateBarText(healthBar, parent, MirrorOffsets(PlayerFrameHealthBar))
    addon.CreateBarText(manaBar, parent, MirrorOffsets(PlayerFrameManaBar))

    MirrorOnMove(PlayerFrameHealthBar.TextString, healthBar.TextString)
    MirrorOnMove(PlayerFrameHealthBar.LeftText,   healthBar.RightText)
    MirrorOnMove(PlayerFrameHealthBar.RightText,  healthBar.LeftText)
    MirrorOnMove(PlayerFrameManaBar.TextString,   manaBar.TextString)
    MirrorOnMove(PlayerFrameManaBar.LeftText,     manaBar.RightText)
    MirrorOnMove(PlayerFrameManaBar.RightText,    manaBar.LeftText)

    local frame = CreateFrame("Frame")
    frame:SetScript("OnEvent", function(_, event, arg1)
        if event == "CVAR_UPDATE" and arg1 ~= "statusText" and arg1 ~= "statusTextDisplay" then return end
        Update()
    end)
    frame:RegisterUnitEvent("UNIT_HEALTH", "target")
    frame:RegisterUnitEvent("UNIT_MAXHEALTH", "target")
    frame:RegisterUnitEvent("UNIT_POWER_UPDATE", "target")
    frame:RegisterUnitEvent("UNIT_MAXPOWER", "target")
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:RegisterEvent("CVAR_UPDATE")
    Update()
end
