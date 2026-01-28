CDMButtonAurasControllerMixin = {}

local function FindActionButtonForSpellName(name)
    for _, actionBar in ipairs(ActionButtonUtil.ActionBarButtonNames) do
        for i = 1, NUM_ACTIONBAR_BUTTONS do
            local btn = _G[actionBar..i]
            local _, actionSpellID = GetActionInfo(btn.action)
            if actionSpellID then
                local baseSpellID = C_Spell.GetBaseSpell(actionSpellID)
                local actionSpellName = C_Spell.GetSpellName(baseSpellID)
                if name == actionSpellName then
                    return btn
                end
            end
        end
    end
    for i = 1, NUM_SPECIAL_BUTTONS do
        -- Stance Bar buttons
        local stanceBtn = StanceBar.actionButtons[i]
        local stanceSpellID = select(4, GetShapeshiftFormInfo(stanceBtn:GetID()))
        if stanceSpellID then
            local stanceSpellName = C_Spell.GetSpellName(stanceSpellID)
            if name == stanceSpellName then
                return stanceBtn
            end
        end
    end
end

function CDMButtonAurasControllerMixin:GetActionButton(cdInfo)
    local cdSpellName = C_Spell.GetSpellName(cdInfo.spellID)
    return FindActionButtonForSpellName(cdSpellName)
end

function CDMButtonAurasControllerMixin:GetOverlay(actionButton)
    if not self.overlayFrames[actionButton] then
        local name = actionButton:GetName() .. "CDMButtonAurasOverlay"
        self.overlayFrames[actionButton] = CreateFrame('Frame', name, actionButton, "CDMButtonAurasOverlayTemplate")
    end
    return self.overlayFrames[actionButton]
end

function CDMButtonAurasControllerMixin:UpdateFromItem(item)
    if not item.cooldownID then return end

    local cdInfo = C_CooldownViewer.GetCooldownViewerCooldownInfo(item.cooldownID)
    if cdInfo.spellID then
        local button = self:GetActionButton(cdInfo)
        if button then
            local overlay = self:GetOverlay(button)
            overlay:Update(item, cdInfo)
        end
    end
end

function CDMButtonAurasControllerMixin:UpdateFromViewer(viewer)
    for _, itemFrame in ipairs(viewer:GetItemFrames()) do
        if itemFrame.cooldownID then
            self:UpdateFromItem(itemFrame)
        end
    end
end

function CDMButtonAurasControllerMixin:HookViewerItem(item)
    if not item.__CDMBAHooked then
        local hook = function () self:UpdateFromItem(item) end
        hooksecurefunc(item, 'RefreshData', hook)
        item.__CDMBAHooked = true
    end
end

function CDMButtonAurasControllerMixin:Initialize()
    --[[
    BuffBarCooldownViewer:HookScript('OnUpdate', updateHook)
    BuffIconCooldownViewer:HookScript('OnUpdate', updateHook)
    ]]
    local hook = function (_, item) self:HookViewerItem(item) end
    hooksecurefunc(BuffBarCooldownViewer, 'OnAcquireItemFrame', hook)
    hooksecurefunc(BuffIconCooldownViewer, 'OnAcquireItemFrame', hook)
end

function CDMButtonAurasControllerMixin:OnLoad()
    self.overlayFrames = {}
    self:RegisterEvent('PLAYER_LOGIN')
end

function CDMButtonAurasControllerMixin:OnEvent(event)
    if event == 'PLAYER_LOGIN' then
        self:Initialize()
    end
end
