-- Set clipboard content to new link
setclipboard("https://linkunlocker.com/just-another-forsaken-script-rJ2JJ")

-- Load Rayfield library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Configuration System
local ConfigSystem = {
    CurrentProfile = "Default",
    Profiles = {"Default", "Profile1", "Profile2", "Profile3"},
    FolderName = "ForsakenScriptConfig"
}

-- Make sure the config folder exists
if not isfolder(ConfigSystem.FolderName) then
    makefolder(ConfigSystem.FolderName)
end

-- Create Window with Key System
local Window = Rayfield:CreateWindow({
    Name = "Forsaken Script",
    LoadingTitle = "Forsaken Script",
    LoadingSubtitle = "Enhanced ESP & Utilities",
    ConfigurationSaving = {
        Enabled = false,
    },
    KeySystem = true,
    KeySettings = {
        Title = "Enter Key",
        Subtitle = "Key is required to use this hub",
        Note = "Key link has been copied to your clipboard",
        Key = "devkey",
        Callback = function(Key)
            local isValid = Key == "devkey"
            Rayfield:Notify({
                Title = "Key System",
                Content = isValid and "Key accepted!" or "Incorrect key!",
                Duration = 5,
            })
            return isValid
        end
    }
})

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Create all tabs with icons
local PlayerTab = Window:CreateTab("Player", 4483362458) -- Default player icon
local ESPTab = Window:CreateTab("ESP", 4483345998) -- Default eye icon
local MiscTab = Window:CreateTab("Misc", 4483344166) -- Default gear icon
local SettingsTab = Window:CreateTab("Settings", 4483345950) -- Default settings icon
-- =============================================
-- IMPROVED ESP SYSTEM
-- =============================================
local ESP = {
    Enabled = false,
    Tags = {},
    ItemTags = {},
    FootprintTags = {},
    Connections = {},
    ItemConnections = {},
    FootprintConnections = {},
    Colors = {
        Survivors = Color3.fromRGB(0, 255, 0),
        Killers = Color3.fromRGB(255, 0, 0),
        Items = Color3.fromRGB(0, 191, 255),
        Footprints = Color3.fromRGB(255, 165, 0)
    },
    Settings = {
        ShowDistance = true,
        ShowHealth = true,
        ShowItems = false,
        ShowFootprints = false,
        HealthUpdateInterval = 0.2
    }
}

-- ESP Color Customization
local SurvivorsColorPicker = ESPTab:CreateColorPicker({
    Name = "Survivors Color",
    Color = ESP.Colors.Survivors,
    Flag = "SurvivorsColor",
    Callback = function(color)
        ESP.Colors.Survivors = color
        if ESP.UpdateAllTags then
            ESP.UpdateAllTags()
        end
    end
})

local KillersColorPicker = ESPTab:CreateColorPicker({
    Name = "Killers Color", 
    Color = ESP.Colors.Killers,
    Flag = "KillersColor",
    Callback = function(color)
        ESP.Colors.Killers = color
        if ESP.UpdateAllTags then
            ESP.UpdateAllTags()
        end
    end
})

local ItemsColorPicker = ESPTab:CreateColorPicker({
    Name = "Items Color", 
    Color = ESP.Colors.Items,
    Flag = "ItemsColor",
    Callback = function(color)
        ESP.Colors.Items = color
        if ESP.UpdateAllItemTags then
            ESP.UpdateAllItemTags()
        end
    end
})

local FootprintsColorPicker = ESPTab:CreateColorPicker({
    Name = "Footprints Color", 
    Color = ESP.Colors.Footprints,
    Flag = "FootprintsColor",
    Callback = function(color)
        ESP.Colors.Footprints = color
        if ESP.UpdateAllFootprintTags then
            ESP.UpdateAllFootprintTags()
        end
    end
})

-- ESP Settings
local ESPDistanceToggle = ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = ESP.Settings.ShowDistance,
    Flag = "ESPDistanceToggle",
    Callback = function(value)
        ESP.Settings.ShowDistance = value
        if ESP.UpdateAllTags then
            ESP.UpdateAllTags()
        end
    end
})

