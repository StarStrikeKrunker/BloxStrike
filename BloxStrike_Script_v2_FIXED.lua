-- BloxStrike Script - Made by I Went Kimbo
-- Version: v2.0 FIXED - "Strike First, Strike Hard"
-- Fixed: CoreGui access issue - now works on all executors

print("[BLOXSTRIKE DEBUG] Script starting...")

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

-- Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    wait(0.1)
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
    Humanoid = char:WaitForChild("Humanoid")
end)

-- Settings (ALL OFF BY DEFAULT)
local Settings = {
    -- Combat
    Aimbot = false,
    SilentAim = false,
    Triggerbot = false,
    ShowFOV = false,
    FOVSize = 100,
    MaxDistance = 300,
    WallCheck = true,
    TeamCheck = true,
    AimPart = "Head", -- Head, Torso, HumanoidRootPart
    
    -- ESP
    PlayerESP = false,
    PlayerNames = true,
    PlayerBoxes = true,
    PlayerDistance = true,
    PlayerHealth = true,
    PlayerTracers = false,
    PlayerChams = false,
    PlayerSkeleton = false,
    ESPTeamCheck = true, -- Red for enemies, Blue for teammates
    
    TeamESP = false,
    TeamNames = true,
    TeamBoxes = true,
    TeamDistance = true,
    TeamHealth = true,
    
    -- Movement
    WalkSpeed = 16,
    JumpPower = 50,
    LockWalkSpeed = false,
    LockJumpPower = false,
    InfiniteJump = false,
    
    -- Misc
    AntiAFK = false,
    Fullbright = false,
}

local ConfigFile = "BloxStrike_Config.json"

-- Status tracking
local Status = {
    CurrentAction = "Idle",
    Kills = 0,
    Deaths = 0,
}

-- ESP Storage
local ESPObjects = {
    Players = {},
    Teams = {},
}

-- Aimbot Storage
local FOVCircle = nil
local CurrentTarget = nil

--[[ UTILITIES ]]--

local function Notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 3,
        })
    end)
end

local function UpdateStatus(action)
    Status.CurrentAction = action
end

local function SaveConfig()
    pcall(function()
        local json = HttpService:JSONEncode(Settings)
        writefile(ConfigFile, json)
    end)
end

local function LoadConfig()
    if isfile and isfile(ConfigFile) then
        pcall(function()
            local json = readfile(ConfigFile)
            local loaded = HttpService:JSONDecode(json)
            for key, value in pairs(loaded) do
                if Settings[key] ~= nil then
                    Settings[key] = value
                end
            end
        end)
        return true
    end
    return false
end

--[[ ANTI-AFK ]]--

task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        if Settings.AntiAFK then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end)

--[[ INFINITE JUMP ]]--

local infiniteJumpConnection = nil

local function EnableInfiniteJump()
    if infiniteJumpConnection then return end
    
    infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if Settings.InfiniteJump and Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function DisableInfiniteJump()
    if infiniteJumpConnection then
        infiniteJumpConnection:Disconnect()
        infiniteJumpConnection = nil
    end
end

--[[ FULLBRIGHT ]]--

local originalAmbient = nil
local originalBrightness = nil
local originalOutdoorAmbient = nil

local function EnableFullbright()
    originalAmbient = Lighting.Ambient
    originalBrightness = Lighting.Brightness
    originalOutdoorAmbient = Lighting.OutdoorAmbient
    
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.Brightness = 2
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
end

local function DisableFullbright()
    if originalAmbient then
        Lighting.Ambient = originalAmbient
        Lighting.Brightness = originalBrightness
        Lighting.OutdoorAmbient = originalOutdoorAmbient
    end
end

--[[ AIMBOT - PROFESSIONAL & MOBILE FRIENDLY ]]--

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local aimEnabled = false
local smoothing = 0.15 -- Lower = smoother, Higher = snappier

-- Mobile hold to aim detection
if isMobile then
    local holdStart = 0
    local isHolding = false
    
    UserInputService.TouchStarted:Connect(function(touch, gameProcessed)
        if gameProcessed then return end
        holdStart = tick()
        isHolding = true
    end)
    
    UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
        isHolding = false
        if Settings.Aimbot and isHolding and (tick() - holdStart) > 0.1 then
            aimEnabled = false
        end
    end)
    
    RunService.Heartbeat:Connect(function()
        if Settings.Aimbot and isHolding and (tick() - holdStart) > 0.2 then
            aimEnabled = true
        end
    end)
else
    -- PC - Right click to aim
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            if Settings.Aimbot then
                aimEnabled = true
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            aimEnabled = false
        end
    end)
end

local function GetClosestPlayer()
    if not aimEnabled and not Settings.SilentAim then return nil end
    
    local closestPlayer = nil
    local shortestDistance = Settings.MaxDistance
    
    local camera = Workspace.CurrentCamera
    local mousePos
    
    if isMobile then
        -- Use screen center for mobile
        local viewportSize = camera.ViewportSize
        mousePos = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    else
        mousePos = UserInputService:GetMouseLocation()
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then continue end
        
        local targetPart = character:FindFirstChild(Settings.AimPart) or humanoidRootPart
        
        -- Wall check with raycast
        if Settings.WallCheck then
            local ray = Ray.new(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position).Unit * Settings.MaxDistance)
            local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {Character})
            
            if hit and not hit:IsDescendantOf(character) then
                continue
            end
        end
        
        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
        
        if not onScreen then continue end
        
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        
        if distance < Settings.FOVSize and distance < shortestDistance then
            closestPlayer = player
            shortestDistance = distance
        end
    end
    
    return closestPlayer
end

local function SmoothAim(targetPosition)
    if not targetPosition then return end
    
    local camera = Workspace.CurrentCamera
    local currentCFrame = camera.CFrame
    local targetCFrame = CFrame.new(currentCFrame.Position, targetPosition)
    
    -- Smooth interpolation
    camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothing)
end

