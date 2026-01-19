local addonName, addon = ...

addon.Utils = {}
local Utils = addon.Utils

-- Format gold amount (copper) to readable string
function Utils.FormatMoney(copper)
    if not copper or copper == 0 then
        return "0g"
    end

    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local copperRem = copper % 100

    local result = ""
    if gold > 0 then
        result = gold .. "g"
    end
    if silver > 0 then
        result = result .. (result ~= "" and " " or "") .. silver .. "s"
    end
    if copperRem > 0 and gold == 0 then
        result = result .. (result ~= "" and " " or "") .. copperRem .. "c"
    end

    return result ~= "" and result or "0c"
end

-- Parse gold string to copper
function Utils.ParseMoney(str)
    if not str then return 0 end

    local copper = 0
    local gold = tonumber(str:match("(%d+)%s*g")) or 0
    local silver = tonumber(str:match("(%d+)%s*s")) or 0
    local cop = tonumber(str:match("(%d+)%s*c")) or 0

    -- Also handle plain number as gold
    if gold == 0 and silver == 0 and cop == 0 then
        gold = tonumber(str) or 0
    end

    copper = (gold * 10000) + (silver * 100) + cop
    return copper
end

-- Get current timestamp
function Utils.GetTimestamp()
    return time()
end

-- Get date string from timestamp
function Utils.GetDateString(timestamp)
    return date("%Y-%m-%d", timestamp)
end

-- Get today's date string
function Utils.GetTodayString()
    return Utils.GetDateString(Utils.GetTimestamp())
end

-- Print addon message
function Utils.Print(msg)
    print("|cff00ff00[OneStopShop]|r " .. tostring(msg))
end

-- Print error message
function Utils.PrintError(msg)
    print("|cffff0000[OneStopShop]|r " .. tostring(msg))
end

-- Check if player is in a group
function Utils.IsInGroup()
    return IsInGroup() or IsInRaid()
end

-- Get party/raid member count
function Utils.GetGroupSize()
    if IsInRaid() then
        return GetNumGroupMembers()
    elseif IsInGroup() then
        return GetNumGroupMembers()
    end
    return 0
end

-- Check if string contains pattern (case insensitive)
function Utils.ContainsIgnoreCase(str, pattern)
    if not str or not pattern then return false end
    return str:lower():find(pattern:lower(), 1, true) ~= nil
end

-- Trim whitespace from string
function Utils.Trim(str)
    if not str then return "" end
    return str:match("^%s*(.-)%s*$")
end

-- Split string by delimiter
function Utils.Split(str, delimiter)
    local result = {}
    if not str then return result end

    delimiter = delimiter or ","
    -- Escape pattern special characters in delimiter
    local escapedDelim = delimiter:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
    for match in (str .. delimiter):gmatch("(.-)" .. escapedDelim) do
        local trimmed = Utils.Trim(match)
        if trimmed ~= "" then
            table.insert(result, trimmed)
        end
    end
    return result
end

-- Deep copy a table
function Utils.DeepCopy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for key, value in pairs(orig) do
            copy[Utils.DeepCopy(key)] = Utils.DeepCopy(value)
        end
        setmetatable(copy, Utils.DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- Merge tables (shallow)
function Utils.MergeTables(target, source)
    for k, v in pairs(source) do
        if target[k] == nil then
            target[k] = v
        end
    end
    return target
end
