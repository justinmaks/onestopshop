local addonName, addon = ...

addon.ConfigFrame = {}
local ConfigFrame = addon.ConfigFrame

local frame = nil

-- Helper to add tooltip to a frame
local function AddTooltip(frame, tooltipText)
    if not tooltipText then return end
    frame:EnableMouse(true)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tooltipText, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

-- Create a labeled input box with optional tooltip
local function CreateInputBox(parent, label, width, initialValue, tooltip)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(width + 100, 25)

    local labelText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelText:SetPoint("LEFT", 0, 0)
    labelText:SetText(label)
    labelText:SetWidth(90)
    labelText:SetJustifyH("LEFT")

    local editBox = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
    editBox:SetSize(width, 20)
    editBox:SetPoint("LEFT", labelText, "RIGHT", 10, 0)
    editBox:SetAutoFocus(false)
    editBox:SetText(initialValue or "")
    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    editBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

    container.editBox = editBox

    -- Add tooltip
    if tooltip then
        AddTooltip(container, tooltip)
    end

    return container
end

-- Create a labeled checkbox with optional tooltip
local function CreateCheckbox(parent, label, initialValue, tooltip)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(250, 25)

    local checkbox = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    checkbox:SetPoint("LEFT", 0, 0)
    checkbox:SetChecked(initialValue or false)

    local labelText = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelText:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    labelText:SetText(label)

    container.checkbox = checkbox

    -- Add tooltip
    if tooltip then
        AddTooltip(container, tooltip)
    end

    return container
end

