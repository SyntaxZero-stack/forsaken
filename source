-- Set clipboard content
setclipboard("https://linkunlocker.com/just-another-forsaken-script-0FJGK")

-- Load Rayfield library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Window with Key System
local Window = Rayfield:CreateWindow({
    Name = "Forsaken Script",
    LoadingTitle = "Forsaken Script",
    LoadingSubtitle = "Enhanced ESP & Utilities",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "ForsakenScriptConfig",
        FileName = "Settings"
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
local LocalPlayer = Players.LocalPlayer

-- Create tabs
local PlayerTab = Window:CreateTab("Player")
local ESPTab = Window:CreateTab("ESP")
local MiscTab = Window:CreateTab("Misc")
local SettingsTab = Window:CreateTab("Settings")

-- =============================================
-- IMPROVED ESP SYSTEM WITH RELIABLE HEALTH TRACKING
-- =============================================
local ESP = {
    Enabled = false,
    Tags = {},
    Connections = {},
    Colors = {
        Survivors = Color3.fromRGB(0, 255, 0),
        Killers = Color3.fromRGB(255, 0, 0)
    }
}

-- Color customization
ESPTab:CreateColorPicker({
    Name = "Survivors Color",
    Color = ESP.Colors.Survivors,
    Flag = "SurvivorsColor",
    Callback = function(color)
        ESP.Colors.Survivors = color
        ESP.UpdateAllTags()
    end
})

ESPTab:CreateColorPicker({
    Name = "Killers Color",
    Color = ESP.Colors.Killers,
    Flag = "KillersColor",
    Callback = function(color)
        ESP.Colors.Killers = color
        ESP.UpdateAllTags()
    end
})

-- Improved ESP Functions
function ESP.CreateTag(character, team)
    if not character or not character.Parent then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local head = character:FindFirstChild("Head")
    if not humanoid or not head then return end

    -- Clean up existing tag
    if ESP.Tags[character] then
        ESP.Tags[character]:Destroy()
        if ESP.Connections[character] then
            ESP.Connections[character]:Disconnect()
        end
    end

    -- Create new tag
    local tag = Instance.new("BillboardGui")
    tag.Name = "ESPTag"
    tag.Adornee = head
    tag.Size = UDim2.new(0, 200, 0, 50)
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
    nameLabel.Text = character.Name
    nameLabel.Parent = tag

    -- Health label
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
    healthLabel.Position = UDim2.new(0, 0, 0.5, -5)
    healthLabel.BackgroundTransparency = 1
    healthLabel.TextColor3 = Color3.new(1, 1, 1)
    healthLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    healthLabel.TextStrokeTransparency = 0.5
    healthLabel.Font = Enum.Font.Gotham
    healthLabel.TextSize = 12
    healthLabel.Parent = tag

    -- More reliable health tracking
    local function UpdateHealth()
        -- Double-check humanoid exists and is alive
        if not humanoid or not humanoid.Parent or humanoid.Health <= 0 then
            -- Remove tag completely when player dies
            if tag and tag.Parent then
                tag:Destroy()
            end
            if ESP.Connections[character] then
                ESP.Connections[character]:Disconnect()
                ESP.Connections[character] = nil
            end
            ESP.Tags[character] = nil
            return
        end
        
        -- Update health display
        healthLabel.Text = string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
    end

    -- Set up multiple tracking methods
    local function CharacterRemoved()
        if tag and tag.Parent then
            tag:Destroy()
        end
        if ESP.Connections[character] then
            ESP.Connections[character]:Disconnect()
            ESP.Connections[character] = nil
        end
        ESP.Tags[character] = nil
    end

    -- Multiple tracking methods for reliability
    ESP.Connections[character] = {
        HealthChanged = humanoid.HealthChanged:Connect(UpdateHealth),
        Died = humanoid.Died:Connect(CharacterRemoved),
        Removed = character.AncestryChanged:Connect(function(_, parent)
            if not parent then CharacterRemoved() end
        end)
    }
    
    ESP.Tags[character] = tag
    UpdateHealth()
    tag.Parent = head

    -- Add periodic health check (in case events fail)
    task.spawn(function()
        while tag and tag.Parent and humanoid and humanoid.Parent do
            UpdateHealth()
            task.wait(1) -- Check every second
        end
    end)
end

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
        if type(connections) == "table" then
            for _, connection in pairs(connections) do
                connection:Disconnect()
            end
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
                        -- Wait for humanoid to load
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
end

-- ESP Toggle
ESPTab:CreateToggle({
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

-- [Rest of your script (Stamina, Anti-Subspace, etc.) remains unchanged...]
