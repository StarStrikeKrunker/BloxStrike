-- BloxStrike FPS Script 2026 - Made by I Went Kimbo
-- Version: v1 BETA - "Tactical Superiority"

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

-- Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    wait(0.1)
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
end)

-- Settings (ALL OFF BY DEFAULT)
local Settings = {
    -- Combat
    SilentAim = false,
    Triggerbot = false,
    AutoHeadshot = false,
    ShowFOV = false,
    FOVSize = 100,
    MaxDistance = 500,  -- Max aimbot distance (studs)
    WallCheck = true,
    TeamCheck = true,
    
    -- Recoil & Accuracy
    NoRecoil = false,
    NoSpread = false,
    InfiniteAmmo = false,
    RapidFire = false,
    AutoReload = false,
    
    -- Movement
    WalkSpeed = 16,
    JumpPower = 50,
    LockWalkSpeed = false,
    LockJumpPower = false,
    InfiniteJump = false,
    Noclip = false,
    BunnyHop = false,
    
    -- Visuals
    Fullbright = false,
    NoFlash = false,
    NoSmoke = false,
    ThirdPerson = false,
    ThirdPersonDistance = 10,
    
    -- Enemy ESP
    EnemyESP = false,
    EnemyNames = false,
    EnemyBoxes = false,
    EnemyDistance = false,
    EnemyHealth = false,
    EnemyWeapon = false,
    
    -- Teammate ESP
    TeamESP = false,
    TeamNames = false,
    TeamBoxes = false,
    TeamDistance = false,
    TeamHealth = false,
    
    -- Weapon & Item ESP
    WeaponESP = false,
    BombESP = false,
    
    -- Auto Features
    AutoBuyWeapons = false,
    AutoPlantBomb = false,
    AutoDefuseBomb = false,
    
    -- Misc
    AntiAFK = false,
    KillSound = false,
    HitMarker = false,
    DamageIndicator = false,
    SpeedHack = false,
}

local ConfigFile = "BloxStrike_Config.json"

-- Status tracking
local Status = {
    CurrentAction = "In Match",
    KillsThisMatch = 0,
    DeathsThisMatch = 0,
    HeadshotsThisMatch = 0,
    CurrentWeapon = "None",
}

-- ESP Storage
local ESPObjects = {
    Enemies = {},
    Teammates = {},
    Weapons = {},
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

--[[ AIMBOT SYSTEM ]]--

local Camera = Workspace.CurrentCamera

local function IsVisible(targetPart)
    if not Settings.WallCheck then return true end
    
    local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * Settings.MaxDistance)
    local hit, pos = Workspace:FindPartOnRayWithIgnoreList(ray, {Character, Camera})
    
    return hit and hit:IsDescendantOf(targetPart.Parent)
end

local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            -- Team check
            if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                continue
            end
            
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
            
            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                
                -- Check if within FOV
                if distance < Settings.FOVSize and distance < shortestDistance then
                    -- Check distance from player
                    local playerDistance = (head.Position - HumanoidRootPart.Position).Magnitude
                    if playerDistance <= Settings.MaxDistance then
                        -- Check visibility
                        if IsVisible(head) then
                            closestPlayer = player
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- FOV Circle
task.spawn(function()
    local Drawing = Drawing or {}
    if Drawing.new then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 2
        FOVCircle.NumSides = 64
        FOVCircle.Radius = Settings.FOVSize
        FOVCircle.Filled = false
        FOVCircle.Visible = Settings.ShowFOV
        FOVCircle.ZIndex = 999
        FOVCircle.Transparency = 1
        FOVCircle.Color = Color3.fromRGB(255, 255, 255)
        
        RunService.RenderStepped:Connect(function()
            if FOVCircle then
                local mousePos = UserInputService:GetMouseLocation()
                FOVCircle.Position = mousePos
                FOVCircle.Radius = Settings.FOVSize
                FOVCircle.Visible = Settings.ShowFOV
            end
        end)
    end
end)

-- Silent Aim
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if Settings.SilentAim and method == "FireServer" and self.Name == "ShootEvent" then
        local target = GetClosestPlayerToCursor()
        if target and target.Character then
            local aimPart = Settings.AutoHeadshot and target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
            if aimPart then
                args[1] = aimPart.Position
                return oldNamecall(self, unpack(args))
            end
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Triggerbot
task.spawn(function()
    RunService.RenderStepped:Connect(function()
        if Settings.Triggerbot then
            local target = GetClosestPlayerToCursor()
            if target then
                local mouse = game:GetService("VirtualInputManager") or {SendMouseButtonEvent = function() end}
                pcall(function()
                    mouse:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    wait()
                    mouse:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end)
            end
        end
    end)
end)

--[[ RECOIL & WEAPON MODS ]]--

