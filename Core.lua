local addon = cfStatusText

function addon.CreateBarText(bar, parent, offsets)
	if bar.TextString and bar.LeftText and bar.RightText then
		return bar.TextString, bar.LeftText, bar.RightText
	end

	local function SetTextPoint(text, point, defaultPoint)
		text:SetPoint(defaultPoint, parent, defaultPoint, point[1] or 0, point[2] or 0)
	end

	bar.TextString = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	SetTextPoint(bar.TextString, offsets.center, "CENTER")
	bar.LeftText = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	SetTextPoint(bar.LeftText, offsets.left, "LEFT")
	bar.RightText = parent:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
	SetTextPoint(bar.RightText, offsets.right, "RIGHT")
	return bar.TextString, bar.LeftText, bar.RightText
end

function addon.HideBarText(bar)
	if not bar then return end
	if bar.TextString then bar.TextString:Hide() end
	if bar.LeftText then bar.LeftText:Hide() end
	if bar.RightText then bar.RightText:Hide() end
end

function addon.IsHealthKnown(unit)
	local guid = UnitGUID(unit)
	local guidType = guid and guid:match("^(.-)%-")
	if guidType ~= "Player" and guidType ~= "Pet" then return true end
	if UnitIsUnit(unit, "player") or UnitIsUnit(unit, "pet") then return true end
	if UnitPlayerOrPetInParty(unit) or UnitPlayerOrPetInRaid(unit) then return true end
	return false
end
