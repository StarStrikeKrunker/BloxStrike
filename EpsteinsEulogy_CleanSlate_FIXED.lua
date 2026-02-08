-- Jailbreak Script 2026 - Made by I Went Kimbo
-- Version: v1 BETA - Clean Slate

print("[EULOGY DEBUG] Script starting...")

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

-- Settings (Clean slate)
local Settings = {
    AntiAFK = false,
}

local ConfigFile = "EpsteinsEulogy_Config.json"

-- Status tracking
local Status = {
    CurrentAction = "Idle",
}

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

--[[ INTRO ]]--

local function ShowIntro()
    local IntroGui = Instance.new("ScreenGui")
    IntroGui.Name = "EulogyIntro"
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
    
    -- Pill icon
    local PillIcon = Instance.new("TextLabel")
    PillIcon.Parent = IntroFrame
    PillIcon.BackgroundTransparency = 1
    PillIcon.Position = UDim2.new(0.5, 0, 0.35, 0)
    PillIcon.Size = UDim2.new(0, 100, 0, 100)
    PillIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    PillIcon.Font = Enum.Font.GothamBold
    PillIcon.Text = "💀"
    PillIcon.TextSize = 72
    PillIcon.TextTransparency = 1
    PillIcon.ZIndex = 11
    
    -- Script Name with RGB
    local ScriptName = Instance.new("TextLabel")
    ScriptName.Parent = IntroFrame
    ScriptName.BackgroundTransparency = 1
    ScriptName.Position = UDim2.new(0.5, 0, 0.48, 0)
    ScriptName.Size = UDim2.new(0, 600, 0, 80)
    ScriptName.AnchorPoint = Vector2.new(0.5, 0.5)
    ScriptName.Font = Enum.Font.GothamBold
    ScriptName.Text = "EPSTEIN'S EULOGY"
    ScriptName.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScriptName.TextSize = 48
    ScriptName.TextTransparency = 1
    ScriptName.ZIndex = 11
    
    local ScriptStroke = Instance.new("UIStroke")
    ScriptStroke.Color = Color3.fromRGB(255, 255, 255)
    ScriptStroke.Thickness = 3
    ScriptStroke.Transparency = 1
    ScriptStroke.Parent = ScriptName
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Parent = IntroFrame
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0.5, 0, 0.58, 0)
    Subtitle.Size = UDim2.new(0, 400, 0, 40)
    Subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "v1 BETA - He Didn't Kill Himself Nga..."
    Subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    Subtitle.TextSize = 20
    Subtitle.TextTransparency = 1
    Subtitle.ZIndex = 11
    
    -- Author
    local Author = Instance.new("TextLabel")
    Author.Parent = IntroFrame
    Author.BackgroundTransparency = 1
    Author.Position = UDim2.new(0.5, 0, 0.65, 0)
    Author.Size = UDim2.new(0, 300, 0, 30)
    Author.AnchorPoint = Vector2.new(0.5, 0.5)
    Author.Font = Enum.Font.GothamBold
    Author.Text = "Made by I Went Kimbo"
    Author.TextColor3 = Color3.fromRGB(255, 100, 100)
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
        
        -- Fade in pill
        TweenService:Create(PillIcon, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 0
        }):Play()
        
        wait(0.5)
        
        -- Fade in script name and stroke
        TweenService:Create(ScriptName, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 0
        }):Play()
        
        TweenService:Create(ScriptStroke, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Transparency = 0
        }):Play()
        
        wait(0.7)
        
        -- Fade in subtitle
        TweenService:Create(Subtitle, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 0
        }):Play()
        
        wait(0.5)
        
        -- Fade in author
        TweenService:Create(Author, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 0
        }):Play()
        
        wait(3)
        
        -- Fade out everything
        TweenService:Create(IntroFrame, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        }):Play()
        
        TweenService:Create(PillIcon, TweenInfo.new(1), {TextTransparency = 1}):Play()
        TweenService:Create(ScriptName, TweenInfo.new(1), {TextTransparency = 1}):Play()
        TweenService:Create(ScriptStroke, TweenInfo.new(1), {Transparency = 1}):Play()
        TweenService:Create(Subtitle, TweenInfo.new(1), {TextTransparency = 1}):Play()
        TweenService:Create(Author, TweenInfo.new(1), {TextTransparency = 1}):Play()
        
        wait(1.2)
        
        -- Destroy intro
        IntroGui:Destroy()
    end)