task.spawn(function()
    RunService.Heartbeat:Connect(function()
        pcall(function()
            local tool = Character:FindFirstChildOfClass("Tool")
            if tool then
                Status.CurrentWeapon = tool.Name
                
                -- No Recoil
                if Settings.NoRecoil then
                    if tool:FindFirstChild("Recoil") then
                        tool.Recoil.Value = 0
                    end
                end
                
                -- No Spread
                if Settings.NoSpread then
                    if tool:FindFirstChild("Spread") then
                        tool.Spread.Value = 0
                    end
                end
                
                -- Infinite Ammo
                if Settings.InfiniteAmmo then
                    if tool:FindFirstChild("Ammo") then
                        tool.Ammo.Value = 999
                    end
                    if tool:FindFirstChild("Magazine") then
                        tool.Magazine.Value = 999
                    end
                end
                
                -- Rapid Fire
                if Settings.RapidFire then
                    if tool:FindFirstChild("FireRate") then
                        tool.FireRate.Value = 0.01
                    end
                end
            else
                Status.CurrentWeapon = "None"
            end
        end)
    end)
end)

--[[ ESP SYSTEM ]]--

local function CreateESP(player, isTeammate)
    if ESPObjects.Enemies[player] or ESPObjects.Teammates[player] then
        return
    end
    
    local espFolder = Instance.new("Folder")
    espFolder.Name = "ESP_" .. player.Name
    espFolder.Parent = game.CoreGui
    
    local function UpdateESP()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        local hrp = player.Character.HumanoidRootPart
        local head = player.Character:FindFirstChild("Head")
        local humanoid = player.Character:FindFirstChild("Humanoid")
        
        -- Name ESP
        local nameLabel = espFolder:FindFirstChild("Name") or Instance.new("BillboardGui")
        if not espFolder:FindFirstChild("Name") then
            nameLabel.Name = "Name"
            nameLabel.Parent = espFolder
            nameLabel.Adornee = head
            nameLabel.Size = UDim2.new(0, 100, 0, 20)
            nameLabel.StudsOffset = Vector3.new(0, 2, 0)
            nameLabel.AlwaysOnTop = true
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Parent = nameLabel
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = isTeammate and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
            textLabel.TextStrokeTransparency = 0.5
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.GothamBold
        end
        
        local shouldShow = isTeammate and Settings.TeamESP and Settings.TeamNames or not isTeammate and Settings.EnemyESP and Settings.EnemyNames
        nameLabel.Enabled = shouldShow
        if shouldShow and nameLabel:FindFirstChildOfClass("TextLabel") then
            nameLabel:FindFirstChildOfClass("TextLabel").Text = player.Name
        end
        
        -- Distance ESP
        local distLabel = espFolder:FindFirstChild("Distance") or Instance.new("BillboardGui")
        if not espFolder:FindFirstChild("Distance") then
            distLabel.Name = "Distance"
            distLabel.Parent = espFolder
            distLabel.Adornee = hrp
            distLabel.Size = UDim2.new(0, 100, 0, 20)
            distLabel.StudsOffset = Vector3.new(0, -2, 0)
            distLabel.AlwaysOnTop = true
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Parent = distLabel
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.TextStrokeTransparency = 0.5
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.Gotham
        end
        
        shouldShow = isTeammate and Settings.TeamESP and Settings.TeamDistance or not isTeammate and Settings.EnemyESP and Settings.EnemyDistance
        distLabel.Enabled = shouldShow
        if shouldShow and distLabel:FindFirstChildOfClass("TextLabel") and HumanoidRootPart then
            local distance = math.floor((hrp.Position - HumanoidRootPart.Position).Magnitude)
            distLabel:FindFirstChildOfClass("TextLabel").Text = distance .. "m"
        end
        
        -- Health ESP
        local healthLabel = espFolder:FindFirstChild("Health") or Instance.new("BillboardGui")
        if not espFolder:FindFirstChild("Health") then
            healthLabel.Name = "Health"
            healthLabel.Parent = espFolder
            healthLabel.Adornee = hrp
            healthLabel.Size = UDim2.new(0, 100, 0, 20)
            healthLabel.StudsOffset = Vector3.new(0, 0, 0)
            healthLabel.AlwaysOnTop = true
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Parent = healthLabel
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            textLabel.TextStrokeTransparency = 0.5
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.GothamBold
        end
        
        shouldShow = isTeammate and Settings.TeamESP and Settings.TeamHealth or not isTeammate and Settings.EnemyESP and Settings.EnemyHealth
        healthLabel.Enabled = shouldShow
        if shouldShow and healthLabel:FindFirstChildOfClass("TextLabel") and humanoid then
            local health = math.floor(humanoid.Health)
            healthLabel:FindFirstChildOfClass("TextLabel").Text = "HP: " .. health
            
            -- Color based on health
            if health > 75 then
                healthLabel:FindFirstChildOfClass("TextLabel").TextColor3 = Color3.fromRGB(100, 255, 100)
            elseif health > 50 then
                healthLabel:FindFirstChildOfClass("TextLabel").TextColor3 = Color3.fromRGB(255, 255, 100)
            elseif health > 25 then
                healthLabel:FindFirstChildOfClass("TextLabel").TextColor3 = Color3.fromRGB(255, 165, 0)
            else
                healthLabel:FindFirstChildOfClass("TextLabel").TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end
        
        -- Weapon ESP
        local weaponLabel = espFolder:FindFirstChild("Weapon") or Instance.new("BillboardGui")
        if not espFolder:FindFirstChild("Weapon") then
            weaponLabel.Name = "Weapon"
            weaponLabel.Parent = espFolder
            weaponLabel.Adornee = hrp
            weaponLabel.Size = UDim2.new(0, 100, 0, 20)
            weaponLabel.StudsOffset = Vector3.new(0, -3, 0)
            weaponLabel.AlwaysOnTop = true
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Parent = weaponLabel
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
            textLabel.TextStrokeTransparency = 0.5
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.Gotham
        end
        
        shouldShow = not isTeammate and Settings.EnemyESP and Settings.EnemyWeapon
        weaponLabel.Enabled = shouldShow
        if shouldShow and weaponLabel:FindFirstChildOfClass("TextLabel") then
            local tool = player.Character:FindFirstChildOfClass("Tool")
            weaponLabel:FindFirstChildOfClass("TextLabel").Text = tool and tool.Name or "Unarmed"
        end
        
        -- Box ESP
        -- (Simplified - would need more complex rendering for actual boxes)
    end
    
    -- Store ESP
    if isTeammate then
        ESPObjects.Teammates[player] = espFolder
    else
        ESPObjects.Enemies[player] = espFolder
    end
    
    -- Update loop
    task.spawn(function()
        while player.Parent and espFolder.Parent do
            pcall(UpdateESP)
            wait(0.1)
        end
    end)
