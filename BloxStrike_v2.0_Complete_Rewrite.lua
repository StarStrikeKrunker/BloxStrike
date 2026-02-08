-- BloxStrike Script - Made by I Went Kimbo
-- Version: v2.0 - "Strike First, Strike Hard"
-- COMPLETE REWRITE using working Epstein's Eulogy structure

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
    AimPart = "Head",
    
    -- ESP
    PlayerESP = false,
    PlayerNames = true,
    PlayerBoxes = true,
    PlayerDistance = true,
    PlayerHealth = true,
    PlayerTracers = false,
    PlayerChams = false,
    ESPTeamCheck = true,
    
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

local function SaveConfig()
    pcall(function()
        if writefile then
            local json = HttpService:JSONEncode(Settings)
            writefile(ConfigFile, json)
        end
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

--[[ MOVEMENT ]]--

RunService.Heartbeat:Connect(function()
    if Settings.LockWalkSpeed and Humanoid then
        Humanoid.WalkSpeed = Settings.WalkSpeed
    end
    
    if Settings.LockJumpPower and Humanoid then
        Humanoid.JumpPower = Settings.JumpPower
    end
end)

--[[ AIMBOT ]]--

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local aimEnabled = false
local smoothing = 0.15

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
        aimEnabled = false
    end)
    
    RunService.Heartbeat:Connect(function()
        if Settings.Aimbot and isHolding and (tick() - holdStart) > 0.2 then
            aimEnabled = true
        end
    end)
else
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
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetChar = player.Character
            local targetPart = targetChar:FindFirstChild(Settings.AimPart)
            
            if targetPart then
                if Settings.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end
                
                if Settings.WallCheck then
                    local ray = Ray.new(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position).Unit * Settings.MaxDistance)
                    local hit, pos = Workspace:FindPartOnRayWithIgnoreList(ray, {Character, targetChar})
                    if hit then continue end
                end
                
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    
                    if distance < shortestDistance and distance <= Settings.FOVSize then
                        shortestDistance = distance
                        closestPlayer = {player = player, part = targetPart}
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

RunService.Heartbeat:Connect(function()
    if not Settings.Aimbot and not Settings.SilentAim then
        CurrentTarget = nil
        return
    end
    
    local target = GetClosestPlayer()
    CurrentTarget = target
    
    if target and aimEnabled and Settings.Aimbot then
        local camera = Workspace.CurrentCamera
        local targetPos = target.part.Position
        
        local currentCFrame = camera.CFrame
        local targetCFrame = CFrame.new(camera.CFrame.Position, targetPos)
        camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothing)
    end
end)

RunService.Heartbeat:Connect(function()
    if not Settings.Triggerbot then return end
    
    if CurrentTarget then
        mouse1press()
        wait(0.05)
        mouse1release()
    end
end)

--[[ FOV CIRCLE ]]--

local function CreateFOVCircle()
    if not Drawing then return end
    
    local fov = Drawing.new("Circle")
    fov.Thickness = 2
    fov.NumSides = 50
    fov.Radius = Settings.FOVSize
    fov.Filled = false
    fov.Transparency = 0.7
    fov.Color = Color3.fromRGB(100, 200, 255)
    fov.Visible = Settings.ShowFOV
    fov.ZIndex = 999
    
    FOVCircle = fov
    
    RunService.Heartbeat:Connect(function()
        if FOVCircle then
            local mousePos = UserInputService:GetMouseLocation()
            FOVCircle.Position = mousePos
            FOVCircle.Radius = Settings.FOVSize
            FOVCircle.Visible = Settings.ShowFOV
            
            local hue = tick() % 5 / 5
            FOVCircle.Color = Color3.fromHSV(hue, 1, 1)
        end
    end)
end

--[[ ESP SYSTEM ]]--

local function CreateESP(player)
    if not Drawing or ESPObjects.Players[player] then return end
    
    local esp = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        Highlight = nil,
    }
    
    esp.Box.Thickness = 2
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    esp.Box.Color = Color3.fromRGB(255, 0, 0)
    esp.Box.Visible = false
    
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Color = Color3.fromRGB(255, 255, 255)
    esp.Name.Visible = false
    
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Visible = false
    
    esp.Health.Size = 12
    esp.Health.Center = true
    esp.Health.Outline = true
    esp.Health.Color = Color3.fromRGB(0, 255, 0)
    esp.Health.Visible = false
    
    esp.Tracer.Thickness = 2
    esp.Tracer.Transparency = 0.7
    esp.Tracer.Color = Color3.fromRGB(255, 0, 0)
    esp.Tracer.Visible = false
    
    if Settings.PlayerChams then
        local highlight = Instance.new("Highlight")
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        esp.Highlight = highlight
    end
    
    ESPObjects.Players[player] = esp
