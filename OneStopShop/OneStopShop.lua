local addonName, addon = ...

-- Addon version (updated by release workflow)
addon.version = "1.0.8"

-- Config version for migrations
addon.configVersion = 2

-- Changelog for update notifications
addon.changelog = {
    ["1.0.8"] = {
        "Added localization support",
        "Added /oss version command",
        "Added first-run welcome wizard",
        "Added changelog popup on update",
        "Added config option tooltips",
        "Added right-click menu on buyer names",
        "Made both windows resizable",
        "Improved GHA workflow with manual release option",
    },
}

-- Player info (populated on load)
addon.playerClass = nil
addon.playerName = nil
addon.playerFaction = nil

-- Show version info
local function ShowVersionInfo()
    local L = addon.L
    addon.Utils.Print(string.format(L["VERSION_INFO"], addon.version))
    addon.Utils.Print(L["VERSION_AUTHOR"])
    local _, _, _, tocVersion = GetBuildInfo()
    addon.Utils.Print(string.format(L["VERSION_CLIENT"], tocVersion or "Unknown"))
end

-- Slash command handler
local function HandleSlashCommand(msg)
    local L = addon.L
    local cmd, args = msg:match("^(%S*)%s*(.-)$")
    cmd = cmd:lower()

    if cmd == "" or cmd == "show" then
        addon.MainFrame.Toggle()

    elseif cmd == "config" or cmd == "options" or cmd == "settings" then
        addon.ConfigFrame.Toggle()

    elseif cmd == "start" then
        addon.Advertiser.Start()

    elseif cmd == "stop" then
        addon.Advertiser.Stop()

    elseif cmd == "stats" then
        addon.ServiceTracker.PrintStats()

    elseif cmd == "clear" then
        addon.BuyerDetector.ClearQueue()
        addon.Utils.Print(L["BUYER_QUEUE_CLEARED"])

    elseif cmd == "log" then
        addon.MainFrame.ShowLogDialog()

    elseif cmd == "version" or cmd == "ver" or cmd == "about" then
        ShowVersionInfo()

    elseif cmd == "changelog" then
        addon.ShowChangelog()

    elseif cmd == "help" then
        addon.Utils.Print(L["CMD_HELP_HEADER"])
        addon.Utils.Print(L["CMD_OSS"])
        addon.Utils.Print(L["CMD_CONFIG"])
        addon.Utils.Print(L["CMD_START"])
        addon.Utils.Print(L["CMD_STOP"])
        addon.Utils.Print(L["CMD_STATS"])
        addon.Utils.Print(L["CMD_CLEAR"])
        addon.Utils.Print(L["CMD_LOG"])
        addon.Utils.Print(L["CMD_VERSION"])
        addon.Utils.Print(L["CMD_HELP"])

    else
        addon.Utils.PrintError(string.format(L["UNKNOWN_COMMAND"], cmd))
        addon.Utils.Print(L["TYPE_HELP"])
    end
end

-- Register slash commands
SLASH_ONESTOPSHOP1 = "/oss"
SLASH_ONESTOPSHOP2 = "/onestopshop"
SlashCmdList["ONESTOPSHOP"] = HandleSlashCommand

-- Create minimap button
local function CreateMinimapButton()
    local btn = CreateFrame("Button", "OneStopShopMinimapButton", Minimap)
    btn:SetSize(32, 32)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)

    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local icon = btn:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER")
    icon:SetTexture("Interface\\Icons\\INV_Misc_Rune_06") -- Portal rune icon
    btn.icon = icon

    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetSize(54, 54)
    border:SetPoint("CENTER")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    -- Position around minimap
    local function UpdatePosition(angle)
        local x = math.cos(math.rad(angle)) * 80
        local y = math.sin(math.rad(angle)) * 80
        btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end

    -- Dragging
    btn:SetMovable(true)
    btn:EnableMouse(true)
    btn:RegisterForClicks("AnyUp")
    btn:RegisterForDrag("LeftButton")

    btn:SetScript("OnDragStart", function(self)
        self.dragging = true
    end)

    btn:SetScript("OnDragStop", function(self)
        self.dragging = false
        -- Calculate angle from minimap center
        local mx, my = Minimap:GetCenter()
        local bx, by = self:GetCenter()
        local angle = math.deg(math.atan2(by - my, bx - mx))
        addon.Config.Set("ui.minimapPosition", angle)
        UpdatePosition(angle)
    end)

    btn:SetScript("OnUpdate", function(self)
        if self.dragging then
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale = UIParent:GetEffectiveScale()
            cx, cy = cx / scale, cy / scale
            local angle = math.deg(math.atan2(cy - my, cx - mx))
            UpdatePosition(angle)
        end
    end)

    btn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            addon.MainFrame.Toggle()
        elseif button == "RightButton" then
            addon.ConfigFrame.Toggle()
        end
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("OneStopShop")
        GameTooltip:AddLine("Left-click: Toggle window", 1, 1, 1)
        GameTooltip:AddLine("Right-click: Settings", 1, 1, 1)
        if addon.Advertiser.IsAdvertising() then
            GameTooltip:AddLine("|cff00ff00Advertising active|r", 1, 1, 1)
        end
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Initial position
    local angle = addon.Config.Get("ui.minimapPosition") or 45
    UpdatePosition(angle)

    return btn
end

-- Show welcome wizard for first-time users
local function ShowWelcomeWizard()
    local L = addon.L

    local f = CreateFrame("Frame", "OneStopShopWelcome", UIParent, "BackdropTemplate")
    f:SetSize(350, 220)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    f:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0.1, 0.1, 0.2, 0.95)
    f:SetBackdropBorderColor(0.4, 0.6, 1, 1)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -15)
    title:SetText(L["WELCOME_TITLE"])
    title:SetTextColor(0.4, 0.8, 1)

    local line1 = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    line1:SetPoint("TOPLEFT", 20, -50)
    line1:SetWidth(310)
    line1:SetJustifyH("LEFT")
    line1:SetText(L["WELCOME_LINE1"])

    local line2 = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    line2:SetPoint("TOPLEFT", 20, -80)
    line2:SetText(L["WELCOME_LINE2"])

    local line3 = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    line3:SetPoint("TOPLEFT", 25, -100)
    line3:SetText(L["WELCOME_LINE3"])

    local line4 = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    line4:SetPoint("TOPLEFT", 25, -115)
    line4:SetText(L["WELCOME_LINE4"])

    local line5 = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    line5:SetPoint("TOPLEFT", 25, -130)
    line5:SetText(L["WELCOME_LINE5"])

    local credit = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    credit:SetPoint("BOTTOM", 0, 45)
    credit:SetText(L["MADE_BY"])

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetSize(100, 25)
    closeBtn:SetPoint("BOTTOM", 0, 15)
    closeBtn:SetText(L["WELCOME_CLOSE"])
    closeBtn:SetScript("OnClick", function()
        f:Hide()
        addon.Config.Set("firstRun", false)
        addon.MainFrame.Show()
    end)

    f:Show()
end

