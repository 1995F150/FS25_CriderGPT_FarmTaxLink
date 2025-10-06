--========================================================--
-- FS25 CriderGPT ↔ Farm Tax Manager Integration
-- Author: Jessie Crider (CriderGPT)
-- Version: 1.0.0.0 | Console Safe | FS25 Ready
--========================================================--

-- 🔒 Dependency Checks
if g_modIsLoaded == nil then
    Logging.error("❌ FS25 CriderGPT Integration failed: g_modIsLoaded missing.")
    return
end

if g_modIsLoaded["FS25_CriderGPTHelper"] == nil then
    Logging.error("❌ CriderGPT Helper not found! Please enable FS25_CriderGPTHelper.")
    return
end

if g_modIsLoaded["FS25_FarmTaxManager"] == nil then
    Logging.error("❌ Farm Tax Manager not found! Please enable FS25_FarmTaxManager.")
    return
end

Logging.info("[CriderGPT│Integration] All required mods detected — initializing systems...")

--========================================================--
--  CriderGPT ↔ Farm Tax Manager Integration Core
--========================================================--
CriderGPT_FarmTaxLink = {}
local CriderGPT_FarmTaxLink_mt = Class(CriderGPT_FarmTaxLink)

function CriderGPT_FarmTaxLink:new(mission, i18n)
    local self = setmetatable({}, CriderGPT_FarmTaxLink_mt)
    self.mission = mission
    self.i18n = i18n
    self.linked = false
    self.totalSyncedTaxes = 0
    self.taxRate = 0
    return self
end

--========================================================--
--  Initialization & Link Validation
--========================================================--
function CriderGPT_FarmTaxLink:loadMap(name)
    self.mission:addUpdateable(self)
    if CriderGPTHelper ~= nil and FarmTaxManager ~= nil then
        self.linked = true
        self.taxRate = FarmTaxManager.salesTaxRate or 0.052
        CriderGPTHelper:showNotification("🔗 CriderGPT linked with Farm Tax Manager.")
        Logging.info("[CriderGPT│Integration] Link established successfully.")

        if CriderGPTApollo ~= nil and CriderGPTApollo.registerAddon ~= nil then
            CriderGPTApollo:registerAddon("Farm Tax Manager")
        end
    else
        Logging.warning("[CriderGPT│Integration] One or more modules missing during load.")
    end

    -- Subscribe to daily event for syncing
    g_messageCenter:subscribe(MessageType.DAY_CHANGED, self.onDayChanged, self)
end

--========================================================--
--  Daily Data Sync
--========================================================--
function CriderGPT_FarmTaxLink:onDayChanged(day)
    if not self.linked then return end

    if FarmTaxManager ~= nil and FarmTaxManager.totalTaxPaid ~= nil then
        self.totalSyncedTaxes = FarmTaxManager.totalTaxPaid
        local msg = string.format("📊 CriderGPT Sync: $%.2f total taxes recorded.", self.totalSyncedTaxes)
        self:showHUD(msg)
        Logging.info("[CriderGPT│Integration] Synced tax data: " .. msg)
    end
end

--========================================================--
--  Apollo Extension (Optional commands)
--========================================================--
if CriderGPTApollo ~= nil then
    function CriderGPTApollo:getTaxSummary()
        if FarmTaxManager ~= nil and FarmTaxManager.totalTaxPaid ~= nil then
            return string.format("💵 Total farm taxes paid: $%.2f", FarmTaxManager.totalTaxPaid)
        else
            return "Farm Tax Manager data unavailable or not initialized yet."
        end
    end

    function CriderGPTApollo:setTaxRate(rate)
        if FarmTaxManager ~= nil then
            FarmTaxManager.salesTaxRate = rate
            Logging.info(string.format("[CriderGPT│Integration] Sales tax rate updated to %.2f%%", rate * 100))
            return string.format("🧾 Sales tax rate updated to %.1f%%", rate * 100)
        else
            return "⚠️ Cannot set rate — Farm Tax Manager missing."
        end
    end
end

--========================================================--
--  HUD Helper (Console Safe)
--========================================================--
function CriderGPT_FarmTaxLink:showHUD(text)
    if g_currentMission ~= nil and g_currentMission.hud ~= nil then
        g_currentMission.hud:addSideNotification("CriderGPT│ " .. text)
    else
        print("[CriderGPT│HUD] " .. text)
    end
end

--========================================================--
--  Register Mod Event
--========================================================--
addModEventListener(CriderGPT_FarmTaxLink:new(g_currentMission, g_i18n))

Logging.info("[CriderGPT│Integration] CriderGPT ↔ Farm Tax Manager link active and console safe.")