end

local function UpdateESP()
    for player, esp in pairs(ESPObjects.Players) do
        if not player or not player.Parent or not player.Character then
            if esp then
                esp.Box:Remove()
                esp.Name:Remove()
                esp.Distance:Remove()
                esp.Health:Remove()
                esp.Tracer:Remove()
                if esp.Highlight then esp.Highlight:Destroy() end
                ESPObjects.Players[player] = nil
            end
            continue
        end
        
        local char = player.Character
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChild("Humanoid")
        
        if not hrp or not head or not hum then continue end
        
        local camera = Workspace.CurrentCamera
        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
        
        if onScreen and Settings.PlayerESP then
            local isTeammate = Settings.ESPTeamCheck and player.Team == LocalPlayer.Team
            local espColor = isTeammate and Color3.fromRGB(0, 100, 255) or Color3.fromRGB(255, 0, 0)
            
            if Settings.PlayerBoxes then
                local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                
                esp.Box.Size = Vector2.new(2000 / screenPos.Z, headPos.Y - legPos.Y)
                esp.Box.Position = Vector2.new(screenPos.X - esp.Box.Size.X / 2, legPos.Y)
                esp.Box.Color = espColor
                esp.Box.Visible = true
            else
                esp.Box.Visible = false
            end
            
            if Settings.PlayerNames then
                esp.Name.Text = player.Name
                esp.Name.Position = Vector2.new(screenPos.X, screenPos.Y - 40)
                esp.Name.Visible = true
            else
                esp.Name.Visible = false
            end
            
            if Settings.PlayerDistance then
                local dist = math.floor((hrp.Position - HumanoidRootPart.Position).Magnitude)
                esp.Distance.Text = dist .. "m"
                esp.Distance.Position = Vector2.new(screenPos.X, screenPos.Y + 40)
                esp.Distance.Visible = true
            else
                esp.Distance.Visible = false
            end
            
            if Settings.PlayerHealth then
                local health = math.floor(hum.Health)
                local maxHealth = math.floor(hum.MaxHealth)
                esp.Health.Text = health .. "/" .. maxHealth
                esp.Health.Color = Color3.fromRGB(255 - (health/maxHealth * 255), (health/maxHealth * 255), 0)
                esp.Health.Position = Vector2.new(screenPos.X, screenPos.Y + 20)
                esp.Health.Visible = true
            else
                esp.Health.Visible = false
            end
            
            if Settings.PlayerTracers then
                local bottom = camera.ViewportSize.Y
                esp.Tracer.From = Vector2.new(camera.ViewportSize.X / 2, bottom)
                esp.Tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                esp.Tracer.Color = espColor
                esp.Tracer.Visible = true
            else
                esp.Tracer.Visible = false
            end
            
            if Settings.PlayerChams and esp.Highlight then
                esp.Highlight.Parent = char
                local hue = tick() % 5 / 5
                esp.Highlight.FillColor = Color3.fromHSV(hue, 1, 1)
                esp.Highlight.OutlineColor = Color3.fromHSV(hue, 1, 1)
            elseif esp.Highlight then
                esp.Highlight.Parent = nil
            end
        else
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Health.Visible = false
            esp.Tracer.Visible = false
            if esp.Highlight then esp.Highlight.Parent = nil end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if Settings.PlayerESP then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESP(player)
            end
        end
        UpdateESP()
    else
        for _, esp in pairs(ESPObjects.Players) do
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Health.Visible = false
            esp.Tracer.Visible = false
            if esp.Highlight then esp.Highlight.Parent = nil end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if ESPObjects.Players[player] then
        local esp = ESPObjects.Players[player]
        esp.Box:Remove()
        esp.Name:Remove()
        esp.Distance:Remove()
        esp.Health:Remove()
        esp.Tracer:Remove()
        if esp.Highlight then esp.Highlight:Destroy() end
        ESPObjects.Players[player] = nil
    end
end)

--[[ KEY SYSTEM ]]--

