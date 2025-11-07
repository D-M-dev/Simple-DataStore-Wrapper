-- Simple DataStore Wrapper for Roblox Studio
-- Provides easy-to-use functions for saving and loading player data

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local SimpleDataStoreWrapper = {}
SimpleDataStoreWrapper.__index = SimpleDataStoreWrapper

-- Configuration
local CONFIG = {
    DATASTORE_NAME = "PlayerData",
    MAX_RETRIES = 3,
    RETRY_DELAY = 1, -- seconds
    AUTO_SAVE_INTERVAL = 300, -- 5 minutes
    DEFAULT_DATA = {
        Coins = 0,
        Level = 1,
        Inventory = {}
    }
}

-- Internal state
local dataStore = nil
local playerCache = {}
local autoSaveConnection = nil

-- Helper function for retry logic
local function retryAsync(func, maxRetries, delay)
    local retries = 0
    local success, result
    
    while retries < maxRetries do
        success, result = pcall(func)
        if success then
            return success, result
        end
        
        retries = retries + 1
        if retries < maxRetries then
            wait(delay)
        end
    end
    
    return false, result
end

-- Initialize the DataStore
function SimpleDataStoreWrapper:Initialize()
    if dataStore then
        return true -- Already initialized
    end
    
    local success, err = pcall(function()
        dataStore = DataStoreService:GetDataStore(CONFIG.DATASTORE_NAME)
    end)
    
    if not success then
        warn("Failed to initialize DataStore:", err)
        return false
    end
    
    -- Set up auto-save on player removal
    Players.PlayerRemoving:Connect(function(player)
        self:SavePlayerData(player)
    end)
    
    -- Set up periodic auto-save
    if autoSaveConnection then
        autoSaveConnection:Disconnect()
    end
    
    autoSaveConnection = game:GetService("RunService").Heartbeat:Connect(function()
        local currentTime = tick()
        if not self._lastAutoSave or (currentTime - self._lastAutoSave) >= CONFIG.AUTO_SAVE_INTERVAL then
            self._lastAutoSave = currentTime
            self:AutoSaveAllPlayers()
        end
    end)
    
    return true
end

-- Get player data with caching and retry logic
function SimpleDataStoreWrapper:GetPlayerData(player)
    if not player or not player.UserId then
        warn("Invalid player provided")
        return table.clone(CONFIG.DEFAULT_DATA)
    end
    
    local userId = tostring(player.UserId)
    
    -- Return cached data if available
    if playerCache[userId] then
        return table.clone(playerCache[userId])
    end
    
    -- Try to load from DataStore with retry logic
    local success, data = retryAsync(function()
        return dataStore:GetAsync(userId)
    end, CONFIG.MAX_RETRIES, CONFIG.RETRY_DELAY)
    
    if success and data then
        -- Merge with default data to ensure all fields exist
        local mergedData = table.clone(CONFIG.DEFAULT_DATA)
        for key, value in pairs(data) do
            mergedData[key] = value
        end
        
        -- Cache the data
        playerCache[userId] = mergedData
        return table.clone(mergedData)
    else
        -- Return default data if loading fails
        warn("Failed to load data for player " .. userId .. ", using defaults")
        playerCache[userId] = table.clone(CONFIG.DEFAULT_DATA)
        return table.clone(CONFIG.DEFAULT_DATA)
    end
end

-- Save player data with retry logic
function SimpleDataStoreWrapper:SavePlayerData(player)
    if not player or not player.UserId then
        warn("Invalid player provided")
        return false
    end
    
    local userId = tostring(player.UserId)
    local data = playerCache[userId]
    
    if not data then
        warn("No data to save for player " .. userId)
        return false
    end
    
    local success, err = retryAsync(function()
        return dataStore:SetAsync(userId, data)
    end, CONFIG.MAX_RETRIES, CONFIG.RETRY_DELAY)
    
    if success then
        print("Successfully saved data for player " .. userId)
        return true
    else
        warn("Failed to save data for player " .. userId .. ":", err)
        return false
    end
end

-- Update player data in cache
function SimpleDataStoreWrapper:UpdatePlayerData(player, updates)
    if not player or not player.UserId then
        warn("Invalid player provided")
        return false
    end
    
    local userId = tostring(player.UserId)
    local currentData = playerCache[userId]
    
    if not currentData then
        warn("No cached data for player " .. userId)
        return false
    end
    
    -- Apply updates
    for key, value in pairs(updates) do
        currentData[key] = value
    end
    
    return true
end

-- Auto-save all players
function SimpleDataStoreWrapper:AutoSaveAllPlayers()
    local savedCount = 0
    local totalCount = 0
    
    for _, player in ipairs(Players:GetPlayers()) do
        totalCount = totalCount + 1
        if self:SavePlayerData(player) then
            savedCount = savedCount + 1
        end
    end
    
    if totalCount > 0 then
        print(string.format("Auto-saved %d/%d players", savedCount, totalCount))
    end
end

-- Get all cached player data (for debugging)
function SimpleDataStoreWrapper:GetCache()
    local cacheCopy = {}
    for userId, data in pairs(playerCache) do
        cacheCopy[userId] = table.clone(data)
    end
    return cacheCopy
end

-- Clear cache for a specific player
function SimpleDataStoreWrapper:ClearPlayerCache(player)
    if not player or not player.UserId then
        return
    end
    
    local userId = tostring(player.UserId)
    playerCache[userId] = nil
end

-- Clean up
function SimpleDataStoreWrapper:Cleanup()
    if autoSaveConnection then
        autoSaveConnection:Disconnect()
        autoSaveConnection = nil
    end
    
    -- Save all players before cleanup
    self:AutoSaveAllPlayers()
    
    -- Clear cache
    table.clear(playerCache)
end

-- Initialize on module load
SimpleDataStoreWrapper:Initialize()

-- Return the module
return SimpleDataStoreWrapper
