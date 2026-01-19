local addonName, addon = ...

addon.MainFrame = {}
local MainFrame = addon.MainFrame

local frame = nil
local buyerButtons = {}
local spellButtons = {}

-- Create the main frame
local function CreateMainFrame()
    local f = CreateFrame("Frame", "OneStopShopMainFrame", UIParent, "BackdropTemplate")
    f:SetSize(320, 400)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Save position
        local point, _, relPoint, x, y = self:GetPoint()
        addon.Config.Set("ui.mainFramePosition", { point = point, relPoint = relPoint, x = x, y = y })
    end)

    -- Make resizable
    f:SetResizable(true)
    f:SetResizeBounds(280, 350, 500, 600)

    -- Backdrop
    f:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    f:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

    -- Title
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("OneStopShop")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -2, -2)

    -- Class indicator
    local classText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    classText:SetPoint("TOP", title, "BOTTOM", 0, -2)
    f.classText = classText

    -- Divider
    local divider1 = f:CreateTexture(nil, "ARTWORK")
    divider1:SetHeight(1)
    divider1:SetPoint("TOPLEFT", 10, -50)
    divider1:SetPoint("TOPRIGHT", -10, -50)
    divider1:SetColorTexture(0.5, 0.5, 0.5, 0.5)

    -- Advertising Section
    local advLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    advLabel:SetPoint("TOPLEFT", 15, -60)
    advLabel:SetText("Advertising")

    local advStatus = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    advStatus:SetPoint("LEFT", advLabel, "RIGHT", 10, 0)
    advStatus:SetText("|cffff0000Stopped|r")
    f.advStatus = advStatus

    local advBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    advBtn:SetSize(80, 22)
    advBtn:SetPoint("TOPRIGHT", -15, -55)
    advBtn:SetText("Start")
    advBtn:SetScript("OnClick", function()
        addon.Advertiser.Toggle()
    end)
    f.advBtn = advBtn

    -- Divider
    local divider2 = f:CreateTexture(nil, "ARTWORK")
    divider2:SetHeight(1)
    divider2:SetPoint("TOPLEFT", 10, -85)
    divider2:SetPoint("TOPRIGHT", -10, -85)
    divider2:SetColorTexture(0.5, 0.5, 0.5, 0.5)

    -- Buyer Queue Section
    local buyerLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buyerLabel:SetPoint("TOPLEFT", 15, -95)
    buyerLabel:SetText("Potential Buyers")

    local buyerScroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    buyerScroll:SetPoint("TOPLEFT", 15, -115)
    buyerScroll:SetPoint("TOPRIGHT", -35, -115)
    buyerScroll:SetHeight(80)

    local buyerContent = CreateFrame("Frame", nil, buyerScroll)
    buyerContent:SetSize(260, 80)
    buyerScroll:SetScrollChild(buyerContent)
    f.buyerContent = buyerContent

    local noBuyers = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    noBuyers:SetPoint("CENTER", buyerScroll, "CENTER")
    noBuyers:SetText("No buyers detected")
    f.noBuyers = noBuyers

    -- Divider
    local divider3 = f:CreateTexture(nil, "ARTWORK")
    divider3:SetHeight(1)
    divider3:SetPoint("TOPLEFT", 10, -200)
    divider3:SetPoint("TOPRIGHT", -10, -200)
    divider3:SetColorTexture(0.5, 0.5, 0.5, 0.5)

    -- Spells Section
    local spellLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    spellLabel:SetPoint("TOPLEFT", 15, -210)
    spellLabel:SetText("Quick Cast")

    local spellContent = CreateFrame("Frame", nil, f)
    spellContent:SetPoint("TOPLEFT", 15, -230)
    spellContent:SetPoint("TOPRIGHT", -15, -230)
    spellContent:SetHeight(80)
    f.spellContent = spellContent

    -- Divider
    local divider4 = f:CreateTexture(nil, "ARTWORK")
    divider4:SetHeight(1)
    divider4:SetPoint("TOPLEFT", 10, -315)
    divider4:SetPoint("TOPRIGHT", -10, -315)
    divider4:SetColorTexture(0.5, 0.5, 0.5, 0.5)

    -- Statistics Section
    local statsLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statsLabel:SetPoint("TOPLEFT", 15, -325)
    statsLabel:SetText("Statistics")

    local sessionStats = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sessionStats:SetPoint("TOPLEFT", 15, -342)
    sessionStats:SetJustifyH("LEFT")
    f.sessionStats = sessionStats

    local todayStats = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    todayStats:SetPoint("TOPLEFT", 15, -355)
    todayStats:SetJustifyH("LEFT")
    f.todayStats = todayStats

    local allTimeStats = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    allTimeStats:SetPoint("TOPLEFT", 15, -368)
    allTimeStats:SetJustifyH("LEFT")
    f.allTimeStats = allTimeStats

    -- Config button
    local configBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    configBtn:SetSize(70, 22)
    configBtn:SetPoint("BOTTOMLEFT", 15, 10)
    configBtn:SetText("Config")
    configBtn:SetScript("OnClick", function()
        addon.ConfigFrame.Toggle()
    end)

    -- Log Service button
    local logBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    logBtn:SetSize(90, 22)
    logBtn:SetPoint("BOTTOMRIGHT", -15, 10)
    logBtn:SetText("Log Service")
    logBtn:SetScript("OnClick", function()
        MainFrame.ShowLogDialog()
    end)

    -- Credit text
    local credit = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    credit:SetPoint("BOTTOM", 0, 12)
    credit:SetText("Made by Stin")

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