local function UpdateAimbot()
    if not Settings.Aimbot and not Settings.SilentAim then
        CurrentTarget = nil
        return
    end
    
    CurrentTarget = GetClosestPlayer()
    
    if CurrentTarget and aimEnabled then
        local character = CurrentTarget.Character
        if character then
            local targetPart = character:FindFirstChild(Settings.AimPart) or character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                SmoothAim(targetPart.Position)
            end
        end
    end
end

local function CreateFOVCircle()
    if FOVCircle then return end
    
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 50
    FOVCircle.Radius = Settings.FOVSize
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Visible = Settings.ShowFOV
end

local function UpdateFOVCircle()
    if not FOVCircle then return end
    
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = mousePos
    FOVCircle.Radius = Settings.FOVSize
    FOVCircle.Visible = Settings.ShowFOV
end

--[[ ESP FUNCTIONS ]]--

-- RGB Color for Chams
local function GetRGBColorForChams()
    local hue = (tick() * 0.5) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- Create Chams (Highlight effect)
local function CreateChams(character, isTeammate)
    local chams = character:FindFirstChild("ESP_Chams")
    
    if not chams then
        chams = Instance.new("Highlight")
        chams.Name = "ESP_Chams"
        chams.FillTransparency = 0.5
        chams.OutlineTransparency = 0
        chams.Parent = character
    end
    
    if Settings.ESPTeamCheck then
        if isTeammate then
            chams.FillColor = Color3.fromRGB(0, 100, 255) -- Blue for teammates
            chams.OutlineColor = Color3.fromRGB(0, 150, 255)
        else
            chams.FillColor = Color3.fromRGB(255, 0, 0) -- Red for enemies
            chams.OutlineColor = Color3.fromRGB(255, 50, 50)
        end
    else
        -- RGB mode if team check is off
        local rgbColor = GetRGBColorForChams()
        chams.FillColor = rgbColor
        chams.OutlineColor = rgbColor
    end
    
    return chams
end

-- Create Skeleton
local function CreateSkeleton(character, isTeammate)
    local skeletonFolder = character:FindFirstChild("ESP_Skeleton")
    
    if skeletonFolder then
        skeletonFolder:Destroy()
    end
    
    skeletonFolder = Instance.new("Folder")
    skeletonFolder.Name = "ESP_Skeleton"
    skeletonFolder.Parent = character
    
    local color = Color3.fromRGB(255, 0, 0) -- Red for enemies
    if Settings.ESPTeamCheck and isTeammate then
        color = Color3.fromRGB(0, 100, 255) -- Blue for teammates
    end
    
    local connections = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"}
    }
    
    -- Fallback for R6
    local r6Connections = {
        {"Head", "Torso"},
        {"Torso", "Left Arm"},
        {"Torso", "Right Arm"},
        {"Torso", "Left Leg"},
        {"Torso", "Right Leg"}
    }
    
    local isR15 = character:FindFirstChild("UpperTorso") ~= nil
    local connectionsToUse = isR15 and connections or r6Connections
    
    for _, connection in pairs(connectionsToUse) do
        local part1 = character:FindFirstChild(connection[1])
        local part2 = character:FindFirstChild(connection[2])
        
        if part1 and part2 then
            local attachment1 = Instance.new("Attachment")
            attachment1.Parent = part1
            
            local attachment2 = Instance.new("Attachment")
            attachment2.Parent = part2
            
            local beam = Instance.new("Beam")
            beam.Attachment0 = attachment1
            beam.Attachment1 = attachment2
            beam.Color = ColorSequence.new(color)
            beam.FaceCamera = true
            beam.Width0 = 0.1
            beam.Width1 = 0.1
            beam.Parent = skeletonFolder
            
            attachment1.Parent = skeletonFolder
            attachment2.Parent = skeletonFolder
        end
    end
    
    return skeletonFolder
end

local function CreateESP(object, espType)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = object
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Parent = billboard
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Position = UDim2.new(0, 0, 0.4, 0)
    distanceLabel.Size = UDim2.new(1, 0, 0.3, 0)
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 12
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.Parent = billboard
    
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "HealthLabel"
    healthLabel.BackgroundTransparency = 1
    healthLabel.Position = UDim2.new(0, 0, 0.7, 0)
    healthLabel.Size = UDim2.new(1, 0, 0.3, 0)
    healthLabel.Font = Enum.Font.Gotham
    healthLabel.TextSize = 12
    healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    healthLabel.TextStrokeTransparency = 0.5
    healthLabel.Parent = billboard
    
    return billboard
end