end

--[[ KEY SYSTEM ]]--

local function ShowKeySystem()
    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "EulogyKeySystem"
    KeyGui.Parent = game.CoreGui
    KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KeyGui.ResetOnSpawn = false
    
    local KeyFrame = Instance.new("Frame")
    KeyFrame.Parent = KeyGui
    KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    KeyFrame.BorderSizePixel = 0
    KeyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    KeyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    KeyFrame.Size = UDim2.new(0, 450, 0, 300)
    
    local KeyCorner = Instance.new("UICorner")
    KeyCorner.CornerRadius = UDim.new(0, 14)
    KeyCorner.Parent = KeyFrame
    
    local KeyStroke = Instance.new("UIStroke")
    KeyStroke.Color = Color3.fromRGB(100, 200, 255)
    KeyStroke.Thickness = 2.5
    KeyStroke.Transparency = 0.3
    KeyStroke.Parent = KeyFrame
    
    local KeyTitle = Instance.new("TextLabel")
    KeyTitle.Parent = KeyFrame
    KeyTitle.BackgroundTransparency = 1
    KeyTitle.Position = UDim2.new(0, 0, 0, 30)
    KeyTitle.Size = UDim2.new(1, 0, 0, 40)
    KeyTitle.Font = Enum.Font.GothamBold
    KeyTitle.Text = "🔐 KEY SYSTEM"
    KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyTitle.TextSize = 26
    
    local KeySubtitle = Instance.new("TextLabel")
    KeySubtitle.Parent = KeyFrame
    KeySubtitle.BackgroundTransparency = 1
    KeySubtitle.Position = UDim2.new(0, 0, 0, 75)
    KeySubtitle.Size = UDim2.new(1, 0, 0, 25)
    KeySubtitle.Font = Enum.Font.Gotham
    KeySubtitle.Text = "Enter your key to continue"
    KeySubtitle.TextColor3 = Color3.fromRGB(180, 180, 190)
    KeySubtitle.TextSize = 15
    
    local KeyInput = Instance.new("TextBox")
    KeyInput.Parent = KeyFrame
    KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    KeyInput.BorderSizePixel = 0
    KeyInput.Position = UDim2.new(0, 50, 0, 120)
    KeyInput.Size = UDim2.new(0, 350, 0, 45)
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.PlaceholderText = "Enter Key Here..."
    KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 15
    KeyInput.ClearTextOnFocus = false
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 10)
    InputCorner.Parent = KeyInput
    
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Parent = KeyFrame
    SubmitButton.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Position = UDim2.new(0, 50, 0, 180)
    SubmitButton.Size = UDim2.new(0, 350, 0, 45)
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Text = "Submit Key"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 16
    SubmitButton.AutoButtonColor = false
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = SubmitButton
    
    local GetKeyButton = Instance.new("TextButton")
    GetKeyButton.Parent = KeyFrame
    GetKeyButton.BackgroundColor3 = Color3.fromRGB(39, 174, 96)
    GetKeyButton.BorderSizePixel = 0
    GetKeyButton.Position = UDim2.new(0, 50, 0, 235)
    GetKeyButton.Size = UDim2.new(0, 350, 0, 40)
    GetKeyButton.Font = Enum.Font.GothamMedium
    GetKeyButton.Text = "Get Key (Discord)"
    GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyButton.TextSize = 14
    GetKeyButton.AutoButtonColor = false
    
    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 10)
    GetKeyCorner.Parent = GetKeyButton
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Parent = KeyFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 1, -30)
    StatusLabel.Size = UDim2.new(1, 0, 0, 25)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    StatusLabel.TextSize = 13
    
    local validKey = "EPSTEIN2026"
    local keySubmitted = false
    
    SubmitButton.MouseButton1Click:Connect(function()
        if keySubmitted then return end
        
        local enteredKey = KeyInput.Text
        
        if enteredKey == validKey then
            keySubmitted = true
            StatusLabel.Text = "✓ Key Valid! Loading..."
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            
            wait(0.5)
            KeyGui:Destroy()
        else
            StatusLabel.Text = "✗ Invalid Key"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            
            TweenService:Create(KeyInput, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 20, 20)}):Play()
            wait(0.1)
            TweenService:Create(KeyInput, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play()
        end
    end)
    
    GetKeyButton.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/yourlink")
        StatusLabel.Text = "Discord link copied!"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    end)
    
    SubmitButton.MouseEnter:Connect(function()
        TweenService:Create(SubmitButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 130, 210)}):Play()
    end)
    
    SubmitButton.MouseLeave:Connect(function()
        TweenService:Create(SubmitButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 120, 200)}):Play()
    end)
    
    GetKeyButton.MouseEnter:Connect(function()
        TweenService:Create(GetKeyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(49, 184, 106)}):Play()
    end)
    
    GetKeyButton.MouseLeave:Connect(function()
        TweenService:Create(GetKeyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(39, 174, 96)}):Play()
    end)
    
    while not keySubmitted do
        wait(0.1)
    end
    
    return keySubmitted
