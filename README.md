# Simple DataStore Wrapper for Roblox Studio

A robust and easy-to-use DataStore wrapper for Roblox Studio that provides reliable player data saving and loading with built-in retry logic, caching, and autosave functionality.

## Features

- ✅ **Simple API** - Easy-to-use functions for saving and loading player data
- ✅ **Retry Logic** - Automatic retry on failed DataStore operations (3 attempts)
- ✅ **Memory Caching** - Reduces DataStore calls by caching data in memory
- ✅ **Auto-save** - Automatic saving when players leave and periodic autosave every 5 minutes
- ✅ **Default Data** - Built-in default player data structure
- ✅ **Error Handling** - Comprehensive error handling and logging
- ✅ **Thread-safe** - Safe for use in multi-threaded Roblox environments

## Installation

1. Copy the `SimpleDataStoreWrapper.lua` file to your Roblox project
2. Place it in `ServerScriptService` 
3. Require the module in your scripts:

```lua
local DataStoreWrapper = require(path.to.SimpleDataStoreWrapper)
```

## Default Player Data

The module comes with built-in default player data:
```lua
{
    Coins = 0,
    Level = 1,
    Inventory = {}
}
```

## API Reference

### GetPlayerData(player)
Retrieves player data from cache or DataStore, returns default data if none exists.

```lua
local playerData = DataStoreWrapper:GetPlayerData(player)
print(playerData.Coins) -- 0 (default)
print(playerData.Level) -- 1 (default)
```

### SavePlayerData(player)
Saves the player's current data to the DataStore.

```lua
local success = DataStoreWrapper:SavePlayerData(player)
if success then
    print("Data saved successfully!")
end
```

### UpdatePlayerData(player, updates)
Updates player data in the cache (does not automatically save).

```lua
DataStoreWrapper:UpdatePlayerData(player, {
    Coins = 100,
    Level = 5
})
```

## Usage Example

```lua
local DataStoreWrapper = require(game.ServerStorage.SimpleDataStoreWrapper)

-- When player joins, load their data
game.Players.PlayerAdded:Connect(function(player)
    local data = DataStoreWrapper:GetPlayerData(player)
    print(player.Name .. " has " .. data.Coins .. " coins")
    
    -- Update player's coins
    DataStoreWrapper:UpdatePlayerData(player, {Coins = data.Coins + 50})
end)

-- When player leaves, data is automatically saved
-- You can also manually save when needed:
game.Players.PlayerRemoving:Connect(function(player)
    local success = DataStoreWrapper:SavePlayerData(player)
    if success then
        print("Player data saved successfully")
    end
end)
```

## Configuration

You can modify the configuration at the top of the module:

```lua
local CONFIG = {
    DATASTORE_NAME = "PlayerData",      -- DataStore name
    MAX_RETRIES = 3,                     -- Retry attempts
    RETRY_DELAY = 1,                     -- Delay between retries (seconds)
    AUTO_SAVE_INTERVAL = 300,           -- Autosave interval (5 minutes)
    DEFAULT_DATA = {                      -- Default player data
        Coins = 0,
        Level = 1,
        Inventory = {}
    }
}
```

## Advanced Features

### Manual Cache Management
```lua
-- Get cache for debugging
local cache = DataStoreWrapper:GetCache()

-- Clear specific player's cache
DataStoreWrapper:ClearPlayerCache(player)
```

### Cleanup
```lua
-- Clean up resources (saves all players and disconnects connections)
DataStoreWrapper:Cleanup()
```

## Error Handling

The module includes comprehensive error handling:
- Failed DataStore operations are retried automatically
- Invalid players are handled gracefully
- Detailed warning messages for debugging
- Fallback to default data when loading fails

## Performance Considerations

- **Memory Caching**: Data is cached in memory to minimize DataStore calls
- **Periodic Autosave**: Saves all players every 5 minutes (configurable)
- **Efficient Updates**: Only modified data is updated in cache
- **Automatic Cleanup**: Resources are properly cleaned up on game shutdown

## License

This module is provided as-is for use in Roblox projects. Feel free to modify and distribute as needed.

## Contributing

This is a simple wrapper module. Contributions are welcome! If you find any bugs or have feature requests, please open an issue or submit a pull request.

---

**Note**: This module requires Roblox DataStoreService to be enabled in your game settings. Make sure to test thoroughly in Roblox Studio before deploying to production.