local function UpdatePlayerESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local character = player.Character
        if not character then continue end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if not humanoidRootPart or not humanoid then continue end
        
        local isTeammate = Settings.ESPTeamCheck and player.Team == LocalPlayer.Team
        
        -- Handle Chams
        if Settings.PlayerChams then
            CreateChams(character, isTeammate)
        else
            local existingChams = character:FindFirstChild("ESP_Chams")
            if existingChams then
                existingChams:Destroy()
            end
        end
        
        -- Handle Skeleton
        if Settings.PlayerSkeleton then
            local skeleton = character:FindFirstChild("ESP_Skeleton")
            if not skeleton then
                CreateSkeleton(character, isTeammate)
            else
                -- Update skeleton color if team check changed
                local color = Color3.fromRGB(255, 0, 0)
                if Settings.ESPTeamCheck and isTeammate then
                    color = Color3.fromRGB(0, 100, 255)
                end
                
                for _, beam in pairs(skeleton:GetChildren()) do
                    if beam:IsA("Beam") then
                        beam.Color = ColorSequence.new(color)
                    end
                end
            end
        else
            local existingSkeleton = character:FindFirstChild("ESP_Skeleton")
            if existingSkeleton then
                existingSkeleton:Destroy()
            end
        end
        
        -- Handle Text ESP
        local existingESP = humanoidRootPart:FindFirstChild("ESP")
        
        if Settings.PlayerESP then
            local esp = existingESP or CreateESP(humanoidRootPart, "Player")
            
            -- Set color based on team
            local nameColor = Color3.fromRGB(255, 0, 0) -- Red for enemies
            if Settings.ESPTeamCheck and isTeammate then
                nameColor = Color3.fromRGB(0, 150, 255) -- Blue for teammates
            end
            
            if Settings.PlayerNames then
                esp.NameLabel.Text = player.Name
                esp.NameLabel.TextColor3 = nameColor
                esp.NameLabel.Visible = true
            else
                esp.NameLabel.Visible = false
            end
            
            if Settings.PlayerDistance then
                local distance = (HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                esp.DistanceLabel.Text = math.floor(distance) .. " studs"
                esp.DistanceLabel.Visible = true
            else
                esp.DistanceLabel.Visible = false
            end
            
            if Settings.PlayerHealth then
                esp.HealthLabel.Text = "HP: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                esp.HealthLabel.Visible = true
                
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                esp.HealthLabel.TextColor3 = Color3.fromRGB(
                    255 * (1 - healthPercent),
                    255 * healthPercent,
                    0
                )
            else
                esp.HealthLabel.Visible = false
            end
        else
            if existingESP then
                existingESP:Destroy()
            end
        end
    end
end

-- Update Chams RGB colors
task.spawn(function()
    while wait(0.03) do
        if Settings.PlayerChams and not Settings.ESPTeamCheck then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local chams = player.Character:FindFirstChild("ESP_Chams")
                    if chams then
                        local rgbColor = GetRGBColorForChams()
                        chams.FillColor = rgbColor
                        chams.OutlineColor = rgbColor
                    end
                end
            end
        end
    end
end)

--[[ MOVEMENT MODIFIERS ]]--

RunService.Heartbeat:Connect(function()
    if not Humanoid then return end
    
    if Settings.LockWalkSpeed then
        Humanoid.WalkSpeed = Settings.WalkSpeed
    end
    
    if Settings.LockJumpPower then
        Humanoid.JumpPower = Settings.JumpPower
    end
end)

--[[ MAIN LOOPS ]]--

-- Aimbot Loop
task.spawn(function()
    while wait() do
        if Settings.Aimbot or Settings.SilentAim then
            UpdateAimbot()
        end
        
        if FOVCircle then
            UpdateFOVCircle()
        end
    end
end)

-- ESP Loop
task.spawn(function()
    while wait(0.5) do
        UpdatePlayerESP()
    end
end)

--[[ KEY SYSTEM ]]--

local validKeys = {
    "BLOXSTRIKE2026",
    "UNIVERSALFARM",
    "STRIKE2026"
}

local function ShowKeySystem()
    local keyValid = false
    
    -- Fix for CoreGui access - Try CoreGui first, fallback to PlayerGui
    local GuiParent
    local success = pcall(function()
        GuiParent = game:GetService("CoreGui")
    end)
    if not success or not GuiParent then
        print("[BLOXSTRIKE] CoreGui not accessible, using PlayerGui")
        GuiParent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "BloxStrikeKeySystem"
    KeyGui.ResetOnSpawn = false
    KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KeyGui.Parent = GuiParent
    
    -- Main Frame
    local KeyFrame = Instance.new("Frame")
    KeyFrame.Parent = KeyGui
    KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    KeyFrame.BorderSizePixel = 0
    KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    KeyFrame.Size = UDim2.new(0, 400, 0, 300)
    KeyFrame.ClipsDescendants = true
    
    local KeyCorner = Instance.new("UICorner")
    KeyCorner.CornerRadius = UDim.new(0, 12)
    KeyCorner.Parent = KeyFrame
    
    -- RGB Border
    local BorderFrame = Instance.new("Frame")
    BorderFrame.Parent = KeyFrame
    BorderFrame.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    BorderFrame.BorderSizePixel = 0
    BorderFrame.Position = UDim2.new(0, -2, 0, -2)
    BorderFrame.Size = UDim2.new(1, 4, 1, 4)
    BorderFrame.ZIndex = 0
    
    local BorderCorner = Instance.new("UICorner")
    BorderCorner.CornerRadius = UDim.new(0, 12)
    BorderCorner.Parent = BorderFrame
    
    -- RGB Animation
    local hue = 0
    task.spawn(function()
        while KeyFrame.Parent do
            hue = (hue + 0.01) % 1
            BorderFrame.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            wait()
        end
    end)
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Parent = KeyFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 15)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🎮 BLOXSTRIKE SCRIPT"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.ZIndex = 2
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Parent = KeyFrame
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0, 0, 0, 55)
    Subtitle.Size = UDim2.new(1, 0, 0, 20)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "Enter Key to Continue"
    Subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    Subtitle.TextSize = 12
    Subtitle.ZIndex = 2
    
    -- Key Input Box
    local KeyBox = Instance.new("TextBox")
    KeyBox.Parent = KeyFrame
    KeyBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    KeyBox.BorderSizePixel = 0
    KeyBox.Position = UDim2.new(0.5, -150, 0, 100)
    KeyBox.Size = UDim2.new(0, 300, 0, 40)
    KeyBox.Font = Enum.Font.Gotham
    KeyBox.PlaceholderText = "Enter your key here..."
    KeyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    KeyBox.Text = ""
    KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyBox.TextSize = 14
    KeyBox.ClearTextOnFocus = false
    KeyBox.ZIndex = 2
    
    local KeyBoxCorner = Instance.new("UICorner")
    KeyBoxCorner.CornerRadius = UDim.new(0, 8)
    KeyBoxCorner.Parent = KeyBox
    
    -- Submit Button
    local SubmitBtn = Instance.new("TextButton")
    SubmitBtn.Parent = KeyFrame
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    SubmitBtn.BorderSizePixel = 0
    SubmitBtn.Position = UDim2.new(0.5, -120, 0, 160)
    SubmitBtn.Size = UDim2.new(0, 100, 0, 35)
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.Text = "✓ Submit"
    SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitBtn.TextSize = 14
    SubmitBtn.AutoButtonColor = false
    SubmitBtn.ZIndex = 2
    
    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = UDim.new(0, 8)
    SubmitCorner.Parent = SubmitBtn
    
    -- Get Key Button
    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Parent = KeyFrame
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    GetKeyBtn.BorderSizePixel = 0
    GetKeyBtn.Position = UDim2.new(0.5, 20, 0, 160)
    GetKeyBtn.Size = UDim2.new(0, 100, 0, 35)
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.Text = "🔑 Get Key"
    GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyBtn.TextSize = 14
    GetKeyBtn.AutoButtonColor = false
    GetKeyBtn.ZIndex = 2
    
    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 8)
    GetKeyCorner.Parent = GetKeyBtn
    
    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Parent = KeyFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 0, 215)
    StatusLabel.Size = UDim2.new(1, 0, 0, 30)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    StatusLabel.TextSize = 12
    StatusLabel.ZIndex = 2
    
    -- Info Label
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Parent = KeyFrame
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Position = UDim2.new(0, 0, 1, -40)
    InfoLabel.Size = UDim2.new(1, 0, 0, 20)
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.Text = "Made by I Went Kimbo | v2.0 FIXED"
    InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    InfoLabel.TextSize = 10
    InfoLabel.ZIndex = 2
    
    -- Button Hover Effects
    SubmitBtn.MouseEnter:Connect(function()
        TweenService:Create(SubmitBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 180, 60)}):Play()
    end)
    
    SubmitBtn.MouseLeave:Connect(function()
        TweenService:Create(SubmitBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 150, 50)}):Play()
    end)
    
    GetKeyBtn.MouseEnter:Connect(function()
        TweenService:Create(GetKeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 120, 220)}):Play()
    end)
    
    GetKeyBtn.MouseLeave:Connect(function()
        TweenService:Create(GetKeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 100, 200)}):Play()
    end)
    
    -- Get Key Button Click
    GetKeyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            setclipboard("https://discord.gg/bloxstrike-keys")
        end)
        StatusLabel.Text = "✓ Discord link copied to clipboard!"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end)
    
    -- Submit Button Click
    SubmitBtn.MouseButton1Click:Connect(function()
        local enteredKey = KeyBox.Text
        
        local isValid = false
        for _, validKey in pairs(validKeys) do
            if enteredKey == validKey then
                isValid = true
                break
            end
        end
        
        if isValid then
            StatusLabel.Text = "✓ Key Valid! Loading..."
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            keyValid = true
            
            wait(1)
            KeyGui:Destroy()
        else
            StatusLabel.Text = "✗ Invalid Key! Try again."
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            
            -- Shake animation
            for i = 1, 5 do
                KeyFrame.Position = KeyFrame.Position + UDim2.new(0, 10, 0, 0)
                wait(0.05)
                KeyFrame.Position = KeyFrame.Position - UDim2.new(0, 10, 0, 0)
                wait(0.05)
            end
        end
    end)
    
    -- Enter key to submit
    KeyBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            SubmitBtn.MouseButton1Click:Fire()
        end
    end)
    
    repeat wait() until keyValid or not KeyGui.Parent
    
    return keyValid
