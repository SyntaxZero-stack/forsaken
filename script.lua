-- Set clipboard content
setclipboard("https://linkunlocker.com/just-another-forsaken-script-0FJGK")

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
-- ESP SYSTEM
-- =============================================
local ESP = {
    Enabled = false,
    Tags = {},
    Connections = {},
    Colors = {
        Survivors = Color3.fromRGB(0, 255, 0),
        Killers = Color3.fromRGB(255, 0, 0)
    },
    Settings = {
        ShowDistance = true,
        ShowHealth = true
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

-- ESP Functions
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

    -- Update function
    local function UpdateTag()
        if not humanoid or not humanoid.Parent or humanoid.Health <= 0 then
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

        -- Update distance
        if distanceLabel then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local distance = hrp and math.floor((head.Position - hrp.Position).Magnitude) or "N/A"
            distanceLabel.Text = "Distance: "..tostring(distance).."m"
        end

        -- Update health
        if healthLabel then
            healthLabel.Text = string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth))
        end
    end

    -- Setup connections
    ESP.Connections[character] = {
        humanoid.HealthChanged:Connect(UpdateTag),
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

-- Fullbright
local fullbrightEnabled = false

local FullbrightToggle = MiscTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = fullbrightEnabled,
    Flag = "FullbrightToggle",
    Callback = function(value)
        fullbrightEnabled = value
        if value then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            Lighting.ClockTime = 12
            Lighting.GlobalShadows = false
            Lighting.Brightness = 2
            Rayfield:Notify({
                Title = "Fullbright",
                Content = "Enabled - Everything is now visible",
                Duration = 3,
            })
        else
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
            Lighting.GlobalShadows = true
            Lighting.Brightness = 1
            Rayfield:Notify({
                Title = "Fullbright",
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
                    }
                },
                Settings = {
                    ShowDistance = ESP.Settings.ShowDistance,
                    ShowHealth = ESP.Settings.ShowHealth
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
            end
            
            if config.ESP.Settings then
                ESP.Settings.ShowDistance = config.ESP.Settings.ShowDistance or true
                ESPDistanceToggle:Set(ESP.Settings.ShowDistance)
                
                ESP.Settings.ShowHealth = config.ESP.Settings.ShowHealth or true
                ESPHealthToggle:Set(ESP.Settings.ShowHealth)
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