local ESPHealthToggle = ESPTab:CreateToggle({
    Name = "Show Health",
    CurrentValue = ESP.Settings.ShowHealth,
    Flag = "ESPHealthToggle",
    Callback = function(value)
        ESP.Settings.ShowHealth = value
        if ESP.UpdateAllTags then
            ESP.UpdateAllTags()
        end
    end
})

local ESPItemsToggle = ESPTab:CreateToggle({
    Name = "Show Items",
    CurrentValue = ESP.Settings.ShowItems,
    Flag = "ESPItemsToggle",
    Callback = function(value)
        ESP.Settings.ShowItems = value
        if value then
            ESP.InitializeItems()
            Rayfield:Notify({
                Title = "Item ESP",
                Content = "Item ESP enabled",
                Duration = 3,
            })
        else
            ESP.ClearItems()
            Rayfield:Notify({
                Title = "Item ESP",
                Content = "Item ESP disabled",
                Duration = 3,
            })
        end
    end
})

local ESPFootprintsToggle = ESPTab:CreateToggle({
    Name = "Show Digital Footprints",
    CurrentValue = ESP.Settings.ShowFootprints,
    Flag = "ESPFootprintsToggle",
    Callback = function(value)
        ESP.Settings.ShowFootprints = value
        if value then
            ESP.InitializeFootprints()
            Rayfield:Notify({
                Title = "Footprint ESP",
                Content = "Digital Footprints enabled",
                Duration = 3,
            })
        else
            ESP.ClearFootprints()
            Rayfield:Notify({
                Title = "Footprint ESP",
                Content = "Digital Footprints disabled",
                Duration = 3,
            })
        end
    end
})
-- Improved health color with smooth transitions
local function GetHealthColor(currentHealth, maxHealth)
    if currentHealth <= 0 then
        return Color3.fromRGB(128, 128, 128) -- Gray for dead
    end
    
    local healthPercent = currentHealth / maxHealth
    
    -- Smooth transition from green to yellow to red
    if healthPercent > 0.65 then -- 100-65 HP (green to yellow-green)
        local factor = (healthPercent - 0.65) / 0.35
        return Color3.new(
            1 - (0.65 * factor),  -- R: 0 → 0.65
            1,                    -- G: stays 1
            0.35 * factor         -- B: 0 → 0.35
        )
    elseif healthPercent > 0.4 then -- 64-40 HP (yellow-green to orange)
        local factor = (healthPercent - 0.4) / 0.25
        return Color3.new(
            1,                    -- R: stays 1
            0.65 + (0.35 * factor), -- G: 0.65 → 1
            0.35 * (1 - factor)   -- B: 0.35 → 0
        )
    else -- 39-1 HP (orange to red)
        local factor = healthPercent / 0.4
        return Color3.new(
            1,                    -- R: stays 1
            0.65 * factor,        -- G: 0 → 0.65
            0                    -- B: stays 0
        )
    end
end

-- Function to create a basic ESP tag
local function CreateBasicTag(adornee, size, name, color)
    local tag = Instance.new("BillboardGui")
    tag.Name = "ESPTag"
    tag.Adornee = adornee
    tag.Size = size
    tag.StudsOffset = Vector3.new(0, 2.5, 0)
    tag.AlwaysOnTop = true
    tag.MaxDistance = 5000
    tag.Enabled = true

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = color
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Text = name
    nameLabel.Parent = tag

    return tag
end

