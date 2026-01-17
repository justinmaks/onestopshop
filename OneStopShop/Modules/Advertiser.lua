local addonName, addon = ...

addon.Advertiser = {}
local Advertiser = addon.Advertiser

local isAdvertising = false
local tickerId = nil
local messageQueue = {}
local lastPostTime = 0
local MIN_INTERVAL = 15 -- Minimum seconds between posts

-- Get the appropriate channel for posting
local function GetTradeChannel()
    local channels = { GetChannelList() }
    for i = 1, #channels, 3 do
        local id, name = channels[i], channels[i + 1]
        if name and name:lower():find("trade") then
            return id
        end
    end
    return nil
end

-- Build advertisement message from template
local function BuildMessage()
    local Config = addon.Config
    local playerClass = addon.playerClass

    local template
    if playerClass == "MAGE" then
        template = Config.Get("advertising.mageTemplate")
    elseif playerClass == "WARLOCK" then
        template = Config.Get("advertising.warlockTemplate")
    else
        return nil
    end

    -- Replace placeholders
    local message = template
    message = message:gsub("{price}", tostring(Config.Get("prices.portal") or 2))
    message = message:gsub("{destinations}", Config.GetDestinationsString())
    message = message:gsub("{summonPrice}", tostring(Config.Get("prices.summon") or 3))

    return message
end

-- Post message to trade chat
local function PostMessage(message)
    local now = GetTime()
    if now - lastPostTime < MIN_INTERVAL then
        table.insert(messageQueue, message)
        return false
    end

    local channel = GetTradeChannel()
    if channel then
        SendChatMessage(message, "CHANNEL", nil, channel)
        lastPostTime = now
        addon.Utils.Print("Posted to trade chat.")
        return true
    else
        addon.Utils.PrintError("Trade channel not found. Are you in a city?")
        return false
    end
end

-- Process message queue
local function ProcessQueue()
    if #messageQueue > 0 then
        local now = GetTime()
        if now - lastPostTime >= MIN_INTERVAL then
            local message = table.remove(messageQueue, 1)
            PostMessage(message)
        end
    end
end

-- Ticker callback for periodic advertising
local function AdvertiseTick()
    if not isAdvertising then return end

    ProcessQueue()

    local message = BuildMessage()
    if message then
        PostMessage(message)
    end
end

-- Start advertising
function Advertiser.Start()
    if isAdvertising then
        addon.Utils.Print("Already advertising.")
        return
    end

    if addon.playerClass ~= "MAGE" and addon.playerClass ~= "WARLOCK" then
        addon.Utils.PrintError("Only Mages and Warlocks can advertise services.")
        return
    end

    local interval = addon.Config.Get("advertising.interval") or 60
    if interval < MIN_INTERVAL then
        interval = MIN_INTERVAL
        addon.Config.Set("advertising.interval", MIN_INTERVAL)
    end

    isAdvertising = true
    addon.Config.Set("advertising.enabled", true)

    -- Post immediately
    local message = BuildMessage()
    if message then
        PostMessage(message)
    end

    -- Set up ticker for periodic posts
    tickerId = addon.Events.RegisterTicker(interval, AdvertiseTick)

    addon.Utils.Print("Started advertising every " .. interval .. " seconds.")
    addon.Events.Fire("OSS_ADVERTISING_STARTED")
end

-- Stop advertising
function Advertiser.Stop()
    if not isAdvertising then
        addon.Utils.Print("Not currently advertising.")
        return
    end

    isAdvertising = false
    addon.Config.Set("advertising.enabled", false)

    if tickerId then
        addon.Events.UnregisterTicker(tickerId)
        tickerId = nil
    end

    messageQueue = {}

    addon.Utils.Print("Stopped advertising.")
    addon.Events.Fire("OSS_ADVERTISING_STOPPED")
end

-- Toggle advertising
function Advertiser.Toggle()
    if isAdvertising then
        Advertiser.Stop()
    else
        Advertiser.Start()
    end
end

-- Check if currently advertising
function Advertiser.IsAdvertising()
    return isAdvertising
end

-- Get queue size
function Advertiser.GetQueueSize()
    return #messageQueue
end

-- Update interval (while running)
function Advertiser.SetInterval(seconds)
    if seconds < MIN_INTERVAL then
        seconds = MIN_INTERVAL
    end

    addon.Config.Set("advertising.interval", seconds)

    -- Restart ticker if running
    if isAdvertising and tickerId then
        addon.Events.UnregisterTicker(tickerId)
        tickerId = addon.Events.RegisterTicker(seconds, AdvertiseTick)
    end
end

-- Initialize module
function Advertiser.Initialize()
    -- Queue processor runs every second to handle rate-limited messages
    addon.Events.RegisterTicker(1, ProcessQueue)
end