end

--[[ INTRO ]]--

local function ShowIntro()
    -- Fix for CoreGui access - Try CoreGui first, fallback to PlayerGui
    local GuiParent
    local success = pcall(function()
        GuiParent = game:GetService("CoreGui")
    end)
    if not success or not GuiParent then
        print("[BLOXSTRIKE] CoreGui not accessible, using PlayerGui")
        GuiParent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local IntroGui = Instance.new("ScreenGui")
    IntroGui.Name = "BloxStrikeIntro"
    IntroGui.ResetOnSpawn = false
    IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    IntroGui.Parent = GuiParent
    
    local IntroFrame = Instance.new("Frame")
    IntroFrame.Parent = IntroGui
    IntroFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    IntroFrame.BorderSizePixel = 0
    IntroFrame.Size = UDim2.new(1, 0, 1, 0)
    IntroFrame.ZIndex = 10
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = IntroFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0.5, 0, 0.4, 0)
    TitleLabel.Size = UDim2.new(0, 600, 0, 80)
    TitleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "BLOXSTRIKE"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 60
    TitleLabel.TextTransparency = 1
    TitleLabel.ZIndex = 11
    
    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Parent = IntroFrame
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    SubtitleLabel.Size = UDim2.new(0, 400, 0, 40)
    SubtitleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.Text = "ESP & Combat Script v2.0 FIXED"
    SubtitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SubtitleLabel.TextSize = 20
    SubtitleLabel.TextTransparency = 1
    SubtitleLabel.ZIndex = 11
    
    local AuthorLabel = Instance.new("TextLabel")
    AuthorLabel.Parent = IntroFrame
    AuthorLabel.BackgroundTransparency = 1
    AuthorLabel.Position = UDim2.new(0.5, 0, 0.6, 0)
    AuthorLabel.Size = UDim2.new(0, 300, 0, 30)
    AuthorLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    AuthorLabel.Font = Enum.Font.GothamBold
    AuthorLabel.Text = "Made by I Went Kimbo"
    AuthorLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    AuthorLabel.TextSize = 16
    AuthorLabel.TextTransparency = 1
    AuthorLabel.ZIndex = 11
    
    -- RGB Effect
    task.spawn(function()
        local hue = 0
        while IntroFrame.Parent do
            hue = (hue + 0.01) % 1
            TitleLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
            wait()
        end
    end)
    
    -- Fade in
    TweenService:Create(TitleLabel, TweenInfo.new(1.5), {TextTransparency = 0}):Play()
    wait(0.5)
    TweenService:Create(SubtitleLabel, TweenInfo.new(1.5), {TextTransparency = 0}):Play()
    wait(0.5)
    TweenService:Create(AuthorLabel, TweenInfo.new(1.5), {TextTransparency = 0}):Play()
    
    wait(3)
    
    -- Fade out
    TweenService:Create(TitleLabel, TweenInfo.new(1), {TextTransparency = 1}):Play()
    TweenService:Create(SubtitleLabel, TweenInfo.new(1), {TextTransparency = 1}):Play()
    TweenService:Create(AuthorLabel, TweenInfo.new(1), {TextTransparency = 1}):Play()
    TweenService:Create(IntroFrame, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
    
    wait(1)
    IntroGui:Destroy()
end

--[[ GUI CREATION ]]--

local function CreateGUI()
    -- Fix for CoreGui access - Try CoreGui first, fallback to PlayerGui
    local GuiParent
    local success = pcall(function()
        GuiParent = game:GetService("CoreGui")
    end)
    if not success or not GuiParent then
        print("[BLOXSTRIKE] CoreGui not accessible, using PlayerGui")
        GuiParent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BloxStrikeUniversalFarm"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = GuiParent
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
    MainFrame.Size = UDim2.new(0, 700, 0, 450)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    -- RGB Border
    local function GetRGBColor()
        local hue = tick() % 5 / 5
        return Color3.fromHSV(hue, 1, 1)
    end
    
    local BorderFrame = Instance.new("Frame")
    BorderFrame.Parent = MainFrame
    BorderFrame.BackgroundColor3 = GetRGBColor()
    BorderFrame.BorderSizePixel = 0
    BorderFrame.Position = UDim2.new(0, -2, 0, -2)
    BorderFrame.Size = UDim2.new(1, 4, 1, 4)
    BorderFrame.ZIndex = 0
    
    local BorderCorner = Instance.new("UICorner")
    BorderCorner.CornerRadius = UDim.new(0, 12)
    BorderCorner.Parent = BorderFrame
    
    task.spawn(function()
        while BorderFrame.Parent do
            BorderFrame.BackgroundColor3 = GetRGBColor()
            wait()
        end
    end)
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.ZIndex = 2
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    local TitleFix = Instance.new("Frame")
    TitleFix.Parent = TitleBar
    TitleFix.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    TitleFix.BorderSizePixel = 0
    TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
    TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
    TitleFix.ZIndex = 2
    
    local Title = Instance.new("TextLabel")
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(0, 400, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🎮 BLOXSTRIKE SCRIPT"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 3
    
    local Version = Instance.new("TextLabel")
    Version.Parent = TitleBar
    Version.BackgroundTransparency = 1
    Version.Position = UDim2.new(0, 15, 0, 25)
    Version.Size = UDim2.new(0, 200, 0, 20)
    Version.Font = Enum.Font.Gotham
    Version.Text = "v2.0 FIXED | Made by I Went Kimbo"
    Version.TextColor3 = Color3.fromRGB(150, 150, 160)
    Version.TextSize = 10
    Version.TextXAlignment = Enum.TextXAlignment.Left
    Version.ZIndex = 3
    
    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = TitleBar
    MinBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
    MinBtn.BorderSizePixel = 0
    MinBtn.Position = UDim2.new(1, -80, 0.5, -12)
    MinBtn.Size = UDim2.new(0, 25, 0, 25)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    MinBtn.TextSize = 18
    MinBtn.AutoButtonColor = false
    MinBtn.ZIndex = 3
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(1, 0)
    MinCorner.Parent = MinBtn
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = TitleBar
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(1, -45, 0.5, -12)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 18
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 3
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(1, 0)
    CloseCorner.Parent = CloseBtn
    
    -- Minimize Icon (shows when minimized)
    local MinimizeIcon = Instance.new("TextButton")
    MinimizeIcon.Parent = ScreenGui
    MinimizeIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    MinimizeIcon.BorderSizePixel = 0
    MinimizeIcon.Position = UDim2.new(0, 10, 0.5, -25)
    MinimizeIcon.Size = UDim2.new(0, 50, 0, 50)
    MinimizeIcon.Font = Enum.Font.GothamBold
    MinimizeIcon.Text = "🎮"
    MinimizeIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeIcon.TextSize = 24
    MinimizeIcon.Visible = false
    MinimizeIcon.AutoButtonColor = false
    
    local MinIconCorner = Instance.new("UICorner")
    MinIconCorner.CornerRadius = UDim.new(1, 0)
    MinIconCorner.Parent = MinimizeIcon
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.Size = UDim2.new(1, 0, 0, 45)
    TabContainer.ZIndex = 2
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 10, 0, 105)
    ContentContainer.Size = UDim2.new(1, -20, 1, -115)
    ContentContainer.ZIndex = 1
    
    -- Pages
    local pages = {}
    
    --[[ UI CREATION FUNCTIONS ]]--
    
    local function CreateToggle(parent, text, position, setting)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Parent = parent
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Position = position
        ToggleFrame.Size = UDim2.new(0, 300, 0, 35)
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 8)
        ToggleCorner.Parent = ToggleFrame
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
        ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.Text = text
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.TextSize = 12
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Parent = ToggleFrame
        ToggleButton.BackgroundColor3 = Settings[setting] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 70)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
        ToggleButton.Size = UDim2.new(0, 40, 0, 20)
        ToggleButton.Text = ""
        ToggleButton.AutoButtonColor = false
        
        local ToggleBtnCorner = Instance.new("UICorner")
        ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
        ToggleBtnCorner.Parent = ToggleButton
        
        local ToggleIndicator = Instance.new("Frame")
        ToggleIndicator.Parent = ToggleButton
        ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleIndicator.BorderSizePixel = 0
        ToggleIndicator.Position = Settings[setting] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(1, 0)
        IndicatorCorner.Parent = ToggleIndicator
        
        ToggleButton.MouseButton1Click:Connect(function()
            Settings[setting] = not Settings[setting]
            
            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Settings[setting] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 70)
            }):Play()
            
            TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                Position = Settings[setting] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }):Play()
            
            -- Apply specific settings
            if setting == "InfiniteJump" then
                if Settings[setting] then
                    EnableInfiniteJump()
                else
                    DisableInfiniteJump()
                end
            elseif setting == "Fullbright" then
                if Settings[setting] then
                    EnableFullbright()
                else
                    DisableFullbright()
                end
            elseif setting == "ShowFOV" then
                if FOVCircle then
                    FOVCircle.Visible = Settings[setting]
                end
            end
            
            SaveConfig()
        end)
        
        return ToggleFrame
    end
    
    local function CreateSlider(parent, text, position, setting, min, max, increment)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Parent = parent
        SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Position = position
        SliderFrame.Size = UDim2.new(0, 300, 0, 60)
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 8)
        SliderCorner.Parent = SliderFrame
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Parent = SliderFrame
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Position = UDim2.new(0, 10, 0, 5)
        SliderLabel.Size = UDim2.new(1, -20, 0, 15)
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.Text = text
        SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderLabel.TextSize = 12
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Parent = SliderFrame
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Position = UDim2.new(1, -60, 0, 5)
        ValueLabel.Size = UDim2.new(0, 50, 0, 15)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.Text = tostring(Settings[setting])
        ValueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        ValueLabel.TextSize = 12
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        local SliderBar = Instance.new("Frame")
        SliderBar.Parent = SliderFrame
        SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        SliderBar.BorderSizePixel = 0
        SliderBar.Position = UDim2.new(0, 10, 0, 30)
        SliderBar.Size = UDim2.new(1, -20, 0, 6)
        
        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(1, 0)
        BarCorner.Parent = SliderBar
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Parent = SliderBar
        SliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
        SliderFill.BorderSizePixel = 0
        SliderFill.Size = UDim2.new((Settings[setting] - min) / (max - min), 0, 1, 0)
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = SliderFill
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Parent = SliderBar
        SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderButton.BorderSizePixel = 0
        SliderButton.Position = UDim2.new((Settings[setting] - min) / (max - min), -8, 0.5, -8)
        SliderButton.Size = UDim2.new(0, 16, 0, 16)
        SliderButton.Text = ""
        SliderButton.AutoButtonColor = false
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(1, 0)
        BtnCorner.Parent = SliderButton
        
        local dragging = false
        
        SliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        SliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        
        RunService.RenderStepped:Connect(function()
            if dragging then
                local mouse = UserInputService:GetMouseLocation()
                local barPos = SliderBar.AbsolutePosition.X
                local barSize = SliderBar.AbsoluteSize.X
                local relativePos = math.clamp(mouse.X - barPos, 0, barSize)
                local percentage = relativePos / barSize
                
                local value = math.floor((percentage * (max - min) + min) / increment + 0.5) * increment
                Settings[setting] = value
                
                ValueLabel.Text = tostring(value)
                SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                SliderButton.Position = UDim2.new(percentage, -8, 0.5, -8)
                
                SaveConfig()
            end
        end)
        
        return SliderFrame
    end
    
    local function CreateButton(parent, text, position, size, color, callback)
        local Button = Instance.new("TextButton")
        Button.Parent = parent
        Button.BackgroundColor3 = color
        Button.BorderSizePixel = 0
        Button.Position = position
        Button.Size = size
        Button.Font = Enum.Font.GothamBold
        Button.Text = text
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 12
        Button.AutoButtonColor = false
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 8)
        BtnCorner.Parent = Button
        
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(
                    math.min(color.R * 255 + 20, 255) / 255,
                    math.min(color.G * 255 + 20, 255) / 255,
                    math.min(color.B * 255 + 20, 255) / 255
                )
            }):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        end)
        
        Button.MouseButton1Click:Connect(callback)
        
        return Button
    end
    
    local function CreateDropdown(parent, text, position, setting, options)
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Parent = parent
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        DropdownFrame.BorderSizePixel = 0
        DropdownFrame.Position = position
        DropdownFrame.Size = UDim2.new(0, 300, 0, 35)
        DropdownFrame.ClipsDescendants = false
        DropdownFrame.ZIndex = 5
        
        local DropCorner = Instance.new("UICorner")
        DropCorner.CornerRadius = UDim.new(0, 8)
        DropCorner.Parent = DropdownFrame
        
        local DropLabel = Instance.new("TextLabel")
        DropLabel.Parent = DropdownFrame
        DropLabel.BackgroundTransparency = 1
        DropLabel.Position = UDim2.new(0, 10, 0, 0)
        DropLabel.Size = UDim2.new(1, -60, 1, 0)
        DropLabel.Font = Enum.Font.Gotham
        DropLabel.Text = text
        DropLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropLabel.TextSize = 12
        DropLabel.TextXAlignment = Enum.TextXAlignment.Left
        DropLabel.ZIndex = 6
        
        local DropButton = Instance.new("TextButton")
        DropButton.Parent = DropdownFrame
        DropButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        DropButton.BorderSizePixel = 0
        DropButton.Position = UDim2.new(1, -100, 0.5, -12)
        DropButton.Size = UDim2.new(0, 95, 0, 24)
        DropButton.Font = Enum.Font.Gotham
        DropButton.Text = Settings[setting]
        DropButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropButton.TextSize = 11
        DropButton.AutoButtonColor = false
        DropButton.ZIndex = 6
        
        local DropBtnCorner = Instance.new("UICorner")
        DropBtnCorner.CornerRadius = UDim.new(0, 6)
        DropBtnCorner.Parent = DropButton
        
        local OptionsFrame = Instance.new("Frame")
        OptionsFrame.Parent = DropdownFrame
        OptionsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        OptionsFrame.BorderSizePixel = 0
        OptionsFrame.Position = UDim2.new(1, -100, 1, 2)
        OptionsFrame.Size = UDim2.new(0, 95, 0, #options * 25)
        OptionsFrame.Visible = false
        OptionsFrame.ZIndex = 7
        
        local OptsCorner = Instance.new("UICorner")
        OptsCorner.CornerRadius = UDim.new(0, 6)
        OptsCorner.Parent = OptionsFrame
        
        for i, option in ipairs(options) do
            local OptionBtn = Instance.new("TextButton")
            OptionBtn.Parent = OptionsFrame
            OptionBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            OptionBtn.BorderSizePixel = 0
            OptionBtn.Position = UDim2.new(0, 0, 0, (i-1) * 25)
            OptionBtn.Size = UDim2.new(1, 0, 0, 25)
            OptionBtn.Font = Enum.Font.Gotham
            OptionBtn.Text = option
            OptionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            OptionBtn.TextSize = 11
            OptionBtn.AutoButtonColor = false
            OptionBtn.ZIndex = 8
            
            OptionBtn.MouseEnter:Connect(function()
                OptionBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            end)
            
            OptionBtn.MouseLeave:Connect(function()
                OptionBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            end)
            
            OptionBtn.MouseButton1Click:Connect(function()
                Settings[setting] = option
                DropButton.Text = option
                OptionsFrame.Visible = false
                SaveConfig()
            end)
        end
        
        DropButton.MouseButton1Click:Connect(function()
            OptionsFrame.Visible = not OptionsFrame.Visible
        end)
        
        return DropdownFrame
    end
    
    --[[ CREATE PAGES ]]--
    
    -- HOME PAGE
    local HomePage = Instance.new("Frame")
    HomePage.Parent = ContentContainer
    HomePage.BackgroundTransparency = 1
    HomePage.Size = UDim2.new(1, 0, 1, 0)
    HomePage.Visible = true
    pages["Home"] = HomePage
    
    local WelcomeLabel = Instance.new("TextLabel")
    WelcomeLabel.Parent = HomePage
    WelcomeLabel.BackgroundTransparency = 1
    WelcomeLabel.Position = UDim2.new(0, 0, 0, 10)
    WelcomeLabel.Size = UDim2.new(1, 0, 0, 40)
    WelcomeLabel.Font = Enum.Font.GothamBold
    WelcomeLabel.Text = "Welcome to BloxStrike Script!"
    WelcomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    WelcomeLabel.TextSize = 20
    
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Parent = HomePage
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Position = UDim2.new(0, 0, 0, 60)
    InfoLabel.Size = UDim2.new(1, 0, 0, 100)
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.Text = "This script provides ESP, Combat features, and Movement enhancements for BloxStrike.\n\nUse the tabs above to access different features.\n\nRemember to configure your settings carefully!"
    InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    InfoLabel.TextSize = 14
    InfoLabel.TextWrapped = true
    InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    local statsY = 180
    local function CreateStatLabel(text, yOffset)
        local label = Instance.new("TextLabel")
        label.Parent = HomePage
        label.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        label.BorderSizePixel = 0
        label.Position = UDim2.new(0, 10, 0, statsY + yOffset)
        label.Size = UDim2.new(0, 320, 0, 30)
        label.Font = Enum.Font.GothamBold
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 12
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = label
        
        return label
    end
    
    local KillsLabel = CreateStatLabel("Kills: 0", 0)
    local StatusLabel = CreateStatLabel("Status: Idle", 40)
    
    -- Update stats
    task.spawn(function()
        while wait(0.5) do
            KillsLabel.Text = "Kills: " .. Status.Kills
            StatusLabel.Text = "Status: " .. Status.CurrentAction
        end
    end)
    
    -- COMBAT PAGE
    local CombatPage = Instance.new("Frame")
    CombatPage.Parent = ContentContainer
    CombatPage.BackgroundTransparency = 1
    CombatPage.Size = UDim2.new(1, 0, 1, 0)
    CombatPage.Visible = false
    pages["Combat"] = CombatPage
    
    CreateToggle(CombatPage, "Aimbot", UDim2.new(0, 10, 0, 5), "Aimbot")
    CreateToggle(CombatPage, "Silent Aim", UDim2.new(0, 10, 0, 45), "SilentAim")
    CreateToggle(CombatPage, "Triggerbot", UDim2.new(0, 10, 0, 85), "Triggerbot")
    CreateToggle(CombatPage, "Show FOV Circle", UDim2.new(0, 10, 0, 125), "ShowFOV")
    CreateToggle(CombatPage, "Wall Check", UDim2.new(0, 10, 0, 165), "WallCheck")
    CreateToggle(CombatPage, "Team Check", UDim2.new(0, 10, 0, 205), "TeamCheck")
    
    CreateSlider(CombatPage, "FOV Size", UDim2.new(0, 350, 0, 5), "FOVSize", 50, 300, 10)
    CreateSlider(CombatPage, "Max Distance", UDim2.new(0, 350, 0, 75), "MaxDistance", 100, 500, 50)
    CreateDropdown(CombatPage, "Aim Part", UDim2.new(0, 350, 0, 145), "AimPart", {"Head", "Torso", "HumanoidRootPart"})
    
    -- ESP PAGE
    local ESPPage = Instance.new("Frame")
    ESPPage.Parent = ContentContainer
    ESPPage.BackgroundTransparency = 1
    ESPPage.Size = UDim2.new(1, 0, 1, 0)
    ESPPage.Visible = false
    pages["ESP"] = ESPPage
    
    CreateToggle(ESPPage, "Player ESP", UDim2.new(0, 10, 0, 5), "PlayerESP")
    CreateToggle(ESPPage, "Show Names", UDim2.new(0, 10, 0, 45), "PlayerNames")
    CreateToggle(ESPPage, "Show Boxes", UDim2.new(0, 10, 0, 85), "PlayerBoxes")
    CreateToggle(ESPPage, "Show Distance", UDim2.new(0, 10, 0, 125), "PlayerDistance")
    CreateToggle(ESPPage, "Show Health", UDim2.new(0, 10, 0, 165), "PlayerHealth")
    CreateToggle(ESPPage, "Show Tracers", UDim2.new(0, 10, 0, 205), "PlayerTracers")
    
    CreateToggle(ESPPage, "RGB Chams", UDim2.new(0, 350, 0, 5), "PlayerChams")
    CreateToggle(ESPPage, "Skeleton ESP", UDim2.new(0, 350, 0, 45), "PlayerSkeleton")
    CreateToggle(ESPPage, "Team Check (Red/Blue)", UDim2.new(0, 350, 0, 85), "ESPTeamCheck")
    
    -- MOVEMENT PAGE
    local MovementPage = Instance.new("Frame")
    MovementPage.Parent = ContentContainer
    MovementPage.BackgroundTransparency = 1
    MovementPage.Size = UDim2.new(1, 0, 1, 0)
    MovementPage.Visible = false
    pages["Movement"] = MovementPage
    
    CreateToggle(MovementPage, "Lock Walk Speed", UDim2.new(0, 10, 0, 5), "LockWalkSpeed")
    CreateToggle(MovementPage, "Lock Jump Power", UDim2.new(0, 10, 0, 45), "LockJumpPower")
    CreateToggle(MovementPage, "Infinite Jump", UDim2.new(0, 10, 0, 85), "InfiniteJump")
    
    CreateSlider(MovementPage, "Walk Speed", UDim2.new(0, 350, 0, 5), "WalkSpeed", 16, 100, 1)
    CreateSlider(MovementPage, "Jump Power", UDim2.new(0, 350, 0, 75), "JumpPower", 50, 120, 5)
    
    -- MISC PAGE
    local MiscPage = Instance.new("Frame")
    MiscPage.Parent = ContentContainer
    MiscPage.BackgroundTransparency = 1
    MiscPage.Size = UDim2.new(1, 0, 1, 0)
    MiscPage.Visible = false
    pages["Misc"] = MiscPage
    
    CreateToggle(MiscPage, "Anti-AFK", UDim2.new(0, 10, 0, 5), "AntiAFK")
    CreateToggle(MiscPage, "Fullbright", UDim2.new(0, 10, 0, 45), "Fullbright")
    
    CreateButton(MiscPage, "💾 Save Config", UDim2.new(0, 350, 0, 5), UDim2.new(0, 140, 0, 35), Color3.fromRGB(50, 150, 50), function()
        SaveConfig()
        Notify("Config", "Configuration saved!")
    end)
    
    CreateButton(MiscPage, "📁 Load Config", UDim2.new(0, 500, 0, 5), UDim2.new(0, 140, 0, 35), Color3.fromRGB(50, 100, 200), function()
        LoadConfig()
        Notify("Config", "Configuration loaded!")
    end)
    
    CreateButton(MiscPage, "🔄 Rejoin Server", UDim2.new(0, 350, 0, 50), UDim2.new(0, 140, 0, 35), Color3.fromRGB(200, 100, 50), function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
    
    CreateButton(MiscPage, "🎲 Random Server", UDim2.new(0, 500, 0, 50), UDim2.new(0, 140, 0, 35), Color3.fromRGB(150, 100, 200), function()
        local TeleportService = game:GetService("TeleportService")
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in pairs(servers.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end)
    
    -- Create Tabs
    local tabs = {"Home", "Combat", "ESP", "Movement", "Misc"}
    local currentTab = "Home"
    
    for i, tabName in ipairs(tabs) do
        local isActive = tabName == currentTab
        
        local tabButton = Instance.new("TextButton")
        tabButton.Parent = TabContainer
        tabButton.BackgroundColor3 = isActive and Color3.fromRGB(30, 30, 40) or Color3.fromRGB(20, 20, 28)
        tabButton.Position = UDim2.new((i-1) / #tabs, 2, 0, 7)
        tabButton.Size = UDim2.new(1 / #tabs, -4, 0, 31)
        tabButton.Font = Enum.Font.GothamBold
        tabButton.Text = tabName
        tabButton.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)
        tabButton.TextSize = 11
        tabButton.AutoButtonColor = false
        tabButton.ZIndex = 3
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabButton
        
        local indicator = Instance.new("Frame")
        indicator.Parent = tabButton
        indicator.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
        indicator.BorderSizePixel = 0
        indicator.Position = UDim2.new(0, 0, 1, -3)
        indicator.Size = UDim2.new(1, 0, 0, 3)
        indicator.Visible = isActive
        indicator.ZIndex = 4
        
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(0, 2)
        indicatorCorner.Parent = indicator
        
        if isActive then
            task.spawn(function()
                while indicator and indicator.Visible do
                    indicator.BackgroundColor3 = GetRGBColor()
                    wait()
                end
            end)
        end
        
        tabButton.MouseButton1Click:Connect(function()
            for _, page in pairs(pages) do
                page.Visible = false
            end
            
            pages[tabName].Visible = true
            currentTab = tabName
            
            for _, child in pairs(TabContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    local isNowActive = child.Text == tabName
                    
                    TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = isNowActive and Color3.fromRGB(30, 30, 40) or Color3.fromRGB(20, 20, 28),
                        TextColor3 = isNowActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)
                    }):Play()
                    
                    local ind = child:FindFirstChildOfClass("Frame")
                    if ind then
                        ind.Visible = isNowActive
                        if isNowActive then
                            task.spawn(function()
                                while ind and ind.Visible do
                                    ind.BackgroundColor3 = GetRGBColor()
                                    wait()
                                end
                            end)
                        end
                    end
                end
            end
        end)
        
        tabButton.MouseEnter:Connect(function()
            if tabButton.Text ~= currentTab then
                TweenService:Create(tabButton, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(25, 25, 33)
                }):Play()
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if tabButton.Text ~= currentTab then
                TweenService:Create(tabButton, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(20, 20, 28)
                }):Play()
            end
        end)
    end
    
    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        MinimizeIcon.Visible = true
    end)
    
    MinimizeIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MinimizeIcon.Visible = false
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Create FOV Circle
    CreateFOVCircle()
    
    LoadConfig()
end

--[[ INIT ]]--

print("[BLOXSTRIKE] Loading BloxStrike Script v2.0 FIXED...")

ShowIntro()

wait(4)

print("[BLOXSTRIKE] Awaiting key verification...")
local keyValid = ShowKeySystem()

if keyValid then
    print("[BLOXSTRIKE] ✓ Key verified! Loading GUI...")
    
    CreateGUI()
    
    Notify("BloxStrike", "Script loaded successfully!")
    print("========================================")
    print("🎮 BloxStrike Script Loaded")
    print("📝 Made by I Went Kimbo")
    print("✅ All systems active")
    print("========================================")
else
    print("[BLOXSTRIKE] ✗ Invalid key. Script terminated.")
end
