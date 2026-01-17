local addonName, addon = ...

addon.PartyManager = {}
local PartyManager = addon.PartyManager

local pendingKicks = {}
local autoKickTimers = {}

-- Invite a player
function PartyManager.Invite(name)
    if not name or name == "" then
        addon.Utils.PrintError("Invalid player name.")
        return false
    end

    -- Check if we can invite
    if addon.Utils.IsInGroup() then
        local isLeader = UnitIsGroupLeader("player")
        local isAssist = UnitIsGroupAssistant("player")
        if not isLeader and not isAssist then
            addon.Utils.PrintError("You must be the party leader or assistant to invite.")
            return false
        end
    end

    -- Send invite
    InviteUnit(name)

    -- Mark as invited in buyer detector
    addon.BuyerDetector.MarkInvited(name)

    -- Send whisper if configured
    if addon.Config.Get("party.whisperOnInvite") then
        local whisperMsg = addon.Config.Get("party.inviteWhisper") or "Invite sent!"
        SendChatMessage(whisperMsg, "WHISPER", nil, name)
    end

    addon.Utils.Print("Invited " .. name)
    addon.Events.Fire("OSS_PLAYER_INVITED", name)

    return true
end

-- Kick a player (or uninvite)
function PartyManager.Kick(name)
    if not name or name == "" then return false end

    if addon.Utils.IsInGroup() then
        local isLeader = UnitIsGroupLeader("player")
        if not isLeader then
            addon.Utils.PrintError("You must be the party leader to kick.")
            return false
        end
        UninviteUnit(name)
        addon.Utils.Print("Removed " .. name .. " from group.")
        addon.Events.Fire("OSS_PLAYER_KICKED", name)
        return true
    end

    return false
end

-- Schedule auto-kick after delay
function PartyManager.ScheduleAutoKick(name, delay)
    if not addon.Config.Get("party.autoKick") then return end

    delay = delay or addon.Config.Get("party.autoKickDelay") or 10

    -- Cancel existing timer for this player
    if autoKickTimers[name] then
        autoKickTimers[name]:Cancel()
    end

    addon.Utils.Print("Will remove " .. name .. " in " .. delay .. " seconds.")

    -- Create timer
    autoKickTimers[name] = C_Timer.NewTimer(delay, function()
        PartyManager.Kick(name)
        autoKickTimers[name] = nil
    end)
end

-- Cancel auto-kick for a player
function PartyManager.CancelAutoKick(name)
    if autoKickTimers[name] then
        autoKickTimers[name]:Cancel()
        autoKickTimers[name] = nil
        addon.Utils.Print("Cancelled auto-kick for " .. name)
    end
end

-- Get party members (excluding self)
function PartyManager.GetPartyMembers()
    local members = {}

    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local name = GetRaidRosterInfo(i)
            if name and name ~= UnitName("player") then
                table.insert(members, name)
            end
        end
    elseif IsInGroup() then
        for i = 1, GetNumGroupMembers() - 1 do
            local unit = "party" .. i
            local name = UnitName(unit)
            if name then
                table.insert(members, name)
            end
        end
    end

    return members
end

-- Check if summon requirements are met (2+ party members for warlock)
function PartyManager.CanSummon()
    if addon.playerClass ~= "WARLOCK" then
        return false, "Only Warlocks can summon."
    end

    local groupSize = addon.Utils.GetGroupSize()
    if groupSize < 2 then
        return false, "Need at least 2 party members to summon."
    end

    return true, nil
end

-- Handle party member joined
local function OnGroupRosterUpdate()
    addon.Events.Fire("OSS_GROUP_CHANGED")
end

-- Handle invite acceptance/decline
local function OnPartyInviteRequest(name)
    -- Could add auto-accept logic here if wanted
    addon.Events.Fire("OSS_INVITE_RECEIVED", name)
end

-- Initialize module
function PartyManager.Initialize()
    addon.Events.Register("GROUP_ROSTER_UPDATE", OnGroupRosterUpdate)
    addon.Events.Register("PARTY_INVITE_REQUEST", OnPartyInviteRequest)

    -- Listen for successful spellcast to trigger auto-kick
    addon.Events.Register("UNIT_SPELLCAST_SUCCEEDED", function(unit, _, spellId)
        if unit ~= "player" then return end
        if not addon.Config.Get("party.autoKick") then return end

        -- Check if this was a portal or summon spell
        local spellName = GetSpellInfo(spellId)
        if not spellName then return end

        local isService = spellName:lower():find("portal") or
            spellName:lower():find("ritual of summoning")

        if isService then
            -- Schedule auto-kick for all party members
            local members = PartyManager.GetPartyMembers()
            for _, name in ipairs(members) do
                PartyManager.ScheduleAutoKick(name)
            end
        end
    end)
end