local function ShowKeySystem()
    -- Valid keys (using string.char to obfuscate)
    local validKeys = {
        "BLOXSTRIKE2026",
        "UNIVERSALFARM",
        "STRIKE2026"
    }
    local keyEntered = false
    
    -- Create key system GUI
    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "BloxStrikeKeySystem"
    KeyGui.Parent = game.CoreGui
    KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KeyGui.ResetOnSpawn = false
    
    -- RGB Animation
    local hue = 0
    local function GetRGBColor()
        hue = hue + 0.0005
        if hue > 1 then hue = 0 end
        return Color3.fromHSV(hue, 0.8, 1)
    end
    
    -- Main key frame
    local KeyFrame = Instance.new("Frame")
    KeyFrame.Parent = KeyGui
    KeyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    KeyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    KeyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    KeyFrame.Size = UDim2.new(0, 400, 0, 300)
    KeyFrame.Active = true
    KeyFrame.Draggable = true
    
    local KeyCorner = Instance.new("UICorner")
    KeyCorner.CornerRadius = UDim.new(0, 12)
    KeyCorner.Parent = KeyFrame
    
    local KeyStroke = Instance.new("UIStroke")
    KeyStroke.Color = Color3.fromRGB(255, 255, 255)
    KeyStroke.Thickness = 2
    KeyStroke.Parent = KeyFrame
    
    -- RGB animation
    task.spawn(function()
        while KeyFrame and KeyFrame.Parent do
            KeyStroke.Color = GetRGBColor()
            wait()
        end
    end)
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Parent = KeyFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 20)
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🔐 BLOXSTRIKE KEY SYSTEM"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 22
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Parent = KeyFrame
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0, 0, 0, 70)
    Subtitle.Size = UDim2.new(1, 0, 0, 50)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "Enter your key to access BloxStrike\nKeys available on Discord"
    Subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    Subtitle.TextSize = 11
    Subtitle.TextWrapped = true
    
    -- Key input box
    local KeyInput = Instance.new("TextBox")
    KeyInput.Parent = KeyFrame
    KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    KeyInput.Position = UDim2.new(0.1, 0, 0, 120)
    KeyInput.Size = UDim2.new(0.8, 0, 0, 50)
    KeyInput.Font = Enum.Font.GothamBold
    KeyInput.PlaceholderText = "Enter key..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 16
    KeyInput.ClearTextOnFocus = false
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = KeyInput
    
    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(255, 255, 255)
    InputStroke.Thickness = 1.5
    InputStroke.Parent = KeyInput
    
    task.spawn(function()
        while KeyInput and KeyInput.Parent do
            InputStroke.Color = GetRGBColor()
            wait()
        end
    end)
    
    -- Status label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Parent = KeyFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 0, 175)
    StatusLabel.Size = UDim2.new(1, 0, 0, 20)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    StatusLabel.TextSize = 14
    
    -- Submit button
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Parent = KeyFrame
    SubmitButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    SubmitButton.Position = UDim2.new(0.1, 0, 0, 200)
    SubmitButton.Size = UDim2.new(0.8, 0, 0, 45)
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Text = "SUBMIT KEY"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 18
    SubmitButton.AutoButtonColor = false
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = SubmitButton
    
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(255, 255, 255)
    ButtonStroke.Thickness = 2
    ButtonStroke.Parent = SubmitButton
    
    task.spawn(function()
        while SubmitButton and SubmitButton.Parent do
            ButtonStroke.Color = GetRGBColor()
            wait()
        end
    end)
    
    -- Discord button
    local DiscordButton = Instance.new("TextButton")
    DiscordButton.Parent = KeyFrame
    DiscordButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    DiscordButton.Position = UDim2.new(0.1, 0, 0, 255)
    DiscordButton.Size = UDim2.new(0.8, 0, 0, 35)
    DiscordButton.Font = Enum.Font.GothamBold
    DiscordButton.Text = "💬 Join Discord for Keys"
    DiscordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DiscordButton.TextSize = 12
    DiscordButton.AutoButtonColor = false
    
    local DiscordCorner = Instance.new("UICorner")
    DiscordCorner.CornerRadius = UDim.new(0, 6)
    DiscordCorner.Parent = DiscordButton
    
    DiscordButton.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then
                setclipboard("https://discord.gg/bloxstrike-keys")
                StatusLabel.Text = "✓ Discord link copied to clipboard!"
                StatusLabel.TextColor3 = Color3.fromRGB(88, 101, 242)
                
                task.delay(3, function()
                    StatusLabel.Text = ""
                end)
            else
                StatusLabel.Text = "Discord: discord.gg/bloxstrike-keys"
                StatusLabel.TextColor3 = Color3.fromRGB(88, 101, 242)
            end
        end)
    end)
    
    -- Button click
    SubmitButton.MouseButton1Click:Connect(function()
        local enteredKey = KeyInput.Text
        
        -- Check if entered key matches any valid key
        local isValidKey = false
        for _, key in ipairs(validKeys) do
            if enteredKey == key then
                isValidKey = true
                break
            end
        end
        
        if isValidKey then
            -- Correct key
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            StatusLabel.Text = "✓ Key accepted! Loading..."
            
            wait(1)
            
            -- Completely destroy the key GUI before proceeding
            KeyGui:Destroy()
            wait(0.5)
            
            keyEntered = true
        else
            -- Wrong key
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            StatusLabel.Text = "✗ Invalid key! Try again."
            KeyInput.Text = ""
            
            -- Shake animation
            local originalPos = KeyFrame.Position
            for i = 1, 3 do
                KeyFrame.Position = UDim2.new(0.5, 10, 0.5, 0)
                wait(0.05)
                KeyFrame.Position = UDim2.new(0.5, -10, 0.5, 0)
                wait(0.05)
            end
            KeyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
    end)
    
    -- Also allow Enter key
    KeyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            SubmitButton.MouseButton1Click:Fire()
        end
    end)
    
    -- Wait until key is entered
    repeat wait() until keyEntered
    
    return true
