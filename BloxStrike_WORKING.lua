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
    AntiAFK = false,
    
    -- Aimbot
    SilentAim = false,
    Triggerbot = false,
    ShowFOV = false,
    FOVSize = 100,
    MaxDistance = 500,
    WallCheck = true,
    TeamCheck = true,
    
    -- Weapon Mods
    NoRecoil = false,
    NoSpread = false,
    InfiniteAmmo = false,
    RapidFire = false,
    
    -- Misc
    WalkSpeed = 16,
    JumpPower = 50,
    LockWalkSpeed = false,
    LockJumpPower = false,
    InfiniteJump = false,
    Noclip = false,
    
    -- Quality of Life
    Fullbright = false,
    NoFlash = false,
    ThirdPerson = false,
    
    -- Enemy ESP
    EnemyESP = false,
    EnemyNames = false,
    EnemyBoxes = false,
    EnemyDistance = false,
    EnemyHealth = false,
    
    -- Team ESP
    TeamESP = false,
    TeamNames = false,
    TeamBoxes = false,
    TeamDistance = false,
    TeamHealth = false,
}

local ConfigFile = "BloxStrike_Config.json"

-- Status tracking
local Status = {
    CurrentAction = "In Match",
    Kills = 0,
    Deaths = 0,
    Weapon = "None",
}