end

local function RemoveESP(player)
    if ESPObjects.Enemies[player] then
        ESPObjects.Enemies[player]:Destroy()
        ESPObjects.Enemies[player] = nil
    end
    if ESPObjects.Teammates[player] then
        ESPObjects.Teammates[player]:Destroy()
        ESPObjects.Teammates[player] = nil
    end
end

-- ESP Manager
task.spawn(function()
    while wait(1) do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local isTeammate = player.Team == LocalPlayer.Team
                
                if (isTeammate and Settings.TeamESP) or (not isTeammate and Settings.EnemyESP) then
                    CreateESP(player, isTeammate)
                else
                    RemoveESP(player)
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

--[[ MOVEMENT MODS ]]--

task.spawn(function()
    RunService.Heartbeat:Connect(function()
        if Character and Character:FindFirstChild("Humanoid") then
            local humanoid = Character.Humanoid
            
            -- Speed
            if Settings.LockWalkSpeed then
                humanoid.WalkSpeed = Settings.WalkSpeed
            end
            
            -- Jump
            if Settings.LockJumpPower then
                humanoid.JumpPower = Settings.JumpPower
            end
            
            -- Infinite Jump
            if Settings.InfiniteJump then
                UserInputService.JumpRequest:Connect(function()
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end
            
            -- Bunny Hop
            if Settings.BunnyHop and humanoid:GetState() == Enum.HumanoidStateType.Landed then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end)

-- Noclip
task.spawn(function()
    RunService.Stepped:Connect(function()
        if Settings.Noclip and Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

--[[ VISUAL MODS ]]--

-- Fullbright
task.spawn(function()
    local Lighting = game:GetService("Lighting")
    RunService.Heartbeat:Connect(function()
        if Settings.Fullbright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end)
end)

-- No Flash (removes flashbang effects)
task.spawn(function()
    RunService.Heartbeat:Connect(function()
        if Settings.NoFlash then
            pcall(function()
                for _, effect in pairs(Camera:GetChildren()) do
                    if effect.Name:lower():find("flash") or effect.Name:lower():find("blind") then
                        effect:Destroy()
                    end
                end
            end)
        end
    end)
end)

-- Third Person
task.spawn(function()
    RunService.RenderStepped:Connect(function()
        if Settings.ThirdPerson and LocalPlayer.Character then
            LocalPlayer.CameraMaxZoomDistance = Settings.ThirdPersonDistance
            LocalPlayer.CameraMinZoomDistance = Settings.ThirdPersonDistance
        else
            LocalPlayer.CameraMaxZoomDistance = 0.5
            LocalPlayer.CameraMinZoomDistance = 0.5
        end
    end)
end)

--[[ KILL TRACKING ]]--

-- Track kills via humanoid death
task.spawn(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Died:Connect(function()
                    -- Check if we likely killed them (simplified)
                    Status.KillsThisMatch = Status.KillsThisMatch + 1
                    if Settings.KillSound then
                        Notify("Kill!", "+" .. Status.KillsThisMatch)
                    end
                end)
            end
        end
    end
end)

--[[ GUI CREATION ]]--

local function CreateGUI()
    -- RGB Color for animated elements
    local hue = 0
    local function GetRGBColor()
        hue = (hue + 0.001) % 1
        return Color3.fromHSV(hue, 1, 1)
    end
    
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BloxStrikeGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game.CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game.CoreGui
    end
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
    MainFrame.Size = UDim2.new(0, 650, 0, 450)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ZIndex = 1
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    -- Animated RGB Border
    local BorderFrame = Instance.new("Frame")
    BorderFrame.Parent = MainFrame
    BorderFrame.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    BorderFrame.BorderSizePixel = 0
    BorderFrame.Size = UDim2.new(1, 4, 1, 4)
    BorderFrame.Position = UDim2.new(0, -2, 0, -2)
    BorderFrame.ZIndex = 0
    
    local BorderCorner = Instance.new("UICorner")
    BorderCorner.CornerRadius = UDim.new(0, 12)
    BorderCorner.Parent = BorderFrame
    
    task.spawn(function()
        while BorderFrame and BorderFrame.Parent do
            BorderFrame.BackgroundColor3 = GetRGBColor()
            wait()
        end
    end)
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.ZIndex = 2
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = TitleBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Size = UDim2.new(0, 300, 1, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "🎯 BloxStrike FPS GUI"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 3
    
    local VersionLabel = Instance.new("TextLabel")
    VersionLabel.Parent = TitleBar
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Position = UDim2.new(0, 15, 0, 25)
    VersionLabel.Size = UDim2.new(0, 200, 0, 15)
    VersionLabel.Font = Enum.Font.Gotham
    VersionLabel.Text = "v1 BETA | Made by I Went Kimbo"
    VersionLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    VersionLabel.TextSize = 10
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
    VersionLabel.ZIndex = 3
    
    -- Close & Minimize Buttons
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = TitleBar
    CloseBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    CloseBtn.Position = UDim2.new(1, -35, 0, 10)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 18
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 3
    
    local CloseBtnCorner = Instance.new("UICorner")
    CloseBtnCorner.CornerRadius = UDim.new(0, 6)
    CloseBtnCorner.Parent = CloseBtn
    
    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = TitleBar
    MinBtn.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
    MinBtn.Position = UDim2.new(1, -65, 0, 10)
    MinBtn.Size = UDim2.new(0, 25, 0, 25)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.TextSize = 18
    MinBtn.AutoButtonColor = false
    MinBtn.ZIndex = 3
    
    local MinBtnCorner = Instance.new("UICorner")
    MinBtnCorner.CornerRadius = UDim.new(0, 6)
    MinBtnCorner.Parent = MinBtn
    
    -- Minimize Icon (shown when minimized)
    local MinimizeIcon = Instance.new("TextButton")
    MinimizeIcon.Parent = ScreenGui
    MinimizeIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    MinimizeIcon.Position = UDim2.new(1, -70, 0, 10)
    MinimizeIcon.Size = UDim2.new(0, 60, 0, 60)
    MinimizeIcon.Font = Enum.Font.GothamBold
    MinimizeIcon.Text = "🎯"
    MinimizeIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeIcon.TextSize = 30
    MinimizeIcon.Visible = false
    MinimizeIcon.AutoButtonColor = false
    
    local MinIconCorner = Instance.new("UICorner")
    MinIconCorner.CornerRadius = UDim.new(0, 12)
    MinIconCorner.Parent = MinimizeIcon
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 0, 0, 45)
    TabContainer.Size = UDim2.new(1, 0, 0, 45)
    TabContainer.ZIndex = 2
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 10, 0, 100)
    ContentContainer.Size = UDim2.new(1, -20, 1, -110)
    ContentContainer.ZIndex = 2
    
    -- Helper functions for UI elements
    local function CreateToggle(parent, text, position, settingKey)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Parent = parent
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        ToggleFrame.Position = position
        ToggleFrame.Size = UDim2.new(0, 300, 0, 32)
        ToggleFrame.ZIndex = 3
        
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
        ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
        ToggleLabel.TextSize = 12
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.ZIndex = 4
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Parent = ToggleFrame
        ToggleButton.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
        ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
        ToggleButton.Size = UDim2.new(0, 40, 0, 20)
        ToggleButton.AutoButtonColor = false
        ToggleButton.Text = ""
        ToggleButton.ZIndex = 4
        
        local ToggleBtnCorner = Instance.new("UICorner")
        ToggleBtnCorner.CornerRadius = UDim.new(0, 10)
        ToggleBtnCorner.Parent = ToggleButton
        
        ToggleButton.MouseButton1Click:Connect(function()
            Settings[settingKey] = not Settings[settingKey]
            ToggleButton.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)
            SaveConfig()
        end)
        
        return ToggleFrame
    end
    
    local function CreateSlider(parent, text, position, settingKey, min, max, increment)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Parent = parent
        SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        SliderFrame.Position = position
        SliderFrame.Size = UDim2.new(0, 300, 0, 55)
        SliderFrame.ZIndex = 3
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 8)
        SliderCorner.Parent = SliderFrame
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Parent = SliderFrame
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Position = UDim2.new(0, 10, 0, 5)
        SliderLabel.Size = UDim2.new(1, -20, 0, 15)
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.Text = text .. ": " .. Settings[settingKey]
        SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
        SliderLabel.TextSize = 11
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.ZIndex = 4
        
        local SliderBG = Instance.new("Frame")
        SliderBG.Parent = SliderFrame
        SliderBG.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        SliderBG.Position = UDim2.new(0, 10, 0, 28)
        SliderBG.Size = UDim2.new(1, -20, 0, 6)
        SliderBG.ZIndex = 4
        
        local SliderBGCorner = Instance.new("UICorner")
        SliderBGCorner.CornerRadius = UDim.new(0, 3)
        SliderBGCorner.Parent = SliderBG
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Parent = SliderBG
        SliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
        SliderFill.BorderSizePixel = 0
        SliderFill.Size = UDim2.new((Settings[settingKey] - min) / (max - min), 0, 1, 0)
        SliderFill.ZIndex = 5
        
        local SliderFillCorner = Instance.new("UICorner")
        SliderFillCorner.CornerRadius = UDim.new(0, 3)
        SliderFillCorner.Parent = SliderFill
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Parent = SliderBG
        SliderButton.BackgroundTransparency = 1
        SliderButton.Size = UDim2.new(1, 0, 1, 0)
        SliderButton.Text = ""
        SliderButton.ZIndex = 6
        
        local dragging = false
        
        SliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        RunService.Heartbeat:Connect(function()
            if dragging then
                local mousePos = UserInputService:GetMouseLocation().X
                local sliderPos = SliderBG.AbsolutePosition.X
                local sliderSize = SliderBG.AbsoluteSize.X
                
                local value = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
                local newValue = math.floor((min + (max - min) * value) / increment + 0.5) * increment
                
                Settings[settingKey] = newValue
                SliderLabel.Text = text .. ": " .. newValue
                SliderFill.Size = UDim2.new((newValue - min) / (max - min), 0, 1, 0)
                SaveConfig()
            end
        end)
        
        return SliderFrame
    end
    
    local function CreateButton(parent, text, position, size, color, callback)
        local Button = Instance.new("TextButton")
        Button.Parent = parent
        Button.BackgroundColor3 = color
        Button.Position = position
        Button.Size = size
        Button.Font = Enum.Font.GothamBold
        Button.Text = text
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 13
        Button.AutoButtonColor = false
        Button.ZIndex = 4
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 8)
        ButtonCorner.Parent = Button
        
        Button.MouseButton1Click:Connect(callback)
        
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(
                math.min(color.R * 255 + 20, 255),
                math.min(color.G * 255 + 20, 255),
                math.min(color.B * 255 + 20, 255)
            )}):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        end)
        
        return Button
    end
    
    -- Pages
    local pages = {}
    
    -- HOME PAGE
    local HomePage = Instance.new("Frame")
    HomePage.Parent = ContentContainer
    HomePage.BackgroundTransparency = 1
    HomePage.Size = UDim2.new(1, 0, 1, 0)
    pages["Home"] = HomePage
    
    local WelcomeLabel = Instance.new("TextLabel")
    WelcomeLabel.Parent = HomePage
    WelcomeLabel.BackgroundTransparency = 1
    WelcomeLabel.Position = UDim2.new(0, 0, 0, 10)
    WelcomeLabel.Size = UDim2.new(1, 0, 0, 40)
    WelcomeLabel.Font = Enum.Font.GothamBold
    WelcomeLabel.Text = "Welcome to BloxStrike FPS GUI"
    WelcomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    WelcomeLabel.TextSize = 20
    WelcomeLabel.ZIndex = 3
    
    local DescLabel = Instance.new("TextLabel")
    DescLabel.Parent = HomePage
    DescLabel.BackgroundTransparency = 1
    DescLabel.Position = UDim2.new(0, 0, 0, 55)
    DescLabel.Size = UDim2.new(1, 0, 0, 60)
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.Text = "Tactical FPS script with aimbot, ESP, weapon mods, and more.\nNavigate through tabs to configure your settings."
    DescLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    DescLabel.TextSize = 13
    DescLabel.TextWrapped = true
    DescLabel.ZIndex = 3
    
    -- Quick Stats
    local StatsFrame = Instance.new("Frame")
    StatsFrame.Parent = HomePage
    StatsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    StatsFrame.Position = UDim2.new(0, 0, 0, 130)
    StatsFrame.Size = UDim2.new(1, 0, 0, 150)
    StatsFrame.ZIndex = 3
    
    local StatsCorner = Instance.new("UICorner")
    StatsCorner.CornerRadius = UDim.new(0, 10)
    StatsCorner.Parent = StatsFrame
    
    local StatsTitle = Instance.new("TextLabel")
    StatsTitle.Parent = StatsFrame
    StatsTitle.BackgroundTransparency = 1
    StatsTitle.Position = UDim2.new(0, 15, 0, 10)
    StatsTitle.Size = UDim2.new(1, -30, 0, 25)
    StatsTitle.Font = Enum.Font.GothamBold
    StatsTitle.Text = "📊 Match Statistics"
    StatsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatsTitle.TextSize = 14
    StatsTitle.TextXAlignment = Enum.TextXAlignment.Left
    StatsTitle.ZIndex = 4
    
    local KillsLabel = Instance.new("TextLabel")
    KillsLabel.Parent = StatsFrame
    KillsLabel.BackgroundTransparency = 1
    KillsLabel.Position = UDim2.new(0, 15, 0, 45)
    KillsLabel.Size = UDim2.new(0.5, -20, 0, 20)
    KillsLabel.Font = Enum.Font.Gotham
    KillsLabel.Text = "Kills: 0"
    KillsLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    KillsLabel.TextSize = 12
    KillsLabel.TextXAlignment = Enum.TextXAlignment.Left
    KillsLabel.ZIndex = 4
    
    local DeathsLabel = Instance.new("TextLabel")
    DeathsLabel.Parent = StatsFrame
    DeathsLabel.BackgroundTransparency = 1
    DeathsLabel.Position = UDim2.new(0.5, 5, 0, 45)
    DeathsLabel.Size = UDim2.new(0.5, -20, 0, 20)
    DeathsLabel.Font = Enum.Font.Gotham
    DeathsLabel.Text = "Deaths: 0"
    DeathsLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    DeathsLabel.TextSize = 12
    DeathsLabel.TextXAlignment = Enum.TextXAlignment.Left
    DeathsLabel.ZIndex = 4
    
    local HeadshotsLabel = Instance.new("TextLabel")
    HeadshotsLabel.Parent = StatsFrame
    HeadshotsLabel.BackgroundTransparency = 1
    HeadshotsLabel.Position = UDim2.new(0, 15, 0, 75)
    HeadshotsLabel.Size = UDim2.new(0.5, -20, 0, 20)
    HeadshotsLabel.Font = Enum.Font.Gotham
    HeadshotsLabel.Text = "Headshots: 0"
    HeadshotsLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    HeadshotsLabel.TextSize = 12
    HeadshotsLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeadshotsLabel.ZIndex = 4
    
    local WeaponLabel = Instance.new("TextLabel")
    WeaponLabel.Parent = StatsFrame
    WeaponLabel.BackgroundTransparency = 1
    WeaponLabel.Position = UDim2.new(0.5, 5, 0, 75)
    WeaponLabel.Size = UDim2.new(0.5, -20, 0, 20)
    WeaponLabel.Font = Enum.Font.Gotham
    WeaponLabel.Text = "Weapon: None"
    WeaponLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    WeaponLabel.TextSize = 12
    WeaponLabel.TextXAlignment = Enum.TextXAlignment.Left
    WeaponLabel.ZIndex = 4
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Parent = StatsFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 15, 0, 105)
    StatusLabel.Size = UDim2.new(1, -30, 0, 20)
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.Text = "Status: In Match"
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    StatusLabel.TextSize = 11
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.ZIndex = 4
    
    -- Update stats every second
    task.spawn(function()
        while wait(1) do
            if HomePage.Visible then
                KillsLabel.Text = "Kills: " .. Status.KillsThisMatch
                DeathsLabel.Text = "Deaths: " .. Status.DeathsThisMatch
                HeadshotsLabel.Text = "Headshots: " .. Status.HeadshotsThisMatch
                WeaponLabel.Text = "Weapon: " .. Status.CurrentWeapon
                StatusLabel.Text = "Status: " .. Status.CurrentAction
            end
        end
    end)
    
    -- AIMBOT PAGE
    local AimbotPage = Instance.new("Frame")
    AimbotPage.Parent = ContentContainer
    AimbotPage.BackgroundTransparency = 1
    AimbotPage.Size = UDim2.new(1, 0, 1, 0)
    AimbotPage.Visible = false
    pages["Aimbot"] = AimbotPage
    
    CreateToggle(AimbotPage, "Silent Aim", UDim2.new(0, 10, 0, 5), "SilentAim")
    CreateToggle(AimbotPage, "Triggerbot", UDim2.new(0, 10, 0, 43), "Triggerbot")
    CreateToggle(AimbotPage, "Auto Headshot", UDim2.new(0, 10, 0, 81), "AutoHeadshot")
    CreateToggle(AimbotPage, "Show FOV Circle", UDim2.new(0, 10, 0, 119), "ShowFOV")
    CreateToggle(AimbotPage, "Wall Check", UDim2.new(0, 10, 0, 157), "WallCheck")
    CreateToggle(AimbotPage, "Team Check", UDim2.new(0, 10, 0, 195), "TeamCheck")
    
    CreateSlider(AimbotPage, "FOV Size", UDim2.new(0, 320, 0, 5), "FOVSize", 50, 300, 10)
    CreateSlider(AimbotPage, "Max Distance", UDim2.new(0, 320, 0, 68), "MaxDistance", 100, 1000, 50)
    
    -- WEAPON MODS PAGE
    local WeaponPage = Instance.new("Frame")
    WeaponPage.Parent = ContentContainer
    WeaponPage.BackgroundTransparency = 1
    WeaponPage.Size = UDim2.new(1, 0, 1, 0)
    WeaponPage.Visible = false
    pages["Weapons"] = WeaponPage
    
    CreateToggle(WeaponPage, "No Recoil", UDim2.new(0, 10, 0, 5), "NoRecoil")
    CreateToggle(WeaponPage, "No Spread", UDim2.new(0, 10, 0, 43), "NoSpread")
    CreateToggle(WeaponPage, "Infinite Ammo", UDim2.new(0, 10, 0, 81), "InfiniteAmmo")
    CreateToggle(WeaponPage, "Rapid Fire", UDim2.new(0, 10, 0, 119), "RapidFire")
    CreateToggle(WeaponPage, "Auto Reload", UDim2.new(0, 10, 0, 157), "AutoReload")
    
    CreateToggle(WeaponPage, "Auto Buy Weapons", UDim2.new(0, 320, 0, 5), "AutoBuyWeapons")
    CreateToggle(WeaponPage, "Weapon ESP", UDim2.new(0, 320, 0, 43), "WeaponESP")
    
    -- ENEMY ESP PAGE
    local EnemyESPPage = Instance.new("Frame")
    EnemyESPPage.Parent = ContentContainer
    EnemyESPPage.BackgroundTransparency = 1
    EnemyESPPage.Size = UDim2.new(1, 0, 1, 0)
    EnemyESPPage.Visible = false
    pages["Enemy ESP"] = EnemyESPPage
    
    CreateToggle(EnemyESPPage, "Enable Enemy ESP", UDim2.new(0, 10, 0, 5), "EnemyESP")
    CreateToggle(EnemyESPPage, "Show Names", UDim2.new(0, 10, 0, 43), "EnemyNames")
    CreateToggle(EnemyESPPage, "Show Boxes", UDim2.new(0, 10, 0, 81), "EnemyBoxes")
    CreateToggle(EnemyESPPage, "Show Distance", UDim2.new(0, 10, 0, 119), "EnemyDistance")
    CreateToggle(EnemyESPPage, "Show Health", UDim2.new(0, 10, 0, 157), "EnemyHealth")
    CreateToggle(EnemyESPPage, "Show Weapon", UDim2.new(0, 10, 0, 195), "EnemyWeapon")
    
    -- TEAM ESP PAGE
    local TeamESPPage = Instance.new("Frame")
    TeamESPPage.Parent = ContentContainer
    TeamESPPage.BackgroundTransparency = 1
    TeamESPPage.Size = UDim2.new(1, 0, 1, 0)
    TeamESPPage.Visible = false
    pages["Team ESP"] = TeamESPPage
    
    CreateToggle(TeamESPPage, "Enable Team ESP", UDim2.new(0, 10, 0, 5), "TeamESP")
    CreateToggle(TeamESPPage, "Show Names", UDim2.new(0, 10, 0, 43), "TeamNames")
    CreateToggle(TeamESPPage, "Show Boxes", UDim2.new(0, 10, 0, 81), "TeamBoxes")
    CreateToggle(TeamESPPage, "Show Distance", UDim2.new(0, 10, 0, 119), "TeamDistance")
    CreateToggle(TeamESPPage, "Show Health", UDim2.new(0, 10, 0, 157), "TeamHealth")
    
    -- MOVEMENT PAGE
    local MovementPage = Instance.new("Frame")
    MovementPage.Parent = ContentContainer
    MovementPage.BackgroundTransparency = 1
    MovementPage.Size = UDim2.new(1, 0, 1, 0)
    MovementPage.Visible = false
    pages["Movement"] = MovementPage
    
    CreateToggle(MovementPage, "Infinite Jump", UDim2.new(0, 10, 0, 5), "InfiniteJump")
    CreateToggle(MovementPage, "Noclip", UDim2.new(0, 10, 0, 43), "Noclip")
    CreateToggle(MovementPage, "Bunny Hop", UDim2.new(0, 10, 0, 81), "BunnyHop")
    CreateToggle(MovementPage, "Speed Hack", UDim2.new(0, 10, 0, 119), "SpeedHack")
    
    CreateSlider(MovementPage, "Walk Speed", UDim2.new(0, 320, 0, 5), "WalkSpeed", 16, 200, 1)
    CreateSlider(MovementPage, "Jump Power", UDim2.new(0, 320, 0, 68), "JumpPower", 50, 200, 1)
    
    -- VISUALS PAGE
    local VisualsPage = Instance.new("Frame")
    VisualsPage.Parent = ContentContainer
    VisualsPage.BackgroundTransparency = 1
    VisualsPage.Size = UDim2.new(1, 0, 1, 0)
    VisualsPage.Visible = false
    pages["Visuals"] = VisualsPage
    
    CreateToggle(VisualsPage, "Fullbright", UDim2.new(0, 10, 0, 5), "Fullbright")
    CreateToggle(VisualsPage, "No Flash", UDim2.new(0, 10, 0, 43), "NoFlash")
    CreateToggle(VisualsPage, "No Smoke", UDim2.new(0, 10, 0, 81), "NoSmoke")
    CreateToggle(VisualsPage, "Third Person", UDim2.new(0, 10, 0, 119), "ThirdPerson")
    CreateToggle(VisualsPage, "Hit Marker", UDim2.new(0, 10, 0, 157), "HitMarker")
    CreateToggle(VisualsPage, "Damage Indicator", UDim2.new(0, 10, 0, 195), "DamageIndicator")
    
    CreateSlider(VisualsPage, "Third Person Distance", UDim2.new(0, 320, 0, 5), "ThirdPersonDistance", 5, 50, 1)
    
    -- SETTINGS PAGE
    local SettingsPage = Instance.new("Frame")
    SettingsPage.Parent = ContentContainer
    SettingsPage.BackgroundTransparency = 1
    SettingsPage.Size = UDim2.new(1, 0, 1, 0)
    SettingsPage.Visible = false
    pages["Settings"] = SettingsPage
    
    CreateToggle(SettingsPage, "Anti-AFK", UDim2.new(0, 10, 0, 5), "AntiAFK")
    CreateToggle(SettingsPage, "Kill Sound", UDim2.new(0, 10, 0, 43), "KillSound")
    
    -- Config Buttons
    CreateButton(SettingsPage, "💾 Save Config", UDim2.new(0, 10, 0, 100), UDim2.new(0, 140, 0, 35), Color3.fromRGB(39, 174, 96), function()
        SaveConfig()
        Notify("Config", "Settings saved!")
    end)
    
    CreateButton(SettingsPage, "📁 Load Config", UDim2.new(0, 160, 0, 100), UDim2.new(0, 140, 0, 35), Color3.fromRGB(52, 152, 219), function()
        if LoadConfig() then
            Notify("Config", "Settings loaded!")
        else
            Notify("Config", "No saved config found")
        end
    end)
    
    CreateButton(SettingsPage, "🔄 Rejoin Server", UDim2.new(0, 10, 0, 145), UDim2.new(0, 140, 0, 35), Color3.fromRGB(60, 120, 200), function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
    
    CreateButton(SettingsPage, "🎲 Random Server", UDim2.new(0, 160, 0, 145), UDim2.new(0, 140, 0, 35), Color3.fromRGB(100, 150, 50), function()
        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        
        pcall(function()
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
            for _, server in pairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end)
    end)
    
    -- Create tabs
    local tabs = {"Home", "Aimbot", "Weapons", "Enemy ESP", "Team ESP", "Movement", "Visuals", "Settings"}
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
        tabButton.TextSize = 10
        tabButton.AutoButtonColor = false
        tabButton.ZIndex = 3
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabButton
        
        -- Active indicator
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
        
        -- Hover effects
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
    
    LoadConfig()
end

--[[ INIT ]]--

print("[BLOXSTRIKE] Loading BloxStrike FPS GUI v1 BETA...")

Notify("BloxStrike FPS", "Script loaded successfully!")

CreateGUI()

print("========================================")
print("🎯 BloxStrike FPS GUI Loaded")
print("📝 Made by I Went Kimbo")
print("✅ All systems active")
print("========================================")