end

--[[ ANIMATED INTRO ]]--

local function ShowIntro()
    -- Create intro screen
    local IntroGui = Instance.new("ScreenGui")
    IntroGui.Name = "BloxStrikeIntro"
    IntroGui.Parent = game.CoreGui
    IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    IntroGui.ResetOnSpawn = false
    IntroGui.IgnoreGuiInset = true
    
    local IntroFrame = Instance.new("Frame")
    IntroFrame.Parent = IntroGui
    IntroFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    IntroFrame.BorderSizePixel = 0
    IntroFrame.Position = UDim2.new(0, 0, 0, 0)
    IntroFrame.Size = UDim2.new(1, 0, 1, 0)
    IntroFrame.BackgroundTransparency = 0
    IntroFrame.ZIndex = 10
    
    -- RGB for intro
    local hue = 0
    local function GetIntroRGB()
        hue = hue + 0.01
        if hue > 1 then hue = 0 end
        return Color3.fromHSV(hue, 0.8, 1)
    end
    
    -- Game icon
    local GameIcon = Instance.new("TextLabel")
    GameIcon.Parent = IntroFrame
    GameIcon.BackgroundTransparency = 1
    GameIcon.Position = UDim2.new(0.5, 0, 0.35, 0)
    GameIcon.Size = UDim2.new(0, 100, 0, 100)
    GameIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    GameIcon.Font = Enum.Font.GothamBold
    GameIcon.Text = "🎮"
    GameIcon.TextSize = 72
    GameIcon.TextTransparency = 1
    GameIcon.ZIndex = 11
    
    -- Script Name with RGB
    local ScriptName = Instance.new("TextLabel")
    ScriptName.Parent = IntroFrame
    ScriptName.BackgroundTransparency = 1
    ScriptName.Position = UDim2.new(0.5, 0, 0.48, 0)
    ScriptName.Size = UDim2.new(0, 600, 0, 80)
    ScriptName.AnchorPoint = Vector2.new(0.5, 0.5)
    ScriptName.Font = Enum.Font.GothamBold
    ScriptName.Text = "BLOXSTRIKE"
    ScriptName.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScriptName.TextSize = 48
    ScriptName.TextTransparency = 1
    ScriptName.ZIndex = 11
    
    local ScriptStroke = Instance.new("UIStroke")
    ScriptStroke.Color = Color3.fromRGB(255, 255, 255)
    ScriptStroke.Thickness = 3
    ScriptStroke.Transparency = 1
    ScriptStroke.Parent = ScriptName
    
    -- Subtitle with RGB
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Parent = IntroFrame
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0.5, 0, 0.58, 0)
    Subtitle.Size = UDim2.new(0, 400, 0, 40)
    Subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "v2.0 - Strike First, Strike Hard"
    Subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    Subtitle.TextSize = 20
    Subtitle.TextTransparency = 1
    Subtitle.ZIndex = 11
    
    -- Author with RGB
    local Author = Instance.new("TextLabel")
    Author.Parent = IntroFrame
    Author.BackgroundTransparency = 1
    Author.Position = UDim2.new(0.5, 0, 0.65, 0)
    Author.Size = UDim2.new(0, 300, 0, 30)
    Author.AnchorPoint = Vector2.new(0.5, 0.5)
    Author.Font = Enum.Font.GothamBold
    Author.Text = "Made by I Went Kimbo"
    Author.TextColor3 = Color3.fromRGB(100, 200, 255)
    Author.TextSize = 18
    Author.TextTransparency = 1
    Author.ZIndex = 11
    
    -- RGB animation for stroke
    task.spawn(function()
        while ScriptStroke and ScriptStroke.Parent do
            ScriptStroke.Color = GetIntroRGB()
            wait()
        end
    end)
    
    -- Animations
    task.spawn(function()
        wait(0.3)
        
        -- Fade in icon with scale animation
        TweenService:Create(GameIcon, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            TextTransparency = 0,
            Size = UDim2.new(0, 120, 0, 120)
        }):Play()
        wait(1.2)
        
        -- Fade in script name AND stroke together
        TweenService:Create(ScriptName, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        TweenService:Create(ScriptStroke, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0}):Play()
        wait(0.8)
        
        -- Fade in subtitle
        TweenService:Create(Subtitle, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        wait(0.7)
        
        -- Fade in author
        TweenService:Create(Author, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
        wait(1.5)
        
        -- Fade out everything
        TweenService:Create(GameIcon, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(ScriptName, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(ScriptStroke, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Transparency = 1}):Play()
        TweenService:Create(Subtitle, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(Author, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(IntroFrame, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        wait(1.2)
        
        -- Destroy intro
        IntroGui:Destroy()
    end)
end

--[[ GUI ]]--

local function CreateGUI()
    if game.CoreGui:FindFirstChild("BloxStrikeGUI") then
        game.CoreGui:FindFirstChild("BloxStrikeGUI"):Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BloxStrikeGUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- RGB Animation
    local hue = 0
    local function GetRGBColor()
        hue = hue + 0.0003
        if hue > 1 then hue = 0 end
        return Color3.fromHSV(hue, 0.7, 1)
    end
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 640, 0, 380)
    MainFrame.ZIndex = 1
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Thickness = 2.5
    MainStroke.Transparency = 0.3
    MainStroke.Parent = MainFrame
    
    -- RGB glow animation
    task.spawn(function()
        while MainFrame and MainFrame.Parent do
            MainStroke.Color = GetRGBColor()
            wait()
        end
    end)
    
    -- Gradient overlay
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
    }
    Gradient.Rotation = 45
    Gradient.Parent = MainFrame
    
    -- Minimize Icon
    local MinimizeIcon = Instance.new("TextButton")
    MinimizeIcon.Name = "MinimizeIcon"
    MinimizeIcon.Parent = ScreenGui
    MinimizeIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MinimizeIcon.Position = UDim2.new(0, 15, 0.5, -35)
    MinimizeIcon.Size = UDim2.new(0, 70, 0, 70)
    MinimizeIcon.Font = Enum.Font.GothamBold
    MinimizeIcon.Text = "🎮"
    MinimizeIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeIcon.TextSize = 32
    MinimizeIcon.Visible = false
    MinimizeIcon.Active = true
    MinimizeIcon.Draggable = true
    MinimizeIcon.ZIndex = 10
    
    local MinIconCorner = Instance.new("UICorner")
    MinIconCorner.CornerRadius = UDim.new(0, 16)
    MinIconCorner.Parent = MinimizeIcon
    
    local MinIconStroke = Instance.new("UIStroke")
    MinIconStroke.Color = Color3.fromRGB(255, 255, 255)
    MinIconStroke.Thickness = 2
    MinIconStroke.Transparency = 0.3
    MinIconStroke.Parent = MinimizeIcon
    
    task.spawn(function()
        while MinimizeIcon and MinimizeIcon.Parent do
            MinIconStroke.Color = GetRGBColor()
            wait()
        end
    end)
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 55)
    TitleBar.ZIndex = 2
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 14)
    TitleCorner.Parent = TitleBar
    
    local TitleBarCoverFrame = Instance.new("Frame")
    TitleBarCoverFrame.Parent = TitleBar
    TitleBarCoverFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TitleBarCoverFrame.BorderSizePixel = 0
    TitleBarCoverFrame.Position = UDim2.new(0, 0, 1, -14)
    TitleBarCoverFrame.Size = UDim2.new(1, 0, 0, 14)
    TitleBarCoverFrame.ZIndex = 2
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🎮 BLOXSTRIKE"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 3
    
    local VersionLabel = Instance.new("TextLabel")
    VersionLabel.Parent = TitleBar
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Position = UDim2.new(0, 20, 0, 30)
    VersionLabel.Size = UDim2.new(0.4, 0, 0, 20)
    VersionLabel.Font = Enum.Font.Gotham
    VersionLabel.Text = "v2.0 - Made by I Went Kimbo"
    VersionLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    VersionLabel.TextSize = 11
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
    VersionLabel.ZIndex = 3
    
    -- Control buttons
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = TitleBar
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 60)
    CloseBtn.Position = UDim2.new(1, -40, 0, 12)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 18
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 3
    
    local CloseBtnCorner = Instance.new("UICorner")
    CloseBtnCorner.CornerRadius = UDim.new(0, 8)
    CloseBtnCorner.Parent = CloseBtn
    
    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = TitleBar
    MinBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    MinBtn.Position = UDim2.new(1, -78, 0, 12)
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "─"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.TextSize = 18
    MinBtn.AutoButtonColor = false
    MinBtn.ZIndex = 3
    
    local MinBtnCorner = Instance.new("UICorner")
    MinBtnCorner.CornerRadius = UDim.new(0, 8)
    MinBtnCorner.Parent = MinBtn
    
    -- Make title bar draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Content container
    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 10, 0, 65)
    ContentContainer.Size = UDim2.new(1, -20, 1, -75)
    ContentContainer.ScrollBarThickness = 4
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 1200)
    ContentContainer.ZIndex = 2
    
    -- Helper function to create toggles
    local function CreateToggle(text, yPos, setting)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Parent = ContentContainer
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        ToggleFrame.Position = UDim2.new(0, 0, 0, yPos)
        ToggleFrame.Size = UDim2.new(0.48, 0, 0, 40)
        
        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(0, 8)
        ToggleCorner.Parent = ToggleFrame
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Parent = ToggleFrame
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
        ToggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.Text = text
        ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleLabel.TextSize = 13
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.ZIndex = 3
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Parent = ToggleFrame
        ToggleButton.BackgroundColor3 = Settings[setting] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 60, 70)
        ToggleButton.Position = UDim2.new(1, -50, 0.5, -10)
        ToggleButton.Size = UDim2.new(0, 40, 0, 20)
        ToggleButton.Text = ""
        ToggleButton.AutoButtonColor = false
        ToggleButton.ZIndex = 3
        
        local ToggleBtnCorner = Instance.new("UICorner")
        ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
        ToggleBtnCorner.Parent = ToggleButton
        
        local ToggleIndicator = Instance.new("Frame")
        ToggleIndicator.Parent = ToggleButton
        ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleIndicator.BorderSizePixel = 0
        ToggleIndicator.Position = Settings[setting] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
        ToggleIndicator.ZIndex = 4
        
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
                if Settings[setting] then EnableInfiniteJump() else DisableInfiniteJump() end
            elseif setting == "Fullbright" then
                if Settings[setting] then EnableFullbright() else DisableFullbright() end
            elseif setting == "ShowFOV" and FOVCircle then
                FOVCircle.Visible = Settings[setting]
            end
        end)
    end
    
    -- Helper function to create sliders
    local function CreateSlider(text, yPos, setting, min, max, increment)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Parent = ContentContainer
        SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        SliderFrame.Position = UDim2.new(0, 0, 0, yPos)
        SliderFrame.Size = UDim2.new(0.48, 0, 0, 50)
        
        local SliderCorner = Instance.new("UICorner")
        SliderCorner.CornerRadius = UDim.new(0, 8)
        SliderCorner.Parent = SliderFrame
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Parent = SliderFrame
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Position = UDim2.new(0, 15, 0, 5)
        SliderLabel.Size = UDim2.new(0.6, 0, 0, 15)
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.Text = text
        SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        SliderLabel.TextSize = 12
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.ZIndex = 3
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Parent = SliderFrame
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Position = UDim2.new(0.6, 0, 0, 5)
        ValueLabel.Size = UDim2.new(0.4, -15, 0, 15)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.Text = tostring(Settings[setting])
        ValueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        ValueLabel.TextSize = 12
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.ZIndex = 3
        
        local SliderBar = Instance.new("Frame")
        SliderBar.Parent = SliderFrame
        SliderBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        SliderBar.Position = UDim2.new(0, 15, 0, 30)
        SliderBar.Size = UDim2.new(1, -30, 0, 6)
        SliderBar.ZIndex = 3
        
        local SliderBarCorner = Instance.new("UICorner")
        SliderBarCorner.CornerRadius = UDim.new(1, 0)
        SliderBarCorner.Parent = SliderBar
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Parent = SliderBar
        SliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
        SliderFill.Size = UDim2.new((Settings[setting] - min) / (max - min), 0, 1, 0)
        SliderFill.ZIndex = 4
        
        local SliderFillCorner = Instance.new("UICorner")
        SliderFillCorner.CornerRadius = UDim.new(1, 0)
        SliderFillCorner.Parent = SliderFill
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Parent = SliderBar
        SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderButton.Position = UDim2.new((Settings[setting] - min) / (max - min), -6, 0.5, -6)
        SliderButton.Size = UDim2.new(0, 12, 0, 12)
        SliderButton.Text = ""
        SliderButton.AutoButtonColor = false
        SliderButton.ZIndex = 5
        
        local SliderBtnCorner = Instance.new("UICorner")
        SliderBtnCorner.CornerRadius = UDim.new(1, 0)
        SliderBtnCorner.Parent = SliderButton
        
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
                local mouse = UserInputService:GetMouseLocation()
                local relativePos = math.clamp((mouse.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                local value = math.floor((min + (max - min) * relativePos) / increment + 0.5) * increment
                
                Settings[setting] = value
                ValueLabel.Text = tostring(value)
                
                SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
                SliderButton.Position = UDim2.new(relativePos, -6, 0.5, -6)
            end
        end)
    end
    
    -- Helper function for dropdowns
    local function CreateDropdown(text, yPos, setting, options)
        local DropdownFrame = Instance.new("Frame")
        DropdownFrame.Parent = ContentContainer
        DropdownFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        DropdownFrame.Position = UDim2.new(0, 0, 0, yPos)
        DropdownFrame.Size = UDim2.new(0.48, 0, 0, 40)
        DropdownFrame.ClipsDescendants = false
        DropdownFrame.ZIndex = 5
        
        local DropdownCorner = Instance.new("UICorner")
        DropdownCorner.CornerRadius = UDim.new(0, 8)
        DropdownCorner.Parent = DropdownFrame
        
        local DropdownLabel = Instance.new("TextLabel")
        DropdownLabel.Parent = DropdownFrame
        DropdownLabel.BackgroundTransparency = 1
        DropdownLabel.Position = UDim2.new(0, 15, 0, 0)
        DropdownLabel.Size = UDim2.new(0.4, 0, 1, 0)
        DropdownLabel.Font = Enum.Font.Gotham
        DropdownLabel.Text = text
        DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownLabel.TextSize = 13
        DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
        DropdownLabel.ZIndex = 6
        
        local DropdownButton = Instance.new("TextButton")
        DropdownButton.Parent = DropdownFrame
        DropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        DropdownButton.Position = UDim2.new(0.45, 0, 0.5, -12)
        DropdownButton.Size = UDim2.new(0.5, -15, 0, 24)
        DropdownButton.Font = Enum.Font.Gotham
        DropdownButton.Text = Settings[setting]
        DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        DropdownButton.TextSize = 11
        DropdownButton.AutoButtonColor = false
        DropdownButton.ZIndex = 6
        
        local DropdownBtnCorner = Instance.new("UICorner")
        DropdownBtnCorner.CornerRadius = UDim.new(0, 6)
        DropdownBtnCorner.Parent = DropdownButton
        
        local DropdownList = Instance.new("Frame")
        DropdownList.Parent = DropdownFrame
        DropdownList.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        DropdownList.Position = UDim2.new(0.45, 0, 1, 5)
        DropdownList.Size = UDim2.new(0.5, -15, 0, #options * 25)
        DropdownList.Visible = false
        DropdownList.ZIndex = 10
        
        local DropdownListCorner = Instance.new("UICorner")
        DropdownListCorner.CornerRadius = UDim.new(0, 6)
        DropdownListCorner.Parent = DropdownList
        
        for i, option in ipairs(options) do
            local OptionButton = Instance.new("TextButton")
            OptionButton.Parent = DropdownList
            OptionButton.BackgroundTransparency = 1
            OptionButton.Position = UDim2.new(0, 0, 0, (i-1) * 25)
            OptionButton.Size = UDim2.new(1, 0, 0, 25)
            OptionButton.Font = Enum.Font.Gotham
            OptionButton.Text = option
            OptionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            OptionButton.TextSize = 11
            OptionButton.AutoButtonColor = false
            OptionButton.ZIndex = 11
            
            OptionButton.MouseEnter:Connect(function()
                OptionButton.BackgroundTransparency = 0.5
                OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end)
            
            OptionButton.MouseLeave:Connect(function()
                OptionButton.BackgroundTransparency = 1
            end)
            
            OptionButton.MouseButton1Click:Connect(function()
                Settings[setting] = option
                DropdownButton.Text = option
                DropdownList.Visible = false
            end)
        end
        
        DropdownButton.MouseButton1Click:Connect(function()
            DropdownList.Visible = not DropdownList.Visible
        end)
    end
    
    -- Helper function for buttons
    local function CreateButton(text, yPos, color, callback)
        local Button = Instance.new("TextButton")
        Button.Parent = ContentContainer
        Button.BackgroundColor3 = color
        Button.Position = UDim2.new(0, 0, 0, yPos)
        Button.Size = UDim2.new(0.48, 0, 0, 35)
        Button.Font = Enum.Font.GothamBold
        Button.Text = text
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.TextSize = 13
        Button.AutoButtonColor = false
        Button.ZIndex = 3
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 8)
        ButtonCorner.Parent = Button
        
        Button.MouseEnter:Connect(function()
            local h, s, v = Color3.toHSV(color)
            TweenService:Create(Button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromHSV(h, s, math.min(v + 0.1, 1))
            }):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {
                BackgroundColor3 = color
            }):Play()
        end)
        
        Button.MouseButton1Click:Connect(callback)
    end
    
    -- Section Headers
    local function CreateSectionHeader(text, yPos)
        local Header = Instance.new("TextLabel")
        Header.Parent = ContentContainer
        Header.BackgroundTransparency = 1
        Header.Position = UDim2.new(0, 0, 0, yPos)
        Header.Size = UDim2.new(1, 0, 0, 25)
        Header.Font = Enum.Font.GothamBold
        Header.Text = text
        Header.TextColor3 = Color3.fromRGB(100, 200, 255)
        Header.TextSize = 16
        Header.TextXAlignment = Enum.TextXAlignment.Left
        Header.ZIndex = 3
    end
    
    -- Create UI Elements
    local yOffset = 0
    
    -- Combat Section
    CreateSectionHeader("⚔️ COMBAT", yOffset)
    yOffset = yOffset + 30
    CreateToggle("Aimbot", yOffset, "Aimbot")
    CreateToggle("Silent Aim", yOffset, "SilentAim")
    yOffset = yOffset + 45
    CreateToggle("Triggerbot", yOffset, "Triggerbot")
    CreateToggle("Show FOV Circle", yOffset, "ShowFOV")
    yOffset = yOffset + 45
    CreateToggle("Wall Check", yOffset, "WallCheck")
    CreateToggle("Team Check", yOffset, "TeamCheck")
    yOffset = yOffset + 45
    CreateSlider("FOV Size", yOffset, "FOVSize", 50, 300, 10)
    CreateSlider("Max Distance", yOffset + 55, "MaxDistance", 100, 500, 50)
    yOffset = yOffset + 110
    CreateDropdown("Aim Part", yOffset, "AimPart", {"Head", "Torso", "HumanoidRootPart"})
    yOffset = yOffset + 60
    
    -- ESP Section
    CreateSectionHeader("👁️ ESP", yOffset)
    yOffset = yOffset + 30
    CreateToggle("Player ESP", yOffset, "PlayerESP")
    CreateToggle("Show Names", yOffset, "PlayerNames")
    yOffset = yOffset + 45
    CreateToggle("Show Boxes", yOffset, "PlayerBoxes")
    CreateToggle("Show Distance", yOffset, "PlayerDistance")
    yOffset = yOffset + 45
    CreateToggle("Show Health", yOffset, "PlayerHealth")
    CreateToggle("Show Tracers", yOffset, "PlayerTracers")
    yOffset = yOffset + 45
    CreateToggle("RGB Chams", yOffset, "PlayerChams")
    CreateToggle("Team Check (Red/Blue)", yOffset, "ESPTeamCheck")
    yOffset = yOffset + 60
    
    -- Movement Section
    CreateSectionHeader("🏃 MOVEMENT", yOffset)
    yOffset = yOffset + 30
    CreateToggle("Lock Walk Speed", yOffset, "LockWalkSpeed")
    CreateToggle("Lock Jump Power", yOffset, "LockJumpPower")
    yOffset = yOffset + 45
    CreateToggle("Infinite Jump", yOffset, "InfiniteJump")
    yOffset = yOffset + 45
    CreateSlider("Walk Speed", yOffset, "WalkSpeed", 16, 100, 1)
    CreateSlider("Jump Power", yOffset + 55, "JumpPower", 50, 120, 5)
    yOffset = yOffset + 125
    
    -- Misc Section
    CreateSectionHeader("⚙️ MISC", yOffset)
    yOffset = yOffset + 30
    CreateToggle("Anti-AFK", yOffset, "AntiAFK")
    CreateToggle("Fullbright", yOffset, "Fullbright")
    yOffset = yOffset + 60
    CreateButton("💾 Save Config", yOffset, Color3.fromRGB(50, 150, 50), function()
        SaveConfig()
        Notify("Config", "Configuration saved!")
    end)
    CreateButton("📁 Load Config", yOffset, Color3.fromRGB(50, 100, 200), function()
        LoadConfig()
        Notify("Config", "Configuration loaded!")
    end)
    yOffset = yOffset + 40
    CreateButton("🔄 Rejoin Server", yOffset, Color3.fromRGB(200, 100, 50), function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
    
    -- Update canvas size
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset + 100)
    
    -- Button functions
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        MinimizeIcon.Visible = true
    end)
    
    MinimizeIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MinimizeIcon.Visible = false
    end)
    
    -- Create FOV Circle
    CreateFOVCircle()
    
    -- Load config
    LoadConfig()
end

--[[ INIT ]]--

print("[BLOXSTRIKE] Loading BloxStrike Script v2.0...")

ShowIntro()

wait(7) -- Wait for intro to finish

-- Show key system
print("[BLOXSTRIKE] Awaiting key verification...")
local keyValid = ShowKeySystem()

if keyValid then
    print("[BLOXSTRIKE] ✓ Key verified! Loading GUI...")
    
    CreateGUI()
    
    print("========================================")
    print("🎮 BloxStrike Script Loaded")
    print("📝 Made by I Went Kimbo")
    print("✅ All systems active")
    print("========================================")
else
    print("[BLOXSTRIKE] ✗ Invalid key. Script terminated.")
end
