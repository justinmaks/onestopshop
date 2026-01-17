local addonName, addon = ...

addon.ServiceTracker = {}
local ServiceTracker = addon.ServiceTracker

-- Service types
ServiceTracker.SERVICE_PORTAL = "portal"
ServiceTracker.SERVICE_SUMMON = "summon"
ServiceTracker.SERVICE_FOOD = "food"
ServiceTracker.SERVICE_WATER = "water"

-- Log a completed service
function ServiceTracker.LogService(serviceType, buyerName, destination, priceCopper)
    local Config = addon.Config

    -- Create history entry
    local entry = {
        type = serviceType,
        buyer = buyerName or "Unknown",
        destination = destination,
        price = priceCopper or 0,
        timestamp = addon.Utils.GetTimestamp(),
    }

    -- Update statistics
    local stats = Config.DB.statistics

    -- Check if we need to reset daily stats
    local today = addon.Utils.GetTodayString()
    if stats.today.date ~= today then
        stats.today = { date = today, services = 0, gold = 0 }
    end

    -- Increment counters
    stats.session.services = stats.session.services + 1
    stats.session.gold = stats.session.gold + priceCopper

    stats.today.services = stats.today.services + 1
    stats.today.gold = stats.today.gold + priceCopper

    stats.allTime.services = stats.allTime.services + 1
    stats.allTime.gold = stats.allTime.gold + priceCopper

    -- Add to history
    table.insert(stats.history, 1, entry)

    -- Trim history to last 100 entries
    while #stats.history > 100 do
        table.remove(stats.history)
    end

    Config.Save()

    addon.Utils.Print(string.format("Service logged: %s to %s for %s",
        serviceType,
        buyerName or "Unknown",
        addon.Utils.FormatMoney(priceCopper)))

    addon.Events.Fire("OSS_SERVICE_LOGGED", entry)

    return entry
end

-- Get session statistics
function ServiceTracker.GetSessionStats()
    local stats = addon.Config.DB.statistics.session
    return {
        services = stats.services,
        gold = stats.gold,
        goldFormatted = addon.Utils.FormatMoney(stats.gold),
    }
end

-- Get today's statistics
function ServiceTracker.GetTodayStats()
    local stats = addon.Config.DB.statistics.today
    local today = addon.Utils.GetTodayString()

    -- Reset if new day
    if stats.date ~= today then
        return { services = 0, gold = 0, goldFormatted = "0g" }
    end

    return {
        services = stats.services,
        gold = stats.gold,
        goldFormatted = addon.Utils.FormatMoney(stats.gold),
    }
end

-- Get all-time statistics
function ServiceTracker.GetAllTimeStats()
    local stats = addon.Config.DB.statistics.allTime
    return {
        services = stats.services,
        gold = stats.gold,
        goldFormatted = addon.Utils.FormatMoney(stats.gold),
    }
end

-- Get recent history
function ServiceTracker.GetHistory(limit)
    limit = limit or 10
    local history = addon.Config.DB.statistics.history or {}
    local result = {}

    for i = 1, math.min(limit, #history) do
        local entry = history[i]
        table.insert(result, {
            type = entry.type,
            buyer = entry.buyer,
            destination = entry.destination,
            price = entry.price,
            priceFormatted = addon.Utils.FormatMoney(entry.price),
            timestamp = entry.timestamp,
            timeAgo = ServiceTracker.GetTimeAgo(entry.timestamp),
        })
    end

    return result
end

-- Get human-readable time ago string
function ServiceTracker.GetTimeAgo(timestamp)
    local diff = addon.Utils.GetTimestamp() - timestamp

    if diff < 60 then
        return "just now"
    elseif diff < 3600 then
        local mins = math.floor(diff / 60)
        return mins .. " min ago"
    elseif diff < 86400 then
        local hours = math.floor(diff / 3600)
        return hours .. " hr ago"
    else
        local days = math.floor(diff / 86400)
        return days .. " day" .. (days > 1 and "s" or "") .. " ago"
    end
end

-- Reset session statistics
function ServiceTracker.ResetSession()
    addon.Config.DB.statistics.session = { services = 0, gold = 0 }
    addon.Config.Save()
    addon.Events.Fire("OSS_SESSION_RESET")
end

-- Print statistics to chat (for export)
function ServiceTracker.PrintStats()
    local session = ServiceTracker.GetSessionStats()
    local today = ServiceTracker.GetTodayStats()
    local allTime = ServiceTracker.GetAllTimeStats()

    addon.Utils.Print("=== OneStopShop Statistics ===")
    addon.Utils.Print(string.format("Session: %d services, %s earned",
        session.services, session.goldFormatted))
    addon.Utils.Print(string.format("Today: %d services, %s earned",
        today.services, today.goldFormatted))
    addon.Utils.Print(string.format("All-Time: %d services, %s earned",
        allTime.services, allTime.goldFormatted))
end

-- Clear all history
function ServiceTracker.ClearHistory()
    addon.Config.DB.statistics.history = {}
    addon.Config.Save()
    addon.Utils.Print("History cleared.")
end

-- Initialize module
function ServiceTracker.Initialize()
    -- Reset session stats on login
    ServiceTracker.ResetSession()

    -- Check for day rollover
    local stats = addon.Config.DB.statistics
    local today = addon.Utils.GetTodayString()
    if stats.today.date ~= today then
        stats.today = { date = today, services = 0, gold = 0 }
        addon.Config.Save()
    end
end
