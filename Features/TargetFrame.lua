local addon = cfStatusText

local bars = {}
local eventFrame = CreateFrame("Frame")
local setupDone
local hooksInstalled
local enabled

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
	if not bars[bar] then
		bars[bar] = true
	end
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
	if setupDone then return end
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
	setupDone = true
end

local function InstallHooks()
	if hooksInstalled then return end

	hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", function(bar)
		if not enabled then return end
		if bar ~= TargetFrameHealthBar then return end
		if not bar.showPercentage then return end
		if not addon.IsHealthKnown("target") then return end
		bar.showPercentage = false
		TextStatusBar_UpdateTextString(bar)
	end)

	hooksInstalled = true
end

local function UpdateBars()
	for bar in pairs(bars) do
		bar.TextString:Show()
		bar.LeftText:Show()
		bar.RightText:Show()
		UpdateLockShow(bar)
	end
end

local function HideBars()
	for bar in pairs(bars) do
		addon.HideBarText(bar)
	end
end

function addon.EnableTarget()
	if enabled then return end
	enabled = true
	SetupTargetBars()
	InstallHooks()

	eventFrame:RegisterEvent("CVAR_UPDATE")
	eventFrame:SetScript("OnEvent", function(_, _, cvar)
		if cvar ~= "statusText" then return end
		for bar in pairs(bars) do
			UpdateLockShow(bar)
		end
	end)

	UpdateBars()
end

function addon.DisableTarget()
	if not enabled then return end
	enabled = false
	eventFrame:UnregisterAllEvents()
	eventFrame:SetScript("OnEvent", nil)
	HideBars()
end

EventUtil.ContinueOnAddOnLoaded("cfStatusText", function()
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:SetScript("OnEvent", function(self)
		self:UnregisterAllEvents()
		if enabled then
			SetupTargetBars()
			UpdateBars()
		end
	end)
end)
