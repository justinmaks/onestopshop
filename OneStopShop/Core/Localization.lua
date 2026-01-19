local addonName, addon = ...

-- Localization table
addon.L = {}
local L = addon.L

-- Default locale (English)
local defaultLocale = {
    -- General
    ["ADDON_LOADED"] = "v%s loaded. Type /oss for commands. Made by Stin.",
    ["ADDON_LOADED_FIRST_RUN"] = "v%s loaded. Welcome! Type /oss to get started. Made by Stin.",
    ["CLASS_WARNING"] = "Note: This addon is designed for Mages and Warlocks.",
    ["UNKNOWN_COMMAND"] = "Unknown command: %s",
    ["TYPE_HELP"] = "Type /oss help for available commands.",

    -- Commands
    ["CMD_HELP_HEADER"] = "Commands:",
    ["CMD_OSS"] = "  /oss - Toggle main window",
    ["CMD_CONFIG"] = "  /oss config - Open settings",
    ["CMD_START"] = "  /oss start - Start advertising",
    ["CMD_STOP"] = "  /oss stop - Stop advertising",
    ["CMD_STATS"] = "  /oss stats - Show statistics",
    ["CMD_CLEAR"] = "  /oss clear - Clear buyer queue",
    ["CMD_LOG"] = "  /oss log - Log a service manually",
    ["CMD_VERSION"] = "  /oss version - Show version info",
    ["CMD_HELP"] = "  /oss help - Show this help",

    -- Version info
    ["VERSION_INFO"] = "OneStopShop v%s",
    ["VERSION_AUTHOR"] = "Author: Stin",
    ["VERSION_CLIENT"] = "WoW Client: %s",

    -- Advertising
    ["ADVERTISING"] = "Advertising",
    ["ADV_STARTED"] = "Started advertising every %d seconds.",
    ["ADV_STOPPED"] = "Stopped advertising.",
    ["ADV_ALREADY_RUNNING"] = "Already advertising.",
    ["ADV_NOT_RUNNING"] = "Not currently advertising.",
    ["ADV_CLASS_ERROR"] = "Only Mages and Warlocks can advertise services.",
    ["ADV_POSTED"] = "Posted to trade chat.",
    ["ADV_NO_CHANNEL"] = "Trade channel not found. Are you in a city?",
    ["ADV_STATUS_RUNNING"] = "|cff00ff00Running|r",
    ["ADV_STATUS_STOPPED"] = "|cffff0000Stopped|r",

    -- Buyer Detection
    ["POTENTIAL_BUYERS"] = "Potential Buyers",
    ["NO_BUYERS"] = "No buyers detected",
    ["BUYER_DETECTED"] = "Potential buyer detected: %s - \"%s\"",
    ["BUYER_QUEUE_CLEARED"] = "Buyer queue cleared.",

    -- Party
    ["INVITED"] = "Invited %s",
    ["INVITE_ERROR_NAME"] = "Invalid player name.",
    ["INVITE_ERROR_LEADER"] = "You must be the party leader or assistant to invite.",
    ["KICK_ERROR_LEADER"] = "You must be the party leader to kick.",
    ["REMOVED_FROM_GROUP"] = "Removed %s from group.",
    ["AUTO_KICK_SCHEDULED"] = "Will remove %s in %d seconds.",
    ["AUTO_KICK_CANCELLED"] = "Cancelled auto-kick for %s",

    -- Spells
    ["QUICK_CAST"] = "Quick Cast",
    ["NO_PORTALS"] = "No portal spells known",
    ["LEARN_SUMMON"] = "Learn Ritual of Summoning (level 20)",
    ["READY_TO_SUMMON"] = "|cff00ff00Ready to summon|r",
    ["CLASS_NOT_SUPPORTED"] = "Only Mages and Warlocks can use this addon",

    -- Statistics
    ["STATISTICS"] = "Statistics",
    ["SESSION"] = "Session: %d services, %s",
    ["TODAY"] = "Today: %d services, %s",
    ["ALL_TIME"] = "All-Time: %d services, %s",

    -- Service Logging
    ["SERVICE_LOGGED"] = "Service logged: %s to %s for %s",
    ["LOG_SERVICE_TITLE"] = "Log completed service?",

    -- Config
    ["SETTINGS_TITLE"] = "OneStopShop Settings",
    ["SETTINGS_SAVED"] = "Settings saved.",
    ["SETTINGS_RESET"] = "Settings reset to defaults.",
    ["RESET_CONFIRM"] = "Reset all settings to defaults?",

    -- Config Sections
    ["CFG_ADVERTISING"] = "|cff00ff00Advertising|r",
    ["CFG_PRICES"] = "|cff00ff00Prices (gold)|r",
    ["CFG_DETECTION"] = "|cff00ff00Buyer Detection|r",
    ["CFG_PARTY"] = "|cff00ff00Party Management|r",

    -- Config Labels
    ["CFG_INTERVAL"] = "Interval (sec):",
    ["CFG_MAGE_AD"] = "Mage Ad:",
    ["CFG_WARLOCK_AD"] = "Warlock Ad:",
    ["CFG_PORTAL_PRICE"] = "Portal:",
    ["CFG_SUMMON_PRICE"] = "Summon:",
    ["CFG_DETECTION_ENABLED"] = "Enable detection",
    ["CFG_SOUND_ENABLED"] = "Play sound on detection",
    ["CFG_AUTO_KICK"] = "Auto-kick after service",
    ["CFG_KICK_DELAY"] = "Kick delay (sec):",
    ["CFG_WHISPER_INVITE"] = "Whisper on invite",
    ["CFG_INVITE_MSG"] = "Invite msg:",

    -- Config Tooltips
    ["TIP_INTERVAL"] = "Time in seconds between trade chat posts.\nMinimum: 15 seconds to avoid spam.",
    ["TIP_MAGE_AD"] = "Message template for mage advertisements.\nUse {destinations} for portal list and {price} for price.",
    ["TIP_WARLOCK_AD"] = "Message template for warlock advertisements.\nUse {price} for summon price.",
    ["TIP_PORTAL_PRICE"] = "Default price for portal services in gold.",
    ["TIP_SUMMON_PRICE"] = "Default price for summon services in gold.",
    ["TIP_DETECTION_ENABLED"] = "Monitor chat for players looking for portals/summons.",
    ["TIP_SOUND_ENABLED"] = "Play a sound when a potential buyer is detected.",
    ["TIP_AUTO_KICK"] = "Automatically remove party members after casting\na portal or summon spell.",
    ["TIP_KICK_DELAY"] = "Seconds to wait after casting before removing\nparty members.",
    ["TIP_WHISPER_INVITE"] = "Send a whisper message when inviting a player.",
    ["TIP_INVITE_MSG"] = "Message to send when inviting a player.",

    -- Welcome/First Run
    ["WELCOME_TITLE"] = "Welcome to OneStopShop!",
    ["WELCOME_LINE1"] = "This addon helps Mages and Warlocks sell portals and summons.",
    ["WELCOME_LINE2"] = "Quick Start:",
    ["WELCOME_LINE3"] = "1. Open settings with /oss config",
    ["WELCOME_LINE4"] = "2. Set your prices and ad message",
    ["WELCOME_LINE5"] = "3. Click 'Start' to begin advertising",
    ["WELCOME_CLOSE"] = "Got it!",

    -- Changelog
    ["CHANGELOG_TITLE"] = "OneStopShop - What's New",
    ["CHANGELOG_UPDATED"] = "Updated to v%s",

    -- Context Menu
    ["MENU_WHISPER"] = "Whisper",
    ["MENU_INVITE"] = "Invite to Group",
    ["MENU_IGNORE"] = "Ignore Player",
    ["MENU_REMOVE"] = "Remove from Queue",
    ["MENU_WHO"] = "Who",

    -- Buttons
    ["BTN_START"] = "Start",
    ["BTN_STOP"] = "Stop",
    ["BTN_CONFIG"] = "Config",
    ["BTN_LOG_SERVICE"] = "Log Service",
    ["BTN_SAVE"] = "Save",
    ["BTN_RESET"] = "Reset",
    ["BTN_INVITE"] = "Invite",
    ["BTN_SENT"] = "Sent",
    ["BTN_PORTAL"] = "Portal",
    ["BTN_SUMMON"] = "Summon",
    ["BTN_CANCEL"] = "Cancel",
    ["BTN_YES"] = "Yes",
    ["BTN_NO"] = "No",

    -- Credits
    ["MADE_BY"] = "Made by Stin",
}

-- Set up metatable to return key if translation missing
setmetatable(L, {
    __index = function(t, key)
        return defaultLocale[key] or key
    end
})

-- Copy defaults to L
for k, v in pairs(defaultLocale) do
    L[k] = v
end

-- Function to get localized string with formatting
function addon.GetLocale(key, ...)
    local str = L[key] or key
    if select("#", ...) > 0 then
        return string.format(str, ...)
    end
    return str
end
