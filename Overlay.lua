local _, CDMBA = ...

CDMButtonAurasOverlayMixin = {}

-- local timerColorCurve = C_CurveUtil.CreateColorCurve()
-- timerColorCurve:SetType(Enum.LuaCurveType.Linear)
-- timerColorCurve:AddPoint(0.0, CreateColor(1, 0, 0, 1))
-- timerColorCurve:AddPoint(3.0, CreateColor(1, 1, 0, 1))
-- timerColorCurve:AddPoint(10.0, CreateColor(1, 1, 1, 1))

function CDMButtonAurasOverlayMixin:OnLoad()
    local parent = self:GetParent()
    PixelUtil.SetSize(self, parent:GetSize())

    if parent.cooldown then
        self:SetFrameLevel(parent.cooldown:GetFrameLevel() + 1)
    end

    self.Cooldown:SetPoint("TOPLEFT", parent.icon, "LEFT", 5, 0)
    self.Cooldown:SetPoint("BOTTOMRIGHT", parent.icon, "BOTTOM", 0, 3)
    self.Cooldown:SetDrawSwipe(false)
    self.Cooldown:SetCountdownFont("NumberFontNormal")
    self.Cooldown:SetCountdownAbbrevThreshold(60)
    self.Cooldown:SetScript('OnCooldownDone', function () self:Update() end)
end

function CDMButtonAurasOverlayMixin:Update(viewerItem, duration)
    self:Hide()
    if viewerItem and viewerItem.auraDataUnit and viewerItem.auraInstanceID then
        local duration = C_UnitAuras.GetAuraDuration(viewerItem.auraDataUnit, viewerItem.auraInstanceID)
        if duration then
            self.Cooldown:SetCooldownFromDurationObject(duration, true)

            local stackText = viewerItem.Applications.Applications:GetText()
            self.Stacks:SetText(stackText)

            if viewerItem.auraDataUnit == 'player' then
                self.Glow:SetVertexColor(0, 0.7, 0, 0.5)
            else
                self.Glow:SetVertexColor(1, 0, 0, 0.5)
            end
            self.Glow:Show()

            self:Show()
        end
    end
end
