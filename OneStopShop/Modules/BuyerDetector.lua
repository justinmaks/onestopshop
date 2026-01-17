local addonName, addon = ...

addon.BuyerDetector = {}
local BuyerDetector = addon.BuyerDetector

local isEnabled = true
local buyerQueue = {}
local playerName = nil

-- Check if message matches any detection pattern
local function MatchesPattern(message)
    local patterns = addon.Config.Get("detection.patterns")
    if not patterns then return false end

    local lowerMsg = message:lower()

    for _, pattern in ipairs(patterns) do
        if lowerMsg:find(pattern) then
            return true
        end
    end

    return false
end

-- Add buyer to queue
local function AddBuyer(name, message, channel)
    -- Check if already in queue
    for _, buyer in ipairs(buyerQueue) do
        if buyer.name == name then
            buyer.message = message
            buyer.time = addon.Utils.GetTimestamp()
            buyer.channel = channel
            return
        end
    end

    -- Add new buyer
    local buyer = {
        name = name,
        message = message,
        time = addon.Utils.GetTimestamp(),
        channel = channel,
        invited = false,
    }

    table.insert(buyerQueue, 1, buyer) -- Add to front

    -- Keep queue size reasonable
    while #buyerQueue > 20 do
        table.remove(buyerQueue)
    end

    -- Play notification sound
    if addon.Config.Get("detection.soundEnabled") then
        local soundId = addon.Config.Get("detection.soundId") or 8959
        PlaySound(soundId)
    end

    addon.Utils.Print("Potential buyer detected: " .. name .. " - \"" .. message .. "\"")
    addon.Events.Fire("OSS_BUYER_DETECTED", buyer)
end

-- Handle chat message
local function OnChatMessage(message, sender, _, channelName, _, _, _, channelNumber, _, _, _, guid)
    if not isEnabled then return end
    if not message or not sender then return end

    -- Ignore own messages
    if sender == playerName then return end

    -- Remove realm from sender name if present
    local senderName = sender:match("([^-]+)") or sender

    -- Check if message matches patterns
    if MatchesPattern(message) then
        local channel = channelName or ("Channel " .. (channelNumber or "?"))
        AddBuyer(senderName, message, channel)
    end
end

-- Handle whisper
local function OnWhisper(message, sender)
    if not isEnabled then return end
    if not message or not sender then return end

    local senderName = sender:match("([^-]+)") or sender

    if MatchesPattern(message) then
        AddBuyer(senderName, message, "Whisper")
    end
end

-- Get buyer queue
function BuyerDetector.GetQueue()
    return buyerQueue
end

-- Clear buyer queue
function BuyerDetector.ClearQueue()
    buyerQueue = {}
    addon.Events.Fire("OSS_BUYER_QUEUE_CLEARED")
end

-- Remove buyer from queue
function BuyerDetector.RemoveBuyer(name)
    for i, buyer in ipairs(buyerQueue) do
        if buyer.name == name then
            table.remove(buyerQueue, i)
            addon.Events.Fire("OSS_BUYER_REMOVED", name)
            return true
        end
    end
    return false
end

-- Mark buyer as invited
function BuyerDetector.MarkInvited(name)
    for _, buyer in ipairs(buyerQueue) do
        if buyer.name == name then
            buyer.invited = true
            addon.Events.Fire("OSS_BUYER_INVITED", buyer)
            return true
        end
    end
    return false
end

-- Enable/disable detection
function BuyerDetector.SetEnabled(enabled)
    isEnabled = enabled
    addon.Config.Set("detection.enabled", enabled)
end

-- Check if enabled
function BuyerDetector.IsEnabled()
    return isEnabled
end

-- Add custom pattern
function BuyerDetector.AddPattern(pattern)
    local patterns = addon.Config.Get("detection.patterns") or {}
    table.insert(patterns, pattern:lower())
    addon.Config.Set("detection.patterns", patterns)
end

-- Remove pattern
function BuyerDetector.RemovePattern(pattern)
    local patterns = addon.Config.Get("detection.patterns") or {}
    for i, p in ipairs(patterns) do
        if p == pattern:lower() then
            table.remove(patterns, i)
            addon.Config.Set("detection.patterns", patterns)
            return true
        end
    end
    return false
end

-- Initialize module
function BuyerDetector.Initialize()
    playerName = UnitName("player")
    isEnabled = addon.Config.Get("detection.enabled") ~= false

    -- Register for chat events
    addon.Events.Register("CHAT_MSG_CHANNEL", OnChatMessage)
    addon.Events.Register("CHAT_MSG_WHISPER", OnWhisper)
    addon.Events.Register("CHAT_MSG_SAY", function(msg, sender)
        OnChatMessage(msg, sender, nil, "Say")
    end)
    addon.Events.Register("CHAT_MSG_YELL", function(msg, sender)
        OnChatMessage(msg, sender, nil, "Yell")
    end)
end
