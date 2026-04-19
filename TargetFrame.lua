local addon = cfStatusText

local bars = {}

local function UpdateLockShow(bar)
	bar.lockShow = GetCVarBool("statusText") and 1 or 0
	TextStatusBar_UpdateTextString(bar)
end

local function MirrorOffsets(playerBar)
	local _, _, _, cx, cy = playerBar.TextString:GetPoint(1)
	local _, _, _, lx, ly = playerBar.LeftText:GetPoint(1)
	local _, _, _, rx, ry = playerBar.RightText:GetPoint(1)
	return {
		center = {-cx, cy},
		left = {-rx, ry},
		right = {-lx, ly},
	}
end

local function CreateBarText(bar, parent, offsets)
	addon.CreateBarText(bar, parent, offsets)
	table.insert(bars, bar)
	UpdateLockShow(bar)
end

local function MirrorOnMove(playerText, targetText)
	hooksecurefunc(playerText, "SetPoint", function(self)
		local _, _, _, px, py = self:GetPoint(1)
		local _, rel, relPt = targetText:GetPoint(1)
		targetText:SetPoint(targetText:GetPoint(1), rel, relPt, -px, py)
	end)
end

local function SetupTargetBars()
	if not TargetFrameHealthBar or not TargetFrameManaBar then return end

	local parent = TargetFrameTextureFrame
	CreateBarText(TargetFrameHealthBar, parent, MirrorOffsets(PlayerFrameHealthBar))
	CreateBarText(TargetFrameManaBar, parent, MirrorOffsets(PlayerFrameManaBar))

	MirrorOnMove(PlayerFrameHealthBar.TextString, TargetFrameHealthBar.TextString)
	MirrorOnMove(PlayerFrameHealthBar.LeftText, TargetFrameHealthBar.RightText)
	MirrorOnMove(PlayerFrameHealthBar.RightText, TargetFrameHealthBar.LeftText)
	MirrorOnMove(PlayerFrameManaBar.TextString, TargetFrameManaBar.TextString)
	MirrorOnMove(PlayerFrameManaBar.LeftText, TargetFrameManaBar.RightText)
	MirrorOnMove(PlayerFrameManaBar.RightText, TargetFrameManaBar.LeftText)
end

local function HookHealthKnown()
	hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", function(bar)
		if bar ~= TargetFrameHealthBar then return end
		if not bar.showPercentage then return end
		if not addon.IsHealthKnown("target") then return end
		bar.showPercentage = false
		TextStatusBar_UpdateTextString(bar)
	end)
end

local function HookTargetEvents()
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("CVAR_UPDATE")
	frame:SetScript("OnEvent", function(_, _, cvar)
		if cvar ~= "statusText" then return end
		for _, bar in ipairs(bars) do
			UpdateLockShow(bar)
		end
	end)
end

EventUtil.ContinueOnAddOnLoaded("cfStatusText", function()
	HookHealthKnown()
	HookTargetEvents()

	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:SetScript("OnEvent", function(self)
		self:UnregisterAllEvents()
		SetupTargetBars()
	end)
end)
