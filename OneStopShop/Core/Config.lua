local addonName, addon = ...

addon.Config = {}
local Config = addon.Config

-- Default configuration
local DEFAULTS = {
    -- Advertising settings
    advertising = {
        enabled = false,
        interval = 60, -- seconds between posts (minimum 15)
        channel = "TRADE", -- TRADE, GENERAL, or specific channel number
        mageTemplate = "WTS Portals: {destinations} - {price}g each! PST",
        warlockTemplate = "WTS Summons - {price}g! PST",
    },

    -- Price settings (in gold)
    prices = {
        portal = 2,
        summon = 3,
        food = 1,
        water = 1,
    },

    -- Portal destinations for mages
    destinations = {
        -- Alliance
        stormwind = true,
        ironforge = true,
        darnassus = true,
        exodar = false, -- TBC+
        theramore = false,
        -- Horde
        orgrimmar = true,
        undercity = true,
        thunderbluff = true,
        silvermoon = false, -- TBC+
        stonard = false,
        -- Neutral
        shattrath = false, -- TBC+
        dalaran = false, -- WotLK+
    },

    -- Buyer detection settings
    detection = {
        enabled = true,
        soundEnabled = true,
        soundId = 8959, -- RAID_WARNING sound
        patterns = {
            "wtb.*portal",
            "wtb.*port",
            "wtb.*summon",
            "lf.*portal",
            "lf.*port",
            "lf.*summon",
            "lf.*mage",
            "lf.*warlock",
            "lf.*lock",
            "looking for.*portal",
            "looking for.*mage",
            "looking for.*summon",
            "need.*portal",
            "need.*port",
            "need.*summon",
            "anyone.*portal",
            "anyone.*summon",
        },
    },

    -- Party management settings
    party = {
        autoKick = false,
        autoKickDelay = 10, -- seconds after casting
        whisperOnInvite = true,
        inviteWhisper = "Invite sent! Please accept.",
    },

    -- UI settings
    ui = {
        mainFramePosition = nil, -- saved position
        minimapButton = true,
        minimapPosition = 45, -- degrees
    },
}

-- Initialize database
function Config.Initialize()
    if not OneStopShopDB then
        OneStopShopDB = {}
    end

    -- Merge defaults with saved data
    Config.DB = addon.Utils.DeepCopy(DEFAULTS)
    Config.MergeDeep(Config.DB, OneStopShopDB)

    -- Initialize statistics if not present
    if not Config.DB.statistics then
        Config.DB.statistics = {
            session = { services = 0, gold = 0 },
            today = { date = addon.Utils.GetTodayString(), services = 0, gold = 0 },
            allTime = { services = 0, gold = 0 },
            history = {},
        }
    end

    -- Initialize buyer queue
    if not Config.DB.buyerQueue then
        Config.DB.buyerQueue = {}
    end
end

-- Deep merge tables
function Config.MergeDeep(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" and type(target[k]) == "table" then
            Config.MergeDeep(target[k], v)
        else
            target[k] = v
        end
    end
end

-- Save configuration
function Config.Save()
    OneStopShopDB = addon.Utils.DeepCopy(Config.DB)
end

-- Get a config value by path (e.g., "advertising.interval")
function Config.Get(path)
    local parts = addon.Utils.Split(path, ".")
    local current = Config.DB

    for _, part in ipairs(parts) do
        if type(current) ~= "table" then
            return nil
        end
        current = current[part]
    end

    return current
end

-- Set a config value by path
function Config.Set(path, value)
    local parts = addon.Utils.Split(path, ".")
    local current = Config.DB

    for i = 1, #parts - 1 do
        local part = parts[i]
        if type(current[part]) ~= "table" then
            current[part] = {}
        end
        current = current[part]
    end

    current[parts[#parts]] = value
    Config.Save()
end

-- Reset to defaults
function Config.Reset()
    Config.DB = addon.Utils.DeepCopy(DEFAULTS)
    Config.Save()
end

-- Get formatted destinations string for mage advertisements
function Config.GetDestinationsString()
    local dests = {}
    local destConfig = Config.DB.destinations

    local destNames = {
        stormwind = "SW",
        ironforge = "IF",
        darnassus = "Darn",
        exodar = "Exo",
        theramore = "Thera",
        orgrimmar = "Org",
        undercity = "UC",
        thunderbluff = "TB",
        silvermoon = "SMC",
        stonard = "Stonard",
        shattrath = "Shatt",
        dalaran = "Dala",
    }

    for dest, enabled in pairs(destConfig) do
        if enabled and destNames[dest] then
            table.insert(dests, destNames[dest])
        end
    end

    return table.concat(dests, "/")
end
