local addonName, addon = ...

addon.SpellCaster = {}
local SpellCaster = addon.SpellCaster

-- Portal spell IDs for Classic/TBC/WotLK
local PORTAL_SPELLS = {
    -- Alliance
    { name = "Portal: Stormwind", id = 10059, dest = "stormwind", faction = "Alliance" },
    { name = "Portal: Ironforge", id = 11416, dest = "ironforge", faction = "Alliance" },
    { name = "Portal: Darnassus", id = 11419, dest = "darnassus", faction = "Alliance" },
    { name = "Portal: Exodar", id = 32266, dest = "exodar", faction = "Alliance" }, -- TBC
    { name = "Portal: Theramore", id = 49360, dest = "theramore", faction = "Alliance" }, -- WotLK

    -- Horde
    { name = "Portal: Orgrimmar", id = 11417, dest = "orgrimmar", faction = "Horde" },
    { name = "Portal: Undercity", id = 11418, dest = "undercity", faction = "Horde" },
    { name = "Portal: Thunder Bluff", id = 11420, dest = "thunderbluff", faction = "Horde" },
    { name = "Portal: Silvermoon", id = 32267, dest = "silvermoon", faction = "Horde" }, -- TBC
    { name = "Portal: Stonard", id = 49361, dest = "stonard", faction = "Horde" }, -- WotLK

    -- Neutral
    { name = "Portal: Shattrath", id = 33691, dest = "shattrath", faction = "Both" }, -- TBC (Alliance)
    { name = "Portal: Shattrath", id = 35717, dest = "shattrath", faction = "Both" }, -- TBC (Horde)
    { name = "Portal: Dalaran", id = 53142, dest = "dalaran", faction = "Both" }, -- WotLK
}

-- Warlock summon spell
local SUMMON_SPELL = { name = "Ritual of Summoning", id = 698 }

-- Cached known spells
local knownPortals = {}
local knowsSummon = false

-- Check if player knows a spell
local function IsSpellKnown(spellId)
    return IsSpellKnown(spellId) or IsPlayerSpell(spellId)
end

-- Scan for known portal spells
function SpellCaster.ScanSpells()
    knownPortals = {}
    knowsSummon = false

    local playerFaction = UnitFactionGroup("player")

    if addon.playerClass == "MAGE" then
        for _, spell in ipairs(PORTAL_SPELLS) do
            if IsSpellKnown(spell.id) then
                if spell.faction == "Both" or spell.faction == playerFaction then
                    table.insert(knownPortals, {
                        name = spell.name,
                        id = spell.id,
                        destination = spell.dest,
                    })
                end
            end
        end
    elseif addon.playerClass == "WARLOCK" then
        if IsSpellKnown(SUMMON_SPELL.id) then
            knowsSummon = true
        end
    end

    addon.Events.Fire("OSS_SPELLS_SCANNED")
end

-- Get known portals
function SpellCaster.GetKnownPortals()
    return knownPortals
end

-- Check if player knows summon
function SpellCaster.KnowsSummon()
    return knowsSummon
end

-- Get spell info (cooldown, usable, etc.)
function SpellCaster.GetSpellInfo(spellId)
    local start, duration, enabled = GetSpellCooldown(spellId)
    local isUsable, notEnoughMana = IsUsableSpell(spellId)
    local spellName = GetSpellInfo(spellId)

    local onCooldown = (start and start > 0 and duration and duration > 0)
    local cooldownRemaining = 0
    if onCooldown then
        cooldownRemaining = (start + duration) - GetTime()
    end

    return {
        name = spellName,
        id = spellId,
        isUsable = isUsable,
        notEnoughMana = notEnoughMana,
        onCooldown = onCooldown,
        cooldownRemaining = cooldownRemaining,
    }
end

-- Check if player has portal reagents (Rune of Portals)
function SpellCaster.HasPortalReagent()
    -- Rune of Portals item ID
    local RUNE_OF_PORTALS = 17032
    local count = GetItemCount(RUNE_OF_PORTALS)
    return count > 0, count
end

-- Check if player has soul shards (for summon)
function SpellCaster.HasSoulShard()
    -- Soul Shard item ID
    local SOUL_SHARD = 6265
    local count = GetItemCount(SOUL_SHARD)
    return count > 0, count
end

-- Get destination display name
function SpellCaster.GetDestinationName(dest)
    local names = {
        stormwind = "Stormwind",
        ironforge = "Ironforge",
        darnassus = "Darnassus",
        exodar = "Exodar",
        theramore = "Theramore",
        orgrimmar = "Orgrimmar",
        undercity = "Undercity",
        thunderbluff = "Thunder Bluff",
        silvermoon = "Silvermoon",
        stonard = "Stonard",
        shattrath = "Shattrath",
        dalaran = "Dalaran",
    }
    return names[dest] or dest
end

-- Create a secure spell button (must be done at load time, not in combat)
function SpellCaster.CreateSpellButton(parent, spellId, width, height)
    local btn = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate")
    btn:SetSize(width or 100, height or 25)

    btn:SetAttribute("type", "spell")
    btn:SetAttribute("spell", spellId)

    -- Visual setup
    btn:SetNormalFontObject("GameFontNormal")
    btn:SetHighlightFontObject("GameFontHighlight")

    local spellName = GetSpellInfo(spellId)
    btn:SetText(spellName or "Unknown")

    -- Background
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    btn.bg = bg

    -- Highlight
    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.2)

    -- Update state on show
    btn:SetScript("OnShow", function(self)
        SpellCaster.UpdateButtonState(self, spellId)
    end)

    btn.spellId = spellId

    return btn
end

-- Update button visual state based on spell availability
function SpellCaster.UpdateButtonState(button, spellId)
    local info = SpellCaster.GetSpellInfo(spellId)

    if not info.isUsable or info.onCooldown then
        button:SetAlpha(0.5)
        if button.bg then
            button.bg:SetColorTexture(0.3, 0.1, 0.1, 0.8)
        end
    else
        button:SetAlpha(1.0)
        if button.bg then
            button.bg:SetColorTexture(0.1, 0.3, 0.1, 0.8)
        end
    end
end

-- Initialize module
function SpellCaster.Initialize()
    -- Scan spells after player info is available
    addon.Events.Register("PLAYER_LOGIN", function()
        SpellCaster.ScanSpells()
    end)

    -- Rescan on spell learned (SPELLS_CHANGED works in Classic/TBC/Wrath)
    addon.Events.Register("SPELLS_CHANGED", function()
        SpellCaster.ScanSpells()
    end)

    -- Initial scan if already logged in
    if UnitName("player") then
        SpellCaster.ScanSpells()
    end
end
