CDMButtonAurasControllerMixin = {}

function CDMButtonAurasControllerMixin:GetActionButton(cdInfo)
    local spellIDs = { cdInfo.spellID }
    tAppendAll(spellIDs, cdInfo.linkedSpellIDs)
    for _, spellID in ipairs(spellIDs) do
        local button = ActionButtonUtil.GetActionButtonBySpellID(spellID, true)
        if button then return button end
    end
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
