local LoadService = {}

function LoadService.OnStart()
end

--- Loads the game map 
--- @param mapName -- The name of the map to load
function LoadService.LoadMap(mapName: string)
    local mapFolder = game.ReplicatedStorage.Shared.Assets.Maps:FindFirstChild(mapName)
    if not mapFolder then
        warn("Map not found: " .. mapName)
        return
    end

    mapFolder:Clone().Parent = game.Workspace
end

return LoadService