-- Improved ESP tag creation with better health tracking
function ESP.CreateTag(character, team)
    if not character or not character.Parent then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    if not humanoid or not head then return end

    -- Clean up existing tag
    if ESP.Tags[character] then
        ESP.Tags[character]:Destroy()
        if ESP.Connections[character] then
            for _, connection in pairs(ESP.Connections[character]) do
                connection:Disconnect()
            end
        end
    end

    -- Create new tag
    local tag = Instance.new("BillboardGui")
    tag.Name = "ESPTag"
    tag.Adornee = head
    tag.Size = UDim2.new(0, 200, 0, (ESP.Settings.ShowHealth and ESP.Settings.ShowDistance) and 70 or 50)
    tag.StudsOffset = Vector3.new(0, 2.5, 0)
    tag.AlwaysOnTop = true
    tag.MaxDistance = 5000
    tag.Enabled = ESP.Enabled

    -- Name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = ESP.Colors[team]
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Text = tostring(character.Name)
    nameLabel.Parent = tag

    -- Distance label (only if enabled)
    local distanceLabel
    if ESP.Settings.ShowDistance then
        distanceLabel = Instance.new("TextLabel")
        distanceLabel.Size = UDim2.new(1, 0, 0.25, 0)
        distanceLabel.Position = UDim2.new(0, 0, 0.5, -10)
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextColor3 = Color3.new(1, 1, 1)
        distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        distanceLabel.TextStrokeTransparency = 0.5
        distanceLabel.Font = Enum.Font.Gotham
        distanceLabel.TextSize = 12
        distanceLabel.Parent = tag
    end

    -- Health label (only if enabled)
    local healthLabel
    if ESP.Settings.ShowHealth then
        healthLabel = Instance.new("TextLabel")
        healthLabel.Size = UDim2.new(1, 0, 0.25, 0)
        healthLabel.Position = UDim2.new(0, 0, ESP.Settings.ShowDistance and 0.75 or 0.5, -5)
        healthLabel.BackgroundTransparency = 1
        healthLabel.TextColor3 = Color3.new(1, 1, 1)
        healthLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        healthLabel.TextStrokeTransparency = 0.5
        healthLabel.Font = Enum.Font.Gotham
        healthLabel.TextSize = 12
        healthLabel.Parent = tag
    end

    -- Improved update function with better health tracking
    local function UpdateTag()
        if not character or not character.Parent then
            if tag and tag.Parent then
                tag:Destroy()
            end
            return
        end

        local currentHealth, maxHealth = GetHumanoidHealth(character)
        
        -- Update distance
        if distanceLabel then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local distance = hrp and math.floor((head.Position - hrp.Position).Magnitude) or "N/A"
            distanceLabel.Text = "Distance: "..tostring(distance).."m"
        end

        -- Update health with color coding
        if healthLabel then
            healthLabel.Text = string.format("HP: %d/%d", math.floor(currentHealth), math.floor(maxHealth))
            healthLabel.TextColor3 = GetHealthColor(currentHealth, maxHealth)
        end

        -- Check if character died
        if currentHealth <= 0 then
            if tag and tag.Parent then
                tag:Destroy()
            end
            if ESP.Connections[character] then
                for _, connection in pairs(ESP.Connections[character]) do
                    connection:Disconnect()
                end
                ESP.Connections[character] = nil
            end
            ESP.Tags[character] = nil
            return
        end
    end

    -- Setup connections with improved health tracking
    ESP.Connections[character] = {
        humanoid.Died:Connect(function()
            if tag and tag.Parent then
                tag:Destroy()
            end
        end),
        RunService.Heartbeat:Connect(UpdateTag)
    }

    ESP.Tags[character] = tag
    UpdateTag()
    tag.Parent = head
end
-- Item ESP Functions
function ESP.CreateItemTag(item)
    if not item or not item.Parent then return end
    
    -- Clean up existing tag
    if ESP.ItemTags[item] then
        ESP.ItemTags[item]:Destroy()
        if ESP.ItemConnections[item] then
            ESP.ItemConnections[item]:Disconnect()
            ESP.ItemConnections[item] = nil
        end
    end

    local primaryPart = item:FindFirstChild("Handle") or item.PrimaryPart
    if not primaryPart then return end

    local tag = CreateBasicTag(
        primaryPart,
        UDim2.new(0, 200, 0, 50),
        item.Name,
        ESP.Colors.Items
    )
    
    tag.Enabled = ESP.Settings.ShowItems
    ESP.ItemTags[item] = tag
    tag.Parent = primaryPart

    -- Setup connection to remove tag if item is removed
    ESP.ItemConnections[item] = item.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if tag and tag.Parent then
                tag:Destroy()
            end
            if ESP.ItemConnections[item] then
                ESP.ItemConnections[item]:Disconnect()
                ESP.ItemConnections[item] = nil
            end
            ESP.ItemTags[item] = nil
        end
    end)
