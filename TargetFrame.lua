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

local function CreateText(parent, point, offset)
    local text = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
    text:SetPoint(point, parent, point, offset[1], offset[2])
    return text
end

-- Classic's target-bar template defines none of TextString/LeftText/RightText. Create
-- all three; Blizzard's UpdateTextString uses bar.TextString for percent/value and splits
-- to bar.LeftText + bar.RightText in BOTH mode.
local function MirrorBarText(playerBar, ourBar, parent)
    local offsets = MirrorOffsets(playerBar)
    ourBar.TextString = CreateText(parent, "CENTER", offsets.center)
    ourBar.LeftText   = CreateText(parent, "LEFT",   offsets.left)
    ourBar.RightText  = CreateText(parent, "RIGHT",  offsets.right)
    MirrorOnMove(playerBar.TextString, ourBar.TextString)
    MirrorOnMove(playerBar.LeftText,   ourBar.RightText)
    MirrorOnMove(playerBar.RightText,  ourBar.LeftText)
end

MirrorBarText(PlayerFrameHealthBar, TargetFrameHealthBar, TargetFrameTextureFrame)
MirrorBarText(PlayerFrameManaBar,   TargetFrameManaBar,   TargetFrameTextureFrame)

-- Force text on regardless of the user's "Always Show Status Text" (statusText) CVar.
TargetFrameHealthBar.lockShow = 1
TargetFrameManaBar.lockShow = 1

-- (1) Blizzard's target update re-asserts showPercentage=true; flip it so BOTH splits
-- to LeftText/RightText. (2) lockShow forces text past NONE — hide explicitly.
hooksecurefunc("TextStatusBar_UpdateTextString", function(bar)
    if bar ~= TargetFrameHealthBar and bar ~= TargetFrameManaBar then return end
    if GetCVar("statusTextDisplay") == "NONE" then
        bar.TextString:Hide(); bar.LeftText:Hide(); bar.RightText:Hide()
    elseif bar.showPercentage then
        bar.showPercentage = false
        TextStatusBar_UpdateTextString(bar)
    end
end)

TextStatusBar_UpdateTextString(TargetFrameHealthBar)
TextStatusBar_UpdateTextString(TargetFrameManaBar)