-- Create the config frame
local function CreateConfigFrame()
    local L = addon.L

    local f = CreateFrame("Frame", "OneStopShopConfigFrame", UIParent, "BackdropTemplate")
    f:SetSize(400, 450)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    -- Make resizable
    f:SetResizable(true)
    f:SetResizeBounds(350, 400, 600, 600)

    -- Backdrop
    f:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    f:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

    -- Title
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText(L["SETTINGS_TITLE"])

    -- Close button
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -2, -2)

    local yOffset = -40

    -- == Advertising Section ==
    local advHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    advHeader:SetPoint("TOPLEFT", 15, yOffset)
    advHeader:SetText(L["CFG_ADVERTISING"])
    yOffset = yOffset - 25

    local intervalInput = CreateInputBox(f, L["CFG_INTERVAL"], 60,
        tostring(addon.Config.Get("advertising.interval") or 60), L["TIP_INTERVAL"])
    intervalInput:SetPoint("TOPLEFT", 15, yOffset)
    f.intervalInput = intervalInput
    yOffset = yOffset - 30

    local mageTemplateInput = CreateInputBox(f, L["CFG_MAGE_AD"], 200,
        addon.Config.Get("advertising.mageTemplate") or "", L["TIP_MAGE_AD"])
    mageTemplateInput:SetPoint("TOPLEFT", 15, yOffset)
    f.mageTemplateInput = mageTemplateInput
    yOffset = yOffset - 30

    local warlockTemplateInput = CreateInputBox(f, L["CFG_WARLOCK_AD"], 200,
        addon.Config.Get("advertising.warlockTemplate") or "", L["TIP_WARLOCK_AD"])
    warlockTemplateInput:SetPoint("TOPLEFT", 15, yOffset)
    f.warlockTemplateInput = warlockTemplateInput
    yOffset = yOffset - 35

    -- == Prices Section ==
    local priceHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    priceHeader:SetPoint("TOPLEFT", 15, yOffset)
    priceHeader:SetText(L["CFG_PRICES"])
    yOffset = yOffset - 25

    local portalPriceInput = CreateInputBox(f, L["CFG_PORTAL_PRICE"], 60,
        tostring(addon.Config.Get("prices.portal") or 2), L["TIP_PORTAL_PRICE"])
    portalPriceInput:SetPoint("TOPLEFT", 15, yOffset)
    f.portalPriceInput = portalPriceInput

    local summonPriceInput = CreateInputBox(f, L["CFG_SUMMON_PRICE"], 60,
        tostring(addon.Config.Get("prices.summon") or 3), L["TIP_SUMMON_PRICE"])
    summonPriceInput:SetPoint("TOPLEFT", 200, yOffset)
    f.summonPriceInput = summonPriceInput
    yOffset = yOffset - 35

    -- == Detection Section ==
    local detectHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    detectHeader:SetPoint("TOPLEFT", 15, yOffset)
    detectHeader:SetText(L["CFG_DETECTION"])
    yOffset = yOffset - 25

    local detectionEnabled = CreateCheckbox(f, L["CFG_DETECTION_ENABLED"],
        addon.Config.Get("detection.enabled") ~= false, L["TIP_DETECTION_ENABLED"])
    detectionEnabled:SetPoint("TOPLEFT", 15, yOffset)
    f.detectionEnabled = detectionEnabled
    yOffset = yOffset - 25

    local soundEnabled = CreateCheckbox(f, L["CFG_SOUND_ENABLED"],
        addon.Config.Get("detection.soundEnabled") ~= false, L["TIP_SOUND_ENABLED"])
    soundEnabled:SetPoint("TOPLEFT", 15, yOffset)
    f.soundEnabled = soundEnabled
    yOffset = yOffset - 35

    -- == Party Section ==
    local partyHeader = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    partyHeader:SetPoint("TOPLEFT", 15, yOffset)
    partyHeader:SetText(L["CFG_PARTY"])
    yOffset = yOffset - 25

    local autoKick = CreateCheckbox(f, L["CFG_AUTO_KICK"],
        addon.Config.Get("party.autoKick") or false, L["TIP_AUTO_KICK"])
    autoKick:SetPoint("TOPLEFT", 15, yOffset)
    f.autoKick = autoKick
    yOffset = yOffset - 25

    local kickDelayInput = CreateInputBox(f, L["CFG_KICK_DELAY"], 60,
        tostring(addon.Config.Get("party.autoKickDelay") or 10), L["TIP_KICK_DELAY"])
    kickDelayInput:SetPoint("TOPLEFT", 15, yOffset)
    f.kickDelayInput = kickDelayInput
    yOffset = yOffset - 30

    local whisperOnInvite = CreateCheckbox(f, L["CFG_WHISPER_INVITE"],
        addon.Config.Get("party.whisperOnInvite") ~= false, L["TIP_WHISPER_INVITE"])
    whisperOnInvite:SetPoint("TOPLEFT", 15, yOffset)
    f.whisperOnInvite = whisperOnInvite
    yOffset = yOffset - 25

    local inviteWhisperInput = CreateInputBox(f, L["CFG_INVITE_MSG"], 180,
        addon.Config.Get("party.inviteWhisper") or "", L["TIP_INVITE_MSG"])
    inviteWhisperInput:SetPoint("TOPLEFT", 15, yOffset)
    f.inviteWhisperInput = inviteWhisperInput
    yOffset = yOffset - 40

    -- Save button
    local saveBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    saveBtn:SetSize(80, 25)
    saveBtn:SetPoint("BOTTOMRIGHT", -15, 15)
    saveBtn:SetText(L["BTN_SAVE"])
    saveBtn:SetScript("OnClick", function()
        ConfigFrame.Save()
        addon.Utils.Print(L["SETTINGS_SAVED"])
    end)

    -- Reset button
    local resetBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    resetBtn:SetSize(80, 25)
    resetBtn:SetPoint("RIGHT", saveBtn, "LEFT", -10, 0)
    resetBtn:SetText(L["BTN_RESET"])
    resetBtn:SetScript("OnClick", function()
        StaticPopupDialogs["OSS_RESET_CONFIRM"] = {
            text = L["RESET_CONFIRM"],
            button1 = L["BTN_YES"],
            button2 = L["BTN_NO"],
            OnAccept = function()
                addon.Config.Reset()
                ConfigFrame.Refresh()
                addon.Utils.Print(L["SETTINGS_RESET"])
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("OSS_RESET_CONFIRM")
    end)

    -- Credit text
    local credit = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    credit:SetPoint("BOTTOMLEFT", 15, 18)
    credit:SetText(L["MADE_BY"])

    -- Resize grip
    local resizeBtn = CreateFrame("Button", nil, f)
    resizeBtn:SetSize(16, 16)
    resizeBtn:SetPoint("BOTTOMRIGHT", -2, 2)
    resizeBtn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeBtn:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeBtn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeBtn:SetScript("OnMouseDown", function(self)
        f:StartSizing("BOTTOMRIGHT")
    end)
    resizeBtn:SetScript("OnMouseUp", function(self)
        f:StopMovingOrSizing()
    end)

    f:Hide()
    return f
end

-- Save settings from UI to config
function ConfigFrame.Save()
    if not frame then return end

    -- Advertising
    local interval = tonumber(frame.intervalInput.editBox:GetText()) or 60
    if interval < 15 then interval = 15 end
    addon.Config.Set("advertising.interval", interval)
    addon.Config.Set("advertising.mageTemplate", frame.mageTemplateInput.editBox:GetText())
    addon.Config.Set("advertising.warlockTemplate", frame.warlockTemplateInput.editBox:GetText())

    -- Prices
    addon.Config.Set("prices.portal", tonumber(frame.portalPriceInput.editBox:GetText()) or 2)
    addon.Config.Set("prices.summon", tonumber(frame.summonPriceInput.editBox:GetText()) or 3)

    -- Detection
    addon.Config.Set("detection.enabled", frame.detectionEnabled.checkbox:GetChecked())
    addon.Config.Set("detection.soundEnabled", frame.soundEnabled.checkbox:GetChecked())
    addon.BuyerDetector.SetEnabled(frame.detectionEnabled.checkbox:GetChecked())

    -- Party
    addon.Config.Set("party.autoKick", frame.autoKick.checkbox:GetChecked())
    local kickDelay = tonumber(frame.kickDelayInput.editBox:GetText()) or 10
    if kickDelay < 1 then kickDelay = 1 end
    addon.Config.Set("party.autoKickDelay", kickDelay)
    addon.Config.Set("party.whisperOnInvite", frame.whisperOnInvite.checkbox:GetChecked())
    addon.Config.Set("party.inviteWhisper", frame.inviteWhisperInput.editBox:GetText())

    -- Update advertiser interval if running
    if addon.Advertiser.IsAdvertising() then
        addon.Advertiser.SetInterval(interval)
    end
end

-- Refresh UI from config
function ConfigFrame.Refresh()
    if not frame then return end

    frame.intervalInput.editBox:SetText(tostring(addon.Config.Get("advertising.interval") or 60))
    frame.mageTemplateInput.editBox:SetText(addon.Config.Get("advertising.mageTemplate") or "")
    frame.warlockTemplateInput.editBox:SetText(addon.Config.Get("advertising.warlockTemplate") or "")

    frame.portalPriceInput.editBox:SetText(tostring(addon.Config.Get("prices.portal") or 2))
    frame.summonPriceInput.editBox:SetText(tostring(addon.Config.Get("prices.summon") or 3))

    frame.detectionEnabled.checkbox:SetChecked(addon.Config.Get("detection.enabled") ~= false)
    frame.soundEnabled.checkbox:SetChecked(addon.Config.Get("detection.soundEnabled") ~= false)

    frame.autoKick.checkbox:SetChecked(addon.Config.Get("party.autoKick") or false)
    frame.kickDelayInput.editBox:SetText(tostring(addon.Config.Get("party.autoKickDelay") or 10))
    frame.whisperOnInvite.checkbox:SetChecked(addon.Config.Get("party.whisperOnInvite") ~= false)
    frame.inviteWhisperInput.editBox:SetText(addon.Config.Get("party.inviteWhisper") or "")
end

-- Show config frame
function ConfigFrame.Show()
    if not frame then
        frame = CreateConfigFrame()
    end

    ConfigFrame.Refresh()
    frame:Show()
end

-- Hide config frame
function ConfigFrame.Hide()
    if frame then
        frame:Hide()
    end
end

-- Toggle config frame
function ConfigFrame.Toggle()
    if frame and frame:IsShown() then
        ConfigFrame.Hide()
    else
        ConfigFrame.Show()
    end
end

-- Initialize module
function ConfigFrame.Initialize()
    -- Nothing special needed
end