end

function ESP.InitializeItems()
    ESP.ClearItems()
    
    local map = Workspace:FindFirstChild("Map")
    if not map then return end
    
    local ingame = map:FindFirstChild("Ingame")
    if not ingame then return end

    -- Find existing items
    for _, item in pairs(ingame:GetDescendants()) do
        if item:IsA("Tool") and (item.Name == "Medkit" or item.Name == "BloxyCola") then
            ESP.CreateItemTag(item)
        end
    end

    -- Listen for new items
    ESP.ItemConnections.DescendantAdded = ingame.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Tool") and (descendant.Name == "Medkit" or descendant.Name == "BloxyCola") then
            ESP.CreateItemTag(descendant)
        end
    end)
end

function ESP.ClearItems()
    for item, tag in pairs(ESP.ItemTags) do
        if tag and tag.Parent then
            tag:Destroy()
        end
        if ESP.ItemConnections[item] then
            ESP.ItemConnections[item]:Disconnect()
            ESP.ItemConnections[item] = nil
        end
    end
    ESP.ItemTags = {}
    
    if ESP.ItemConnections.DescendantAdded then
        ESP.ItemConnections.DescendantAdded:Disconnect()
        ESP.ItemConnections.DescendantAdded = nil
    end
end

-- Digital Footprint ESP Functions
function ESP.CreateFootprintTag(footprint)
    if not footprint or not footprint.Parent then return end
    
    -- Clean up existing tag
    if ESP.FootprintTags[footprint] then
        ESP.FootprintTags[footprint]:Destroy()
        if ESP.FootprintConnections[footprint] then
            ESP.FootprintConnections[footprint]:Disconnect()
            ESP.FootprintConnections[footprint] = nil
        end
    end

    local tag = CreateBasicTag(
        footprint,
        UDim2.new(0, 200, 0, 50),
        "Footprint",
        ESP.Colors.Footprints
    )
    
    tag.Enabled = ESP.Settings.ShowFootprints
    ESP.FootprintTags[footprint] = tag
    tag.Parent = footprint

    -- Setup connection to remove tag if footprint is removed
    ESP.FootprintConnections[footprint] = footprint.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if tag and tag.Parent then
                tag:Destroy()
            end
            if ESP.FootprintConnections[footprint] then
                ESP.FootprintConnections[footprint]:Disconnect()
                ESP.FootprintConnections[footprint] = nil
            end
            ESP.FootprintTags[footprint] = nil
        end
    end)
end

function ESP.InitializeFootprints()
    ESP.ClearFootprints()
    
    local map = Workspace:FindFirstChild("Map")
    if not map then return end
    
    local ingame = map:FindFirstChild("Ingame")
    if not ingame then return end

    -- Find killer username
    local killerUsername = nil
    local playersFolder = Workspace:FindFirstChild("Players")
    if playersFolder then
        local killers = playersFolder:FindFirstChild("Killers")
        if killers then
            for _, killer in pairs(killers:GetChildren()) do
                if killer:IsA("Model") then
                    local player = Players:GetPlayerFromCharacter(killer)
                    if player then
                        killerUsername = player.Name
                        break
                    end
                end
            end
        end
    end

    if not killerUsername then return end

    -- Find footprint folder
    local footprintFolder = ingame:FindFirstChild(killerUsername.."Shadows")
    if not footprintFolder then return end

    -- Find existing footprints
    for _, footprint in pairs(footprintFolder:GetDescendants()) do
        if footprint.Name == "Shadow" and footprint:IsA("BasePart") then
            ESP.CreateFootprintTag(footprint)
        end
    end

    -- Listen for new footprints
    ESP.FootprintConnections.DescendantAdded = footprintFolder.DescendantAdded:Connect(function(descendant)
        if descendant.Name == "Shadow" and descendant:IsA("BasePart") then
            ESP.CreateFootprintTag(descendant)
        end
    end)
