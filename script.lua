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
        Enabled = false, -- We're handling this manually
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

-- Create all tabs
local PlayerTab = Window:CreateTab("Player")
local ESPTab = Window:CreateTab("ESP")
local MiscTab = Window:CreateTab("Misc")
local SettingsTab = Window:CreateTab("Settings")

-- =============================================
-- IMPROVED ESP SYSTEM WITH ALL REQUESTED FEATURES
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

-- Improved health tracking variables
local healthTrackers = {}
local lastHealthValues = {}

-- Function to safely get humanoid health
local function GetHumanoidHealth(character)
    if not character or not character.Parent then return 0, 0 end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return 0, 0 end
    return humanoid.Health, humanoid.MaxHealth
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
        if healthTrackers[character] then
            healthTrackers[character]:Disconnect()
            healthTrackers[character] = nil
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
            
            -- Color code based on health ranges
            if currentHealth <= 0 then
                healthLabel.TextColor3 = Color3.fromRGB(128, 128, 128) -- Gray for dead
            elseif currentHealth <= 39 then
                healthLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red (39-1 HP)
            elseif currentHealth <= 64 then
                healthLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow (64-40 HP)
            else
                healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green (100-65 HP)
            end
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

    -- Special health tracker with interval
    healthTrackers[character] = RunService.Heartbeat:Connect(function()
        local currentHealth, maxHealth = GetHumanoidHealth(character)
        if lastHealthValues[character] ~= currentHealth then
            UpdateTag()
            lastHealthValues[character] = currentHealth
        end
    end)

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

function ESP.UpdateAllItemTags()
    for item, tag in pairs(ESP.ItemTags) do
        if tag and item and item.Parent then
            tag.Enabled = ESP.Settings.ShowItems
        else
            if tag and tag.Parent then
                tag:Destroy()
            end
            ESP.ItemTags[item] = nil
        end
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

function ESP.UpdateAllFootprintTags()
    for footprint, tag in pairs(ESP.FootprintTags) do
        if tag and footprint and footprint.Parent then
            tag.Enabled = ESP.Settings.ShowFootprints
        else
            if tag and tag.Parent then
                tag:Destroy()
            end
            ESP.FootprintTags[footprint] = nil
        end
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
    for _, teamName in ipairs({"Su
