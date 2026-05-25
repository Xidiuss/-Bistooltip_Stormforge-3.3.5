-- ============================================================
-- TokenData.lua - Tier token BIS proxy (TokenLinks.lua)
-- ============================================================

Bistooltip_token_registry = Bistooltip_token_registry or {}
Bistooltip_token_meta_cache = Bistooltip_token_meta_cache or {}

local function GearInBislist(className, specName, gearId)
    local bislists = _G.Bistooltip_bislists
    if not bislists or not bislists[className] or not bislists[className][specName] then
        return false
    end
    local phases = _G.Bistooltip_wowtbc_phases
    if phases then
        for _, phase in ipairs(phases) do
            local phaseData = bislists[className][specName][phase]
            if type(phaseData) == "table" then
                for _, slotData in ipairs(phaseData) do
                    if type(slotData) == "table" then
                        local i = 1
                        while slotData[i] do
                            if slotData[i] == gearId then
                                return true
                            end
                            i = i + 1
                        end
                    end
                end
            end
        end
    else
        for _, phaseData in pairs(bislists[className][specName]) do
            if type(phaseData) == "table" then
                for _, slotData in ipairs(phaseData) do
                    if type(slotData) == "table" then
                        local i = 1
                        while slotData[i] do
                            if slotData[i] == gearId then
                                return true
                            end
                            i = i + 1
                        end
                    end
                end
            end
        end
    end
    return false
end

function Bistooltip_BuildTokenRegistry()
    wipe(Bistooltip_token_registry)
    wipe(Bistooltip_token_meta_cache)

    if not Bistooltip_token_data then return end

    for tokenId, data in pairs(Bistooltip_token_data) do
        Bistooltip_token_registry[tokenId] = {
            tier = data.tier,
            tierNum = tonumber((data.tier or ""):match("T(%d+)")) or nil,
            slot = data.slot,
        }
    end
end

function Bistooltip_ClearTokenMetaCache(itemId)
    if itemId then
        Bistooltip_token_meta_cache[itemId] = nil
    else
        wipe(Bistooltip_token_meta_cache)
    end
end

function Bistooltip_IsTierToken(itemId)
    return itemId and Bistooltip_token_data and Bistooltip_token_data[itemId] ~= nil
end

function Bistooltip_GetTokenMeta(itemId)
    if not Bistooltip_IsTierToken(itemId) then
        return nil
    end
    local cached = Bistooltip_token_meta_cache[itemId]
    if cached then
        return cached
    end
    local data = Bistooltip_token_data[itemId]
    local meta = {
        tier = data.tier,
        tierNum = tonumber((data.tier or ""):match("T(%d+)")),
        slot = data.slot,
    }
    Bistooltip_token_meta_cache[itemId] = meta
    return meta
end

-- Pick gear from token's list that appears in this class/spec BIS data
function Bistooltip_GetTokenProxyGearId(className, specName, tokenIdOrMeta)
    local tokenId = tokenIdOrMeta
    if type(tokenIdOrMeta) == "table" then
        tokenId = tokenIdOrMeta.tokenId
    end

    local data = tokenId and Bistooltip_token_data and Bistooltip_token_data[tokenId]
    if not data or not data.gear or #data.gear == 0 then
        return nil
    end

    for _, gearId in ipairs(data.gear) do
        if GearInBislist(className, specName, gearId) then
            return gearId
        end
    end
    return nil
end
