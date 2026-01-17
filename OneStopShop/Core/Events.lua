local addonName, addon = ...

addon.Events = {}
local Events = addon.Events

-- Event handlers registered by modules
local handlers = {}

-- Main event frame
local eventFrame = CreateFrame("Frame")

-- Register an event handler
function Events.Register(event, callback)
    if not handlers[event] then
        handlers[event] = {}
        eventFrame:RegisterEvent(event)
    end
    table.insert(handlers[event], callback)
end

-- Unregister a specific callback for an event
function Events.Unregister(event, callback)
    if not handlers[event] then return end

    for i, cb in ipairs(handlers[event]) do
        if cb == callback then
            table.remove(handlers[event], i)
            break
        end
    end

    if #handlers[event] == 0 then
        handlers[event] = nil
        eventFrame:UnregisterEvent(event)
    end
end

-- Unregister all handlers for an event
function Events.UnregisterAll(event)
    if handlers[event] then
        handlers[event] = nil
        eventFrame:UnregisterEvent(event)
    end
end

-- Fire a custom event (for inter-module communication)
function Events.Fire(event, ...)
    if handlers[event] then
        for _, callback in ipairs(handlers[event]) do
            callback(...)
        end
    end
end

-- Event dispatcher
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if handlers[event] then
        for _, callback in ipairs(handlers[event]) do
            local success, err = pcall(callback, ...)
            if not success then
                addon.Utils.PrintError("Error in " .. event .. " handler: " .. tostring(err))
            end
        end
    end
end)

-- Update ticker for timed operations
local tickerHandlers = {}
local tickerFrame = CreateFrame("Frame")
local elapsed = 0

function Events.RegisterTicker(interval, callback)
    local id = tostring(callback)
    tickerHandlers[id] = {
        interval = interval,
        callback = callback,
        elapsed = 0,
    }
    tickerFrame:Show()
    return id
end

function Events.UnregisterTicker(id)
    tickerHandlers[id] = nil
    if next(tickerHandlers) == nil then
        tickerFrame:Hide()
    end
end

tickerFrame:SetScript("OnUpdate", function(self, delta)
    for id, ticker in pairs(tickerHandlers) do
        ticker.elapsed = ticker.elapsed + delta
        if ticker.elapsed >= ticker.interval then
            ticker.elapsed = 0
            local success, err = pcall(ticker.callback)
            if not success then
                addon.Utils.PrintError("Error in ticker: " .. tostring(err))
            end
        end
    end
end)
tickerFrame:Hide()