end
function ESP.ClearFootprints()
    for footprint, tag in pairs(ESP.FootprintTags) do
        if tag and tag.Parent then
            tag:Destroy()
        end
        if ESP.FootprintConnections[footprint] then
            ESP.FootprintConnections[footprint]:Disconnect()
            ESP.FootprintConnections[footprint] = nil
        end
    end
    ESP.FootprintTags = {}
    
    if ESP.FootprintConnections.DescendantAdded then
        ESP.FootprintConnections.DescendantAdded:Disconnect()
        ESP.FootprintConnections.DescendantAdded = nil
    end
end

-- Main ESP Functions
function ESP.UpdateAllTags()
    for character, tag in pairs(ESP.Tags) do
        if character and character.Parent then
            local team = character.Parent.Name == "Survivors" and "Survivors" or "Killers"
            ESP.CreateTag(character, team)
        end
    end
end

function ESP.Initialize()
    -- Clean up existing
    for character, connections in pairs(ESP.Connections) do
        for _, connection in pairs(connections) do
            connection:Disconnect()
        end
    end
    for _, tag in pairs(ESP.Tags) do
        if tag and tag.Parent then
            tag:Destroy()
        end
    end
    
    ESP.Tags = {}
    ESP.Connections = {}

    local playersFolder = Workspace:WaitForChild("Players")
    if not playersFolder then return end

    -- Process existing players
    for _, teamName in ipairs({"Survivors", "Killers"}) do
        local team = playersFolder:FindFirstChild(teamName)
        if team then
            for _, character in ipairs(team:GetChildren()) do
                if character:IsA("Model") then
                    task.spawn(function()
                        local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 2)
                        if humanoid then
                            ESP.CreateTag(character, teamName)
                        end
                    end)
                end
            end
        end
    end

    -- Listen for new players
    playersFolder.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Model") then
            local parent = descendant.Parent
            if parent and (parent.Name == "Survivors" or parent.Name == "Killers") then
                task.spawn(function()
                    local humanoid = descendant:FindFirstChildOfClass("Humanoid") or descendant:WaitForChild("Humanoid", 2)
                    if humanoid then
                        ESP.CreateTag(descendant, parent.Name)
                    end
                end)
            end
        end
    end)

    -- Initialize items and footprints if enabled
    if ESP.Settings.ShowItems then
        ESP.InitializeItems()
    end
    if ESP.Settings.ShowFootprints then
        ESP.InitializeFootprints()
    end
end

-- ESP Toggle
local ESPToggle = ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = ESP.Enabled,
    Flag = "ESPToggle",
    Callback = function(value)
        ESP.Enabled = value
        for _, tag in pairs(ESP.Tags) do
            if tag then
                tag.Enabled = value
            end
        end
        
        if value then
            ESP.Initialize()
            Rayfield:Notify({
                Title = "ESP",
                Content = "ESP enabled with reliable health tracking",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "ESP",
                Content = "ESP disabled",
                Duration = 3,
            })
        end
    end
})
-- =============================================
-- PLAYER TAB
-- =============================================
local sprintModule
local isStaminaDrainDisabled = false
local staminaMonitorConnection = nil

local function modifyStaminaSettings()
    pcall(function()
        if not sprintModule then
            sprintModule = require(ReplicatedStorage.Systems.Character.Game.Sprinting)
        end
        sprintModule.StaminaLossDisabled = isStaminaDrainDisabled
    end)
end

local function monitorAndReapplyStamina()
    if staminaMonitorConnection then
        staminaMonitorConnection:Disconnect()
    end
    
    staminaMonitorConnection = RunService.Heartbeat:Connect(function()
        if isStaminaDrainDisabled then
            modifyStaminaSettings()
        end
    end)
end

local StaminaToggle = PlayerTab:CreateToggle({
    Name = "Disable Stamina Drain",
    CurrentValue = isStaminaDrainDisabled,
    Flag = "StaminaToggle",
    Callback = function(Value)
        isStaminaDrainDisabled = Value
        modifyStaminaSettings()
        
        if Value then
            monitorAndReapplyStamina()
            Rayfield:Notify({
                Title = "Stamina",
                Content = "Stamina drain disabled!",
                Duration = 3,
            })
        else
            if staminaMonitorConnection then
                staminaMonitorConnection:Disconnect()
                staminaMonitorConnection = nil
            end
            Rayfield:Notify({
                Title = "Stamina",
                Content = "Stamina drain enabled",
                Duration = 3,
            })
        end
    end,
})

-- Character reset with cooldown
local lastResetTime = 0
local resetCooldown = 10 -- seconds

PlayerTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        local currentTime = os.time()
        if currentTime - lastResetTime >= resetCooldown then
            lastResetTime = currentTime
            local character = LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                end
            end
        else
            Rayfield:Notify({
                Title = "Cooldown",
                Content = string.format("Please wait %d more seconds before resetting again", resetCooldown - (currentTime - lastResetTime)),
                Duration = 3,
            })
        end
    end,
})
-- =============================================
-- MISC TAB
-- =============================================
-- Reworked Fullbright System
local fullbrightEnabled = false
local originalLightingSettings = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    Brightness = Lighting.Brightness
}

local function ToggleFullbright(enabled)
    if enabled then
        -- Save original settings
        originalLightingSettings = {
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            ClockTime = Lighting.ClockTime,
            GlobalShadows = Lighting.GlobalShadows,
            Brightness = Lighting.Brightness
        }
        
        -- Apply fullbright
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.ClockTime = 12
        Lighting.GlobalShadows = false
        Lighting.Brightness = 2
        
        -- Create a subtle light source at camera
        local camera = workspace.CurrentCamera
        if camera and not camera:FindFirstChild("FullbrightLight") then
            local light = Instance.new("PointLight")
            light.Name = "FullbrightLight"
            light.Brightness = 0.5
            light.Range = 100
            light.Shadows = false
            light.Parent = camera
        end
    else
        -- Restore original settings
        for property, value in pairs(originalLightingSettings) do
            Lighting[property] = value
        end
        
        -- Remove the light source
        local camera = workspace.CurrentCamera
        if camera then
            local light = camera:FindFirstChild("FullbrightLight")
            if light then
                light:Destroy()
            end
        end
    end
end

local FullbrightToggle = MiscTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = fullbrightEnabled,
    Flag = "FullbrightToggle",
    Callback = function(value)
        fullbrightEnabled = value
        ToggleFullbright(value)
        
        if value then
            Rayfield:Notify({
                Title = "Fullbright",
                Content = "Enabled with enhanced lighting",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "Fullbright",
                Content = "Disabled - Lighting restored",
                Duration = 3,
            })
        end
    end
})

-- Connect to camera changes to maintain fullbright light
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if fullbrightEnabled then
        ToggleFullbright(true)
    end
end)

-- Anti-AFK
local antiAfkEnabled = false
local antiAfkConnection

local AntiAFKToggle = MiscTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = antiAfkEnabled,
    Flag = "AntiAFKToggle",
    Callback = function(value)
        antiAfkEnabled = value
        if value then
            antiAfkConnection = game:GetService("Players").LocalPlayer.Idled:Connect(function()
                game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
            Rayfield:Notify({
                Title = "Anti-AFK",
                Content = "Enabled - You won't be kicked for idling",
                Duration = 3,
            })
        else
            if antiAfkConnection then
                antiAfkConnection:Disconnect()
            end
            Rayfield:Notify({
                Title = "Anti-AFK",
                Content = "Disabled",
                Duration = 3,
            })
        end
    end
})

-- Rejoin Game
MiscTab:CreateButton({
    Name = "Rejoin Game",
    Callback = function()
        Rayfield:Notify({
            Title = "Rejoining",
            Content = "Attempting to rejoin the game...",
            Duration = 3,
        })
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end,
})

-- Anti Subspace
MiscTab:CreateButton({
    Name = "Anti Subspace",
    Callback = function()
        pcall(function()
            local path = ReplicatedStorage.Modules.StatusEffects.SurvivorExclusive
            if path:FindFirstChild("Subspaced") then
                path.Subspaced:Destroy()
                Rayfield:Notify({
                    Title = "Success",
                    Content = "Subspace effect removed!",
                    Duration = 5,
                })
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Subspace effect not found",
                    Duration = 5,
                })
            end
        end)
    end,
})

-- Round Timer Mover
local function setupRoundTimerMover()
    local roundTimer = PlayerGui:FindFirstChild("RoundTimer")
    if not roundTimer then return nil end
    
    local mainFrame = roundTimer:FindFirstChild("Main")
    if not mainFrame then return nil end
    
    return mainFrame
end

local mainFrame = setupRoundTimerMover()
local RoundTimerPosSlider

if mainFrame then
    RoundTimerPosSlider = MiscTab:CreateSlider({
        Name = "RoundTimer Position",
        Range = {0, 1},
        Increment = 0.01,
        Suffix = "position",
        CurrentValue = 0.5,
        Flag = "RoundTimerPos",
        Callback = function(value)
            mainFrame.Position = UDim2.new(value, 0, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset)
        end,
    })
end
-- =============================================
-- SETTINGS TAB WITH CONFIGURATION SYSTEM
-- =============================================
-- Create profile dropdown
local ProfileDropdown = SettingsTab:CreateDropdown({
    Name = "Configuration Profile",
    Options = ConfigSystem.Profiles,
    CurrentOption = ConfigSystem.CurrentProfile,
    Flag = "ConfigProfile",
    Callback = function(option)
        ConfigSystem.CurrentProfile = option
    end
})

-- Function to save current configuration to a profile
function SaveConfig(profileName)
    profileName = tostring(profileName)
    local success, err = pcall(function()
        local config = {
            ESP = {
                Enabled = ESP.Enabled,
                Colors = {
                    Survivors = {
                        R = ESP.Colors.Survivors.R,
                        G = ESP.Colors.Survivors.G,
                        B = ESP.Colors.Survivors.B
                    },
                    Killers = {
                        R = ESP.Colors.Killers.R,
                        G = ESP.Colors.Killers.G,
                        B = ESP.Colors.Killers.B
                    },
                    Items = {
                        R = ESP.Colors.Items.R,
                        G = ESP.Colors.Items.G,
                        B = ESP.Colors.Items.B
                    },
                    Footprints = {
                        R = ESP.Colors.Footprints.R,
                        G = ESP.Colors.Footprints.G,
                        B = ESP.Colors.Footprints.B
                    }
                },
                Settings = {
                    ShowDistance = ESP.Settings.ShowDistance,
                    ShowHealth = ESP.Settings.ShowHealth,
                    ShowItems = ESP.Settings.ShowItems,
                    ShowFootprints = ESP.Settings.ShowFootprints
                }
            },
            Player = {
                StaminaDrainDisabled = isStaminaDrainDisabled
            },
            Misc = {
                AntiAFK = antiAfkEnabled,
                Fullbright = fullbrightEnabled,
                RoundTimerPos = mainFrame and mainFrame.Position.X.Scale or 0.5
            }
        }
        
        local filePath = ConfigSystem.FolderName.."/"..profileName..".json"
        writefile(filePath, HttpService:JSONEncode(config))
    end)
    
    if success then
        Rayfield:Notify({
            Title = "Configuration Saved",
            Content = "Settings saved to profile: "..profileName,
            Duration = 3,
        })
    else
        Rayfield:Notify({
            Title = "Error Saving",
            Content = "Failed to save config: "..tostring(err),
            Duration = 5,
        })
    end
end

