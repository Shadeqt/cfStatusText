local addon = cfStatusText
local eventFrame = CreateFrame("Frame")
local enabled

local function GetHealthBar(unit)
	local plate = C_NamePlate.GetNamePlateForUnit(unit)
	if not plate or not plate.UnitFrame then return end
	return plate.UnitFrame.healthBar or plate.UnitFrame.HealthBarsContainer and plate.UnitFrame.HealthBarsContainer.healthBar
end

local function GetBarText(bar)
	return addon.CreateBarText(bar, bar, {
		center = {0, 0},
		left = {2, 0},
		right = {-2, 0},
	})
end

local function FormatHealthText(unit)
	if not GetCVarBool("statusText") then return "", "", "" end

	local display = GetCVar("statusTextDisplay")
	if display == "NONE" then return "", "", "" end

	local maxHealth = UnitHealthMax(unit)
	if maxHealth == 0 then return "", "", "" end

	local health = UnitHealth(unit)
	local percent = floor((health / maxHealth) * 100 + 0.5)

	if not addon.IsHealthKnown(unit) then
		return "", percent .. "%", ""
	end

	if display == "PERCENT" then
		return "", percent .. "%", ""
	elseif display == "BOTH" then
		return percent .. "%", "", tostring(health)
	end

	return "", string.format("%d / %d", health, maxHealth), ""
end

local function UpdateNameplateText(unit)
	local bar = GetHealthBar(unit)
	if not bar then return end

	local center, left, right = GetBarText(bar)
	local leftValue, centerValue, rightValue = FormatHealthText(unit)

	left:SetText(leftValue)
	left:SetShown(leftValue ~= "")
	center:SetText(centerValue)
	center:SetShown(centerValue ~= "")
	right:SetText(rightValue)
	right:SetShown(rightValue ~= "")
end

local function UpdateExistingNameplates()
	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		local unit = plate.namePlateUnitToken or plate.UnitFrame and plate.UnitFrame.unit
		if unit then
			UpdateNameplateText(unit)
		end
	end
end

local function HideNameplateText(unit)
	local bar = GetHealthBar(unit)
	if not bar then return end
	addon.HideBarText(bar)
end

local function HideExistingNameplates()
	for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
		local unit = plate.namePlateUnitToken or plate.UnitFrame and plate.UnitFrame.unit
		if unit then
			HideNameplateText(unit)
		end
	end
end

function addon.EnableNameplates()
	if enabled then return end
	enabled = true
	eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	eventFrame:RegisterEvent("UNIT_HEALTH")
	eventFrame:RegisterEvent("UNIT_MAXHEALTH")
	eventFrame:RegisterEvent("CVAR_UPDATE")
	eventFrame:SetScript("OnEvent", function(_, event, arg1)
		if event == "NAME_PLATE_UNIT_ADDED" or event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
			UpdateNameplateText(arg1)
			return
		end

		if arg1 == "statusText" or arg1 == "statusTextDisplay" then
			UpdateExistingNameplates()
		end
	end)

	UpdateExistingNameplates()
end

function addon.DisableNameplates()
	if not enabled then return end
	enabled = false
	eventFrame:UnregisterAllEvents()
	eventFrame:SetScript("OnEvent", nil)
	HideExistingNameplates()
end
