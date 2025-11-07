---this is caller for moduler you can replace this with your script 
local DataStoreWrapper = require(game.ServerScriptService.SimpleDataStoreWrapper)
local Players = game:GetService("Players")

-- Example: Incialization for new player
Players.PlayerAdded:Connect(function(player)
    local data = DataStoreWrapper:GetPlayerData(player)
    print("Loaded data for", player.Name, data)
end)

-- Example: save data
Players.PlayerAdded:Connect(function(player)
    local data = DataStoreWrapper:GetPlayerData(player)
    DataStoreWrapper:UpdatePlayerData(player, {Coins = data.Coins + 10})
    DataStoreWrapper:SavePlayerData(player)
end)