-- Function to load configuration from a profile
function LoadConfig(profileName)
    profileName = tostring(profileName)
    local success, config = pcall(function()
        if not isfile(ConfigSystem.FolderName.."/"..profileName..".json") then
            return nil
        end
        return HttpService:JSONDecode(readfile(ConfigSystem.FolderName.."/"..profileName..".json"))
    end)
    
    if success and config then
        -- ESP Settings
        if config.ESP then
            ESP.Enabled = config.ESP.Enabled or false
            ESPToggle:Set(ESP.Enabled)
            
            if config.ESP.Colors then
                if config.ESP.Colors.Survivors then
                    local color = Color3.new(
                        config.ESP.Colors.Survivors.R,
                        config.ESP.Colors.Survivors.G,
                        config.ESP.Colors.Survivors.B
                    )
                    ESP.Colors.Survivors = color
                    SurvivorsColorPicker:Set(color)
                end
                
                if config.ESP.Colors.Killers then
                    local color = Color3.new(
                        config.ESP.Colors.Killers.R,
                        config.ESP.Colors.Killers.G,
                        config.ESP.Colors.Killers.B
                    )
                    ESP.Colors.Killers = color
                    KillersColorPicker:Set(color)
                end
                
                if config.ESP.Colors.Items then
                    local color = Color3.new(
                        config.ESP.Colors.Items.R,
                        config.ESP.Colors.Items.G,
                        config.ESP.Colors.Items.B
                    )
                    ESP.Colors.Items = color
                    ItemsColorPicker:Set(color)
                end
                
                if config.ESP.Colors.Footprints then
                    local color = Color3.new(
                        config.ESP.Colors.Footprints.R,
                        config.ESP.Colors.Footprints.G,
                        config.ESP.Colors.Footprints.B
                    )
                    ESP.Colors.Footprints = color
                    FootprintsColorPicker:Set(color)
                end
            end
            
            if config.ESP.Settings then
                ESP.Settings.ShowDistance = config.ESP.Settings.ShowDistance or true
                ESPDistanceToggle:Set(ESP.Settings.ShowDistance)
                
                ESP.Settings.ShowHealth = config.ESP.Settings.ShowHealth or true
                ESPHealthToggle:Set(ESP.Settings.ShowHealth)
                
                ESP.Settings.ShowItems = config.ESP.Settings.ShowItems or false
                ESPItemsToggle:Set(ESP.Settings.ShowItems)
                
                ESP.Settings.ShowFootprints = config.ESP.Settings.ShowFootprints or false
                ESPFootprintsToggle:Set(ESP.Settings.ShowFootprints)
            end
        end
        
        -- Player Settings
        if config.Player then
            isStaminaDrainDisabled = config.Player.StaminaDrainDisabled or false
            StaminaToggle:Set(isStaminaDrainDisabled)
        end
        
        -- Misc Settings
        if config.Misc then
            antiAfkEnabled = config.Misc.AntiAFK or false
            AntiAFKToggle:Set(antiAfkEnabled)
            
            fullbrightEnabled = config.Misc.Fullbright or false
            FullbrightToggle:Set(fullbrightEnabled)
            
            if config.Misc.RoundTimerPos and mainFrame and RoundTimerPosSlider then
                RoundTimerPosSlider:Set(config.Misc.RoundTimerPos)
            end
        end
        
        Rayfield:Notify({
            Title = "Configuration Loaded",
            Content = "Settings loaded from profile: "..profileName,
            Duration = 3,
        })
    else
        Rayfield:Notify({
            Title = "Error Loading",
            Content = "Failed to load config: "..(config == nil and "File not found" or tostring(err)),
            Duration = 5,
        })
    end
end

-- Create save and load buttons
SettingsTab:CreateButton({
    Name = "Save Current Profile",
    Callback = function()
        SaveConfig(ConfigSystem.CurrentProfile)
    end,
})

SettingsTab:CreateButton({
    Name = "Load Selected Profile",
    Callback = function()
        LoadConfig(ConfigSystem.CurrentProfile)
    end,
})

-- Auto-load default config on script start
task.spawn(function()
    LoadConfig(ConfigSystem.CurrentProfile)
end)