-- Update advertising status display
local function UpdateAdvertisingStatus()
    if not frame then return end

    if addon.Advertiser.IsAdvertising() then
        frame.advStatus:SetText("|cff00ff00Running|r")
        frame.advBtn:SetText("Stop")
    else
        frame.advStatus:SetText("|cffff0000Stopped|r")
        frame.advBtn:SetText("Start")
    end
end

-- Update buyer queue display
local function UpdateBuyerQueue()
    if not frame then return end

    -- Clear existing buttons
    for _, btn in ipairs(buyerButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end
    buyerButtons = {}

    local queue = addon.BuyerDetector.GetQueue()

    if #queue == 0 then
        frame.noBuyers:Show()
        return
    end

    frame.noBuyers:Hide()

    local yOffset = 0
    for i, buyer in ipairs(queue) do
        if i > 5 then break end -- Show max 5

        local row = CreateFrame("Frame", nil, frame.buyerContent)
        row:SetSize(250, 20)
        row:SetPoint("TOPLEFT", 0, -yOffset)

        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        nameText:SetPoint("LEFT", 0, 0)
        nameText:SetText(buyer.name)
        nameText:SetWidth(80)
        nameText:SetJustifyH("LEFT")

        local msgText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        msgText:SetPoint("LEFT", nameText, "RIGHT", 5, 0)
        msgText:SetText(buyer.message:sub(1, 30))
        msgText:SetWidth(100)
        msgText:SetJustifyH("LEFT")

        local inviteBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        inviteBtn:SetSize(50, 18)
        inviteBtn:SetPoint("RIGHT", 0, 0)
        inviteBtn:SetText(buyer.invited and "Sent" or "Invite")
        if buyer.invited then
            inviteBtn:Disable()
        end
        inviteBtn:SetScript("OnClick", function()
            addon.PartyManager.Invite(buyer.name)
            UpdateBuyerQueue()
        end)

        table.insert(buyerButtons, row)
        yOffset = yOffset + 22
    end
end

-- Update spell buttons
local function UpdateSpellButtons()
    if not frame then return end

    -- Clear existing buttons
    for _, btn in ipairs(spellButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end
    spellButtons = {}

    if addon.playerClass == "MAGE" then
        local portals = addon.SpellCaster.GetKnownPortals()
        local col, row = 0, 0
        local btnWidth, btnHeight = 70, 22
        local padding = 5

        for i, portal in ipairs(portals) do
            local btn = addon.SpellCaster.CreateSpellButton(frame.spellContent, portal.id, btnWidth, btnHeight)
            btn:SetPoint("TOPLEFT", col * (btnWidth + padding), -row * (btnHeight + padding))
            btn:SetText(addon.SpellCaster.GetDestinationName(portal.destination))

            table.insert(spellButtons, btn)

            col = col + 1
            if col >= 4 then
                col = 0
                row = row + 1
            end
        end

        if #portals == 0 then
            local noSpells = frame.spellContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
            noSpells:SetPoint("CENTER")
            noSpells:SetText("No portal spells known")
        end

    elseif addon.playerClass == "WARLOCK" then
        if addon.SpellCaster.KnowsSummon() then
            local btn = addon.SpellCaster.CreateSpellButton(frame.spellContent, 698, 120, 30)
            btn:SetPoint("TOPLEFT", 0, 0)
            btn:SetText("Ritual of Summoning")

            -- Add party check indicator
            local partyInfo = frame.spellContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
            partyInfo:SetPoint("TOP", btn, "BOTTOM", 0, -5)

            local canSummon, reason = addon.PartyManager.CanSummon()
            if canSummon then
                partyInfo:SetText("|cff00ff00Ready to summon|r")
            else
                partyInfo:SetText("|cffff0000" .. reason .. "|r")
            end

            table.insert(spellButtons, btn)
        else
            local noSpells = frame.spellContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
            noSpells:SetPoint("CENTER")
            noSpells:SetText("Learn Ritual of Summoning (level 20)")
        end
    else
        local noClass = frame.spellContent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        noClass:SetPoint("CENTER")
        noClass:SetText("Only Mages and Warlocks can use this addon")
    end
end

-- Update statistics display
local function UpdateStatistics()
    if not frame then return end

    local session = addon.ServiceTracker.GetSessionStats()
    local today = addon.ServiceTracker.GetTodayStats()
    local allTime = addon.ServiceTracker.GetAllTimeStats()

    frame.sessionStats:SetText(string.format("Session: %d services, %s", session.services, session.goldFormatted))
    frame.todayStats:SetText(string.format("Today: %d services, %s", today.services, today.goldFormatted))
    frame.allTimeStats:SetText(string.format("All-Time: %d services, %s", allTime.services, allTime.goldFormatted))
end

-- Show log service dialog
function MainFrame.ShowLogDialog()
    -- Simple static popup for logging a service
    StaticPopupDialogs["OSS_LOG_SERVICE"] = {
        text = "Log completed service?",
        button1 = "Portal",
        button2 = "Summon",
        button3 = "Cancel",
        OnButton1 = function()
            local price = addon.Config.Get("prices.portal") or 2
            addon.ServiceTracker.LogService("portal", "Manual", nil, price * 10000)
            MainFrame.Refresh()
        end,
        OnButton2 = function()
            local price = addon.Config.Get("prices.summon") or 3
            addon.ServiceTracker.LogService("summon", "Manual", nil, price * 10000)
            MainFrame.Refresh()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }
    StaticPopup_Show("OSS_LOG_SERVICE")
end

-- Refresh all displays
function MainFrame.Refresh()
    if not frame or not frame:IsShown() then return end

    UpdateAdvertisingStatus()
    UpdateBuyerQueue()
    UpdateSpellButtons()
    UpdateStatistics()

    -- Update class text
    if addon.playerClass then
        local classColor = RAID_CLASS_COLORS[addon.playerClass]
        if classColor then
            frame.classText:SetText(string.format("|cff%02x%02x%02x%s|r",
                classColor.r * 255, classColor.g * 255, classColor.b * 255,
                addon.playerClass:sub(1, 1) .. addon.playerClass:sub(2):lower()))
        end
    end
end

-- Show main frame
function MainFrame.Show()
    if not frame then
        frame = CreateMainFrame()
    end

    -- Restore position
    local pos = addon.Config.Get("ui.mainFramePosition")
    if pos then
        frame:ClearAllPoints()
        frame:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
    end

    frame:Show()
    MainFrame.Refresh()
end

-- Hide main frame
function MainFrame.Hide()
    if frame then
        frame:Hide()
    end
end

-- Toggle main frame
function MainFrame.Toggle()
    if frame and frame:IsShown() then
        MainFrame.Hide()
    else
        MainFrame.Show()
    end
end

-- Initialize module
function MainFrame.Initialize()
    -- Register for events that should trigger refresh
    addon.Events.Register("OSS_ADVERTISING_STARTED", UpdateAdvertisingStatus)
    addon.Events.Register("OSS_ADVERTISING_STOPPED", UpdateAdvertisingStatus)
    addon.Events.Register("OSS_BUYER_DETECTED", UpdateBuyerQueue)
    addon.Events.Register("OSS_BUYER_REMOVED", UpdateBuyerQueue)
    addon.Events.Register("OSS_BUYER_INVITED", UpdateBuyerQueue)
    addon.Events.Register("OSS_SERVICE_LOGGED", UpdateStatistics)
    addon.Events.Register("OSS_SPELLS_SCANNED", UpdateSpellButtons)
    addon.Events.Register("OSS_GROUP_CHANGED", UpdateSpellButtons)

    -- Periodic refresh for cooldowns
    addon.Events.RegisterTicker(1, function()
        if frame and frame:IsShown() then
            for _, btn in ipairs(spellButtons) do
                if btn.spellId then
                    addon.SpellCaster.UpdateButtonState(btn, btn.spellId)
                end
            end
        end
    end)
end