-- Show changelog popup
function addon.ShowChangelog(forceShow)
    local L = addon.L
    local lastVersion = addon.Config.Get("lastVersion")

    -- Don't show if same version (unless forced)
    if not forceShow and lastVersion == addon.version then
        return
    end

    local changes = addon.changelog[addon.version]
    if not changes and not forceShow then
        return
    end

    local f = CreateFrame("Frame", "OneStopShopChangelog", UIParent, "BackdropTemplate")
    f:SetSize(350, 280)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    f:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0.1, 0.1, 0.2, 0.95)
    f:SetBackdropBorderColor(0.4, 0.6, 1, 1)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -15)
    title:SetText(L["CHANGELOG_TITLE"])
    title:SetTextColor(0.4, 0.8, 1)

    local versionText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    versionText:SetPoint("TOP", title, "BOTTOM", 0, -5)
    versionText:SetText(string.format(L["CHANGELOG_UPDATED"], addon.version))

    local yOffset = -65
    if changes then
        for _, change in ipairs(changes) do
            local line = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            line:SetPoint("TOPLEFT", 25, yOffset)
            line:SetWidth(300)
            line:SetJustifyH("LEFT")
            line:SetText("- " .. change)
            yOffset = yOffset - 18
        end
    end

    local credit = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    credit:SetPoint("BOTTOM", 0, 45)
    credit:SetText(L["MADE_BY"])

    local closeBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 25)
    closeBtn:SetPoint("BOTTOM", 0, 15)
    closeBtn:SetText("OK")
    closeBtn:SetScript("OnClick", function()
        f:Hide()
    end)

    f:Show()

    -- Update last seen version
    addon.Config.Set("lastVersion", addon.version)
end

-- Check client version compatibility
local function CheckClientVersion()
    local _, _, _, tocVersion = GetBuildInfo()
    if not tocVersion then return end

    -- Known supported interface versions
    local supported = {
        [11508] = true, -- Classic Era 1.15.8
        [20505] = true, -- TBC 2.5.5
        [40402] = true, -- Cata 4.4.2
    }

    -- Check major version match (first digit)
    local majorVersion = math.floor(tocVersion / 10000)
    local isSupported = false

    for ver, _ in pairs(supported) do
        if math.floor(ver / 10000) == majorVersion then
            isSupported = true
            break
        end
    end

    if not isSupported then
        addon.Utils.PrintError("Warning: This WoW client version may not be fully supported.")
        addon.Utils.Print("Please check for addon updates at github.com/justinmaks/onestopshop")
    end
end

-- Initialize addon
local function Initialize()
    local L = addon.L

    -- Get player info
    addon.playerClass = select(2, UnitClass("player"))
    addon.playerName = UnitName("player")
    addon.playerFaction = UnitFactionGroup("player")

    -- Initialize config (must be first)
    addon.Config.Initialize()

    -- Check if first run
    local isFirstRun = addon.Config.Get("firstRun") ~= false and addon.Config.Get("lastVersion") == nil

    -- Initialize modules
    addon.Advertiser.Initialize()
    addon.BuyerDetector.Initialize()
    addon.PartyManager.Initialize()
    addon.ServiceTracker.Initialize()
    addon.SpellCaster.Initialize()

    -- Initialize UI
    addon.MainFrame.Initialize()
    addon.ConfigFrame.Initialize()

    -- Create minimap button
    if addon.Config.Get("ui.minimapButton") ~= false then
        CreateMinimapButton()
    end

    -- Check client version
    CheckClientVersion()

    -- Show appropriate welcome message/wizard
    if isFirstRun then
        addon.Utils.Print(string.format(L["ADDON_LOADED_FIRST_RUN"], addon.version))
        C_Timer.After(1, ShowWelcomeWizard)
    else
        addon.Utils.Print(string.format(L["ADDON_LOADED"], addon.version))
        -- Show changelog if version changed
        C_Timer.After(1.5, function()
            addon.ShowChangelog()
        end)
    end

    -- Show class warning for non-mage/warlock
    if addon.playerClass ~= "MAGE" and addon.playerClass ~= "WARLOCK" then
        addon.Utils.Print(L["CLASS_WARNING"])
    end
end

-- Main event frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Delay initialization until player is fully loaded
        C_Timer.After(0.5, Initialize)
        self:UnregisterEvent("ADDON_LOADED")

    elseif event == "PLAYER_LOGOUT" then
        -- Save config on logout
        addon.Config.Save()
    end
end)

-- Add to special frames so ESC closes the windows
tinsert(UISpecialFrames, "OneStopShopMainFrame")
tinsert(UISpecialFrames, "OneStopShopConfigFrame")
tinsert(UISpecialFrames, "OneStopShopWelcome")
tinsert(UISpecialFrames, "OneStopShopChangelog")
