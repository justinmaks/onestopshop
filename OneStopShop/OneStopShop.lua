local addonName, addon = ...

-- Addon version
addon.version = "1.0.0"

-- Player info (populated on load)
addon.playerClass = nil
addon.playerName = nil
addon.playerFaction = nil

-- Slash command handler
local function HandleSlashCommand(msg)
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
        addon.Utils.Print("Buyer queue cleared.")

    elseif cmd == "log" then
        addon.MainFrame.ShowLogDialog()

    elseif cmd == "help" then
        addon.Utils.Print("Commands:")
        addon.Utils.Print("  /oss - Toggle main window")
        addon.Utils.Print("  /oss config - Open settings")
        addon.Utils.Print("  /oss start - Start advertising")
        addon.Utils.Print("  /oss stop - Stop advertising")
        addon.Utils.Print("  /oss stats - Show statistics")
        addon.Utils.Print("  /oss clear - Clear buyer queue")
        addon.Utils.Print("  /oss log - Log a service manually")
        addon.Utils.Print("  /oss help - Show this help")

    else
        addon.Utils.PrintError("Unknown command: " .. cmd)
        addon.Utils.Print("Type /oss help for available commands.")
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

-- Initialize addon
local function Initialize()
    -- Get player info
    addon.playerClass = select(2, UnitClass("player"))
    addon.playerName = UnitName("player")
    addon.playerFaction = UnitFactionGroup("player")

    -- Initialize config (must be first)
    addon.Config.Initialize()

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

    -- Print welcome message
    addon.Utils.Print("v" .. addon.version .. " loaded. Type /oss for commands.")

    -- Show class warning for non-mage/warlock
    if addon.playerClass ~= "MAGE" and addon.playerClass ~= "WARLOCK" then
        addon.Utils.Print("Note: This addon is designed for Mages and Warlocks.")
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