end

--[[ GUI ]]--

local function CreateGUI()
    if game.CoreGui:FindFirstChild("EpsteinsEulogyGUI") then
        game.CoreGui:FindFirstChild("EpsteinsEulogyGUI"):Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EpsteinsEulogyGUI"
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
    
    task.spawn(function()
        while MainFrame and MainFrame.Parent do
            MainStroke.Color = GetRGBColor()
            wait()
        end
    end)
    
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
    MinimizeIcon.Text = "💀"
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
        while MinIconStroke and MinIconStroke.Parent do
            MinIconStroke.Color = GetRGBColor()
            wait()
        end
    end)
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 54)
    TitleBar.ZIndex = 2
    
    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 14)
    TitleBarCorner.Parent = TitleBar
    
    local TitleBarCoverFrame = Instance.new("Frame")
    TitleBarCoverFrame.Parent = TitleBar
    TitleBarCoverFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    TitleBarCoverFrame.BorderSizePixel = 0
    TitleBarCoverFrame.Position = UDim2.new(0, 0, 1, -14)
    TitleBarCoverFrame.Size = UDim2.new(1, 0, 0, 14)
    TitleBarCoverFrame.ZIndex = 2
    
    local Title = Instance.new("TextLabel")
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "💀 EPSTEIN'S EULOGY"
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
    VersionLabel.Text = "v1 BETA - Clean Slate"
    VersionLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
    VersionLabel.TextSize = 11
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
    VersionLabel.ZIndex = 3
    
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
    
    -- Make TitleBar draggable
    local dragging, dragInput, dragStart, startPos
    
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
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 10, 0, 64)
    TabContainer.Size = UDim2.new(1, -20, 0, 40)
    TabContainer.ZIndex = 2
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 10, 0, 114)
    ContentContainer.Size = UDim2.new(1, -20, 1, -124)
    ContentContainer.ZIndex = 2
    
    local pages = {}
    
    -- HOME PAGE
    local HomePage = Instance.new("Frame")
    HomePage.Parent = ContentContainer
    HomePage.BackgroundTransparency = 1
    HomePage.Size = UDim2.new(1, 0, 1, 0)
    HomePage.Visible = true
    pages["Home"] = HomePage
    
    local WelcomeTitle = Instance.new("TextLabel")
    WelcomeTitle.Parent = HomePage
    WelcomeTitle.BackgroundTransparency = 1
    WelcomeTitle.Position = UDim2.new(0, 20, 0, 20)
    WelcomeTitle.Size = UDim2.new(1, -40, 0, 40)
    WelcomeTitle.Font = Enum.Font.GothamBold
    WelcomeTitle.Text = "Welcome to Epstein's Eulogy"
    WelcomeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    WelcomeTitle.TextSize = 24
    WelcomeTitle.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeTitle.ZIndex = 3
    
    local WelcomeSubtitle = Instance.new("TextLabel")
    WelcomeSubtitle.Parent = HomePage
    WelcomeSubtitle.BackgroundTransparency = 1
    WelcomeSubtitle.Position = UDim2.new(0, 20, 0, 65)
    WelcomeSubtitle.Size = UDim2.new(1, -40, 0, 25)
    WelcomeSubtitle.Font = Enum.Font.Gotham
    WelcomeSubtitle.Text = "Clean Slate - Ready to build your mods!"
    WelcomeSubtitle.TextColor3 = Color3.fromRGB(180, 180, 190)
    WelcomeSubtitle.TextSize = 16
    WelcomeSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeSubtitle.ZIndex = 3
    
    local InfoBox = Instance.new("Frame")
    InfoBox.Parent = HomePage
    InfoBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    InfoBox.BorderSizePixel = 0
    InfoBox.Position = UDim2.new(0, 20, 0, 110)
    InfoBox.Size = UDim2.new(1, -40, 0, 100)
    InfoBox.ZIndex = 3
    
    local InfoCorner = Instance.new("UICorner")
    InfoCorner.CornerRadius = UDim.new(0, 10)
    InfoCorner.Parent = InfoBox
    
    local InfoText = Instance.new("TextLabel")
    InfoText.Parent = InfoBox
    InfoText.BackgroundTransparency = 1
    InfoText.Position = UDim2.new(0, 15, 0, 10)
    InfoText.Size = UDim2.new(1, -30, 1, -20)
    InfoText.Font = Enum.Font.Gotham
    InfoText.Text = [[📝 This is a clean GUI framework

• All mods and features have been removed
• The GUI structure and tabs are ready
• Add your own features in the Settings tab
• Customize and build as needed!]]
    InfoText.TextColor3 = Color3.fromRGB(200, 200, 210)
    InfoText.TextSize = 13
    InfoText.TextXAlignment = Enum.TextXAlignment.Left
    InfoText.TextYAlignment = Enum.TextYAlignment.Top
    InfoText.TextWrapped = true
    InfoText.ZIndex = 4
    
    -- STATUS PAGE
    local StatusPage = Instance.new("Frame")
    StatusPage.Parent = ContentContainer
    StatusPage.BackgroundTransparency = 1
    StatusPage.Size = UDim2.new(1, 0, 1, 0)
    StatusPage.Visible = false
    pages["Status"] = StatusPage
    
    local StatusTitle = Instance.new("TextLabel")
    StatusTitle.Parent = StatusPage
    StatusTitle.BackgroundTransparency = 1
    StatusTitle.Position = UDim2.new(0, 20, 0, 10)
    StatusTitle.Size = UDim2.new(1, -40, 0, 30)
    StatusTitle.Font = Enum.Font.GothamBold
    StatusTitle.Text = "📊 System Status"
    StatusTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    StatusTitle.TextSize = 20
    StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
    StatusTitle.ZIndex = 3
    
    local function CreateStatusLabel(parent, text, yPos)
        local label = Instance.new("TextLabel")
        label.Parent = parent
        label.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        label.BorderSizePixel = 0
        label.Position = UDim2.new(0, 20, 0, yPos)
        label.Size = UDim2.new(1, -40, 0, 35)
        label.Font = Enum.Font.GothamMedium
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 210)
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 3
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = label
        
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 15)
        padding.Parent = label
        
        return label
    end
    
    CreateStatusLabel(StatusPage, "📌 Player: " .. LocalPlayer.Name, 50)
    CreateStatusLabel(StatusPage, "🎮 Status: " .. Status.CurrentAction, 95)
    CreateStatusLabel(StatusPage, "⚙️ Version: v1 BETA (Clean Slate)", 140)
    
    -- SETTINGS PAGE
    local SettingsPage = Instance.new("Frame")
    SettingsPage.Parent = ContentContainer
    SettingsPage.BackgroundTransparency = 1
    SettingsPage.Size = UDim2.new(1, 0, 1, 0)
    SettingsPage.Visible = false
    pages["Settings"] = SettingsPage
    
    local function CreateToggle(parent, text, yPos, settingKey)
        local isOn = Settings[settingKey]
        
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Parent = parent
        toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        toggleFrame.Position = UDim2.new(0, 20, 0, yPos)
        toggleFrame.Size = UDim2.new(0, 300, 0, 38)
        toggleFrame.ZIndex = 3
        
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 10)
        frameCorner.Parent = toggleFrame
        
        local label = Instance.new("TextLabel")
        label.Parent = toggleFrame
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 15, 0, 0)
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Font = Enum.Font.GothamSemibold
        label.Text = text
        label.TextColor3 = Color3.fromRGB(230, 230, 240)
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 4
        
        local toggleButton = Instance.new("TextButton")
        toggleButton.Parent = toggleFrame
        toggleButton.BackgroundColor3 = isOn and Color3.fromRGB(60, 120, 200) or Color3.fromRGB(50, 50, 60)
        toggleButton.BorderSizePixel = 0
        toggleButton.Position = UDim2.new(1, -60, 0.5, -12)
        toggleButton.Size = UDim2.new(0, 48, 0, 24)
        toggleButton.Text = ""
        toggleButton.AutoButtonColor = false
        toggleButton.ZIndex = 4
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(1, 0)
        toggleCorner.Parent = toggleButton
        
        local indicator = Instance.new("Frame")
        indicator.Parent = toggleButton
        indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        indicator.BorderSizePixel = 0
        indicator.Position = isOn and UDim2.new(0, 26, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        indicator.Size = UDim2.new(0, 20, 0, 20)
        indicator.ZIndex = 5
        
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(1, 0)
        indicatorCorner.Parent = indicator
        
        toggleButton.MouseButton1Click:Connect(function()
            Settings[settingKey] = not Settings[settingKey]
            isOn = Settings[settingKey]
            
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = isOn and Color3.fromRGB(60, 120, 200) or Color3.fromRGB(50, 50, 60)
            }):Play()
            
            TweenService:Create(indicator, TweenInfo.new(0.2), {
                Position = isOn and UDim2.new(0, 26, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            }):Play()
            
            SaveConfig()
        end)
        
        return toggleFrame
    end
    
    local function CreateButton(parent, text, xPos, yPos, width, height, color, callback)
        local button = Instance.new("TextButton")
        button.Parent = parent
        button.BackgroundColor3 = color
        button.BorderSizePixel = 0
        button.Position = UDim2.new(0, xPos, 0, yPos)
        button.Size = UDim2.new(0, width, 0, height)
        button.Font = Enum.Font.GothamBold
        button.Text = text
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 13
        button.AutoButtonColor = false
        button.ZIndex = 3
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button
        
        button.MouseButton1Click:Connect(callback)
        
        button.MouseEnter:Connect(function()
            local h, s, v = color:ToHSV()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromHSV(h, s, math.min(v + 0.1, 1))
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        end)
        
        return button
    end
    
    CreateToggle(SettingsPage, "🚫 Anti-AFK", 20, "AntiAFK")
    
    CreateButton(SettingsPage, "🔄 Rejoin Server", 20, 80, 180, 38, Color3.fromRGB(60, 120, 200), function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
    
    CreateButton(SettingsPage, "🎲 Random Server", 210, 80, 180, 38, Color3.fromRGB(100, 150, 50), function()
        local TeleportService = game:GetService("TeleportService")
        local success, servers = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if success then
            for _, server in pairs(servers.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    break
                end
            end
        end
    end)
    
    CreateButton(SettingsPage, "💾 Save Config", 20, 130, 180, 38, Color3.fromRGB(39, 174, 96), function()
        SaveConfig()
        Notify("Config", "Settings saved!")
    end)
    
    CreateButton(SettingsPage, "📁 Load Config", 210, 130, 180, 38, Color3.fromRGB(52, 152, 219), function()
        if LoadConfig() then
            Notify("Config", "Settings loaded!")
        else
            Notify("Config", "No saved config found")
        end
    end)
    
    -- Create Tabs
    local tabs = {"Home", "Status", "Settings"}
    local currentTab = "Home"
    
    for i, tabName in ipairs(tabs) do
        local isActive = tabName == currentTab
        
        local tabButton = Instance.new("TextButton")
        tabButton.Parent = TabContainer
        tabButton.BackgroundColor3 = isActive and Color3.fromRGB(30, 30, 40) or Color3.fromRGB(20, 20, 28)
        tabButton.Position = UDim2.new((i-1) / #tabs, 2, 0, 5)
        tabButton.Size = UDim2.new(1 / #tabs, -4, 0, 30)
        tabButton.Font = Enum.Font.GothamBold
        tabButton.Text = tabName
        tabButton.TextColor3 = isActive and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 160)
        tabButton.TextSize = 13
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
    
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(240, 70, 80)}):Play()
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 50, 60)}):Play()
    end)
    
    MinBtn.MouseEnter:Connect(function()
        TweenService:Create(MinBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 130, 210)}):Play()
    end)
    
    MinBtn.MouseLeave:Connect(function()
        TweenService:Create(MinBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 120, 200)}):Play()
    end)
    
    LoadConfig()
end

--[[ INIT ]]--

print("[EULOGY] Loading Epstein's Eulogy v1 BETA...")

ShowIntro()

wait(7)

print("[EULOGY] Awaiting key verification...")
local keyValid = ShowKeySystem()

if keyValid then
    print("[EULOGY] ✓ Key verified! Loading GUI...")
    
    CreateGUI()
    
    print("========================================")
    print("🎮 Epstein's Eulogy Loaded")
    print("📝 Made by I Went Kimbo")
    print("✅ Clean slate - ready for mods!")
    print("========================================")
else
    print("[EULOGY] ✗ Invalid key. Script terminated.")
end