-- ESP Storage
local ESPObjects = {
    Enemies = {},
    Teammates = {},
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

--[[ MOVEMENT MODS ]]--

task.spawn(function()
    RunService.Heartbeat:Connect(function()
        pcall(function()
            if Character and Character:FindFirstChild("Humanoid") then
                local humanoid = Character.Humanoid
                
                if Settings.LockWalkSpeed then
                    humanoid.WalkSpeed = Settings.WalkSpeed
                end
                
                if Settings.LockJumpPower then
                    humanoid.JumpPower = Settings.JumpPower
                end
            end
        end)
    end)
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and Character and Character:FindFirstChild("Humanoid") then
        Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

task.spawn(function()
    RunService.Stepped:Connect(function()
        if Settings.Noclip and Character then
            pcall(function()
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        end
    end)
end)

--[[ VISUAL MODS ]]--

task.spawn(function()
    local Lighting = game:GetService("Lighting")
    RunService.Heartbeat:Connect(function()
        if Settings.Fullbright then
            pcall(function()
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            end)
        end
    end)
end)

task.spawn(function()
    local Camera = Workspace.CurrentCamera
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

task.spawn(function()
    RunService.RenderStepped:Connect(function()
        pcall(function()
            if Settings.ThirdPerson and LocalPlayer.Character then
                LocalPlayer.CameraMaxZoomDistance = 10
                LocalPlayer.CameraMinZoomDistance = 10
            else
                LocalPlayer.CameraMaxZoomDistance = 0.5
                LocalPlayer.CameraMinZoomDistance = 0.5
            end
        end)
    end)
end)

--[[ KEY SYSTEM ]]--

local function ShowKeySystem()
    -- Hidden keys (encoded)
    local validKeys = {
        string.char(66, 76, 79, 88),                  -- "BLOX"
        string.char(98, 108, 111, 120),               -- "blox"
        string.char(83, 84, 82, 73, 75, 69),          -- "STRIKE"
        string.char(115, 116, 114, 105, 107, 101),    -- "strike"
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
    Title.Text = "🔐 KEY SYSTEM"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 24
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Parent = KeyFrame
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0, 0, 0, 70)
    Subtitle.Size = UDim2.new(1, 0, 0, 50)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "BloxStrike FPS Script\nEnter key to continue or click skip"
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
    
    -- Skip button
    local SkipButton = Instance.new("TextButton")
    SkipButton.Parent = KeyFrame
    SkipButton.BackgroundColor3 = Color3.fromRGB(52, 152, 219)
    SkipButton.Position = UDim2.new(0.1, 0, 0, 255)
    SkipButton.Size = UDim2.new(0.8, 0, 0, 35)
    SkipButton.Font = Enum.Font.GothamBold
    SkipButton.Text = "⚡ SKIP (Free Access)"
    SkipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SkipButton.TextSize = 12
    SkipButton.AutoButtonColor = false
    
    local SkipCorner = Instance.new("UICorner")
    SkipCorner.CornerRadius = UDim.new(0, 6)
    SkipCorner.Parent = SkipButton
    
    SkipButton.MouseButton1Click:Connect(function()
        StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        StatusLabel.Text = "✓ Skipping! Loading..."
        
        wait(1)
        
        KeyGui:Destroy()
        wait(0.5)
        
        keyEntered = true
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
            StatusLabel.Text = "✗ Invalid key! Try again or skip."
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
    
    -- Icon
    local Icon = Instance.new("TextLabel")
    Icon.Parent = IntroFrame
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(0.5, 0, 0.35, 0)
    Icon.Size = UDim2.new(0, 100, 0, 100)
    Icon.AnchorPoint = Vector2.new(0.5, 0.5)
    Icon.Font = Enum.Font.GothamBold
    Icon.Text = "🎯"
    Icon.TextSize = 72
    Icon.TextTransparency = 1
    Icon.ZIndex = 11
    
    -- Script Name with RGB
    local ScriptName = Instance.new("TextLabel")
    ScriptName.Parent = IntroFrame
    ScriptName.BackgroundTransparency = 1
    ScriptName.Position = UDim2.new(0.5, 0, 0.48, 0)
    ScriptName.Size = UDim2.new(0, 600, 0, 80)
    ScriptName.AnchorPoint = Vector2.new(0.5, 0.5)
    ScriptName.Font = Enum.Font.GothamBold
    ScriptName.Text = "BLOXSTRIKE FPS"
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
    Subtitle.Text = "v1 BETA - Tactical Superiority"
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
        
        -- Fade in icon
        TweenService:Create(Icon, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            TextTransparency = 0,
            Size = UDim2.new(0, 120, 0, 120)
        }):Play()
        wait(1.2)
        
        -- Fade in script name
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
        TweenService:Create(Icon, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
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
    MainFrame.Size = UDim2.new(0, 640, 0, 360)
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
    
    -- Minimize Icon
    local MinimizeIcon = Instance.new("TextButton")
    MinimizeIcon.Name = "MinimizeIcon"
    MinimizeIcon.Parent = ScreenGui
    MinimizeIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MinimizeIcon.Position = UDim2.new(0, 15, 0.5, -35)
    MinimizeIcon.Size = UDim2.new(0, 70, 0, 70)
    MinimizeIcon.Font = Enum.Font.GothamBold
    MinimizeIcon.Text = "🎯"
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
    
    -- Hide bottom corners
    local TitleBarCoverFrame = Instance.new("Frame")
    TitleBarCoverFrame.Parent = TitleBar
    TitleBarCoverFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TitleBarCoverFrame.BorderSizePixel = 0
    TitleBarCoverFrame.Position = UDim2.new(0, 0, 1, -14)
    TitleBarCoverFrame.Size = UDim2.new(1, 0, 0, 14)
    TitleBarCoverFrame.ZIndex = 2
    
    -- Title text
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = TitleBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.new(0, 20, 0, 5)
    TitleLabel.Size = UDim2.new(0, 300, 0, 25)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "🎯 BLOXSTRIKE FPS"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 3
    
    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Parent = TitleBar
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Position = UDim2.new(0, 20, 0, 28)
    SubtitleLabel.Size = UDim2.new(0, 300, 0, 20)
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.Text = "v1 BETA | Made by I Went Kimbo"
    SubtitleLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    SubtitleLabel.TextSize = 11
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.ZIndex = 3
    
    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = TitleBar
    CloseBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    CloseBtn.Position = UDim2.new(1, -40, 0, 12.5)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 20
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 3
    
    local CloseBtnCorner = Instance.new("UICorner")
    CloseBtnCorner.CornerRadius = UDim.new(0, 8)
    CloseBtnCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Minimize button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = TitleBar
    MinBtn.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
    MinBtn.Position = UDim2.new(1, -75, 0, 12.5)
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "−"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.TextSize = 20
    MinBtn.AutoButtonColor = false
    MinBtn.ZIndex = 3
    
    local MinBtnCorner = Instance.new("UICorner")
    MinBtnCorner.CornerRadius = UDim.new(0, 8)
    MinBtnCorner.Parent = MinBtn
    
    MinBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        MinimizeIcon.Visible = true
    end)
    
    MinimizeIcon.MouseButton1Click:Connect(function()
        MainFrame.Visible = true
        MinimizeIcon.Visible = false
    end)
    
    -- Make title bar draggable
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Content Frame
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 0, 0, 55)
    ContentFrame.Size = UDim2.new(1, 0, 1, -55)
    ContentFrame.ZIndex = 2
    
    -- Success message
    local SuccessLabel = Instance.new("TextLabel")
    SuccessLabel.Parent = ContentFrame
    SuccessLabel.BackgroundTransparency = 1
    SuccessLabel.Position = UDim2.new(0, 0, 0.4, 0)
    SuccessLabel.Size = UDim2.new(1, 0, 0, 60)
    SuccessLabel.Font = Enum.Font.GothamBold
    SuccessLabel.Text = "✓ BLOXSTRIKE FPS LOADED"
    SuccessLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    SuccessLabel.TextSize = 24
    SuccessLabel.ZIndex = 3
    
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Parent = ContentFrame
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Position = UDim2.new(0, 0, 0.55, 0)
    InfoLabel.Size = UDim2.new(1, 0, 0, 40)
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.Text = "All systems active!\nFeatures ready to use."
    InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    InfoLabel.TextSize = 14
    InfoLabel.ZIndex = 3
    
    print("[BLOXSTRIKE] GUI Created Successfully!")
end

--[[ INIT ]]--

print("[BLOXSTRIKE] Loading BloxStrike FPS v1 BETA...")

ShowIntro()

wait(7) -- Wait for intro to finish

-- Show key system
print("[BLOXSTRIKE] Awaiting key verification...")
local keyValid = ShowKeySystem()

if keyValid then
    print("[BLOXSTRIKE] ✓ Key verified! Loading GUI...")
    
    CreateGUI()
    
    print("========================================")
    print("🎯 BloxStrike FPS Loaded")
    print("📝 Made by I Went Kimbo")
    print("✅ All systems active")
    print("========================================")
else
    print("[BLOXSTRIKE] ✗ Invalid key. Script terminated.")
end
