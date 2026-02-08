-- Jailbreak Script 2026 - Made by I Went Kimbo
-- Version: v1 BETA - "He Didn't Kill Himself Nga..."

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

-- Settings (Clean slate - no mods)
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

--[[ INTRO SCREEN ]]--

local function ShowIntro()
    local IntroGui = Instance.new("ScreenGui")
    IntroGui.Name = "IntroScreen"
    IntroGui.Parent = game.CoreGui
    IntroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    IntroGui.DisplayOrder = 999999
    
    local IntroFrame = Instance.new("Frame")
    IntroFrame.Parent = IntroGui
    IntroFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    IntroFrame.BorderSizePixel = 0
    IntroFrame.Position = UDim2.new(0, 0, 0, 0)
    IntroFrame.Size = UDim2.new(1, 0, 1, 0)
    IntroFrame.ZIndex = 1
    
    local function GetRGBColor()
        local t = tick() * 2
        local r = math.floor(127 * math.sin(t) + 128)
        local g = math.floor(127 * math.sin(t + 2) + 128)
        local b = math.floor(127 * math.sin(t + 4) + 128)
        return Color3.fromRGB(r, g, b)
    end
    
    local IntroTitle = Instance.new("TextLabel")
    IntroTitle.Parent = IntroFrame
    IntroTitle.BackgroundTransparency = 1
    IntroTitle.Position = UDim2.new(0.5, 0, 0.35, 0)
    IntroTitle.AnchorPoint = Vector2.new(0.5, 0.5)
    IntroTitle.Size = UDim2.new(0, 600, 0, 80)
    IntroTitle.Font = Enum.Font.GothamBold
    IntroTitle.Text = "Epstein's Eulogy"
    IntroTitle.TextSize = 52
    IntroTitle.TextTransparency = 0
    IntroTitle.ZIndex = 2
    
    task.spawn(function()
        while IntroTitle and IntroTitle.Parent do
            IntroTitle.TextColor3 = GetRGBColor()
            wait()
        end
    end)
    
    local IntroSubtitle = Instance.new("TextLabel")
    IntroSubtitle.Parent = IntroFrame
    IntroSubtitle.BackgroundTransparency = 1
    IntroSubtitle.Position = UDim2.new(0.5, 0, 0.45, 0)
    IntroSubtitle.AnchorPoint = Vector2.new(0.5, 0.5)
    IntroSubtitle.Size = UDim2.new(0, 600, 0, 40)
    IntroSubtitle.Font = Enum.Font.Gotham
    IntroSubtitle.Text = '"He Didn\'t Kill Himself Nga..."'
    IntroSubtitle.TextColor3 = Color3.fromRGB(180, 180, 190)
    IntroSubtitle.TextSize = 18
    IntroSubtitle.TextTransparency = 0
    IntroSubtitle.ZIndex = 2
    
    local IntroCredit = Instance.new("TextLabel")
    IntroCredit.Parent = IntroFrame
    IntroCredit.BackgroundTransparency = 1
    IntroCredit.Position = UDim2.new(0.5, 0, 0.55, 0)
    IntroCredit.AnchorPoint = Vector2.new(0.5, 0.5)
    IntroCredit.Size = UDim2.new(0, 400, 0, 30)
    IntroCredit.Font = Enum.Font.GothamMedium
    IntroCredit.Text = "By I Went Kimbo"
    IntroCredit.TextColor3 = Color3.fromRGB(150, 150, 160)
    IntroCredit.TextSize = 16
    IntroCredit.TextTransparency = 0
    IntroCredit.ZIndex = 2
    
    local IntroProgress = Instance.new("Frame")
    IntroProgress.Parent = IntroFrame
    IntroProgress.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    IntroProgress.BorderSizePixel = 0
    IntroProgress.Position = UDim2.new(0.5, -150, 0.65, 0)
    IntroProgress.AnchorPoint = Vector2.new(0, 0.5)
    IntroProgress.Size = UDim2.new(0, 0, 0, 4)
    IntroProgress.ZIndex = 2
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(0, 2)
    ProgressCorner.Parent = IntroProgress
    
    task.spawn(function()
        while IntroProgress and IntroProgress.Parent do
            IntroProgress.BackgroundColor3 = GetRGBColor()
            wait()
        end
    end)
    
    TweenService:Create(IntroProgress, TweenInfo.new(6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
        Size = UDim2.new(0, 300, 0, 4)
    }):Play()
    
    wait(6.5)
    
    TweenService:Create(IntroFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        BackgroundTransparency = 1
    }):Play()
    
    TweenService:Create(IntroTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(IntroSubtitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(IntroCredit, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(IntroProgress, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    
    wait(0.5)
    IntroGui:Destroy()
end

--[[ KEY SYSTEM ]]--

local function ShowKeySystem()
    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "KeySystemGui"
    KeyGui.Parent = game.CoreGui
    KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    KeyGui.DisplayOrder = 999998
    
    local function GetRGBColor()
        local t = tick() * 2
        local r = math.floor(127 * math.sin(t) + 128)
        local g = math.floor(127 * math.sin(t + 2) + 128)
        local b = math.floor(127 * math.sin(t + 4) + 128)
        return Color3.fromRGB(r, g, b)
    end
    
    local KeyFrame = Instance.new("Frame")
    KeyFrame.Parent = KeyGui
    KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    KeyFrame.BorderSizePixel = 0
    KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    KeyFrame.Size = UDim2.new(0, 400, 0, 300)
    KeyFrame.ZIndex = 1
    
    local KeyCorner = Instance.new("UICorner")
    KeyCorner.CornerRadius = UDim.new(0, 12)
    KeyCorner.Parent = KeyFrame
    
    local KeyStroke = Instance.new("UIStroke")
    KeyStroke.Parent = KeyFrame
    KeyStroke.Thickness = 2
    KeyStroke.Transparency = 0.3
    
    task.spawn(function()
        while KeyStroke and KeyStroke.Parent do
            KeyStroke.Color = GetRGBColor()
            wait()
        end
    end)
    
    local KeyTitle = Instance.new("TextLabel")
    KeyTitle.Parent = KeyFrame
    KeyTitle.BackgroundTransparency = 1
    KeyTitle.Position = UDim2.new(0, 0, 0, 20)
    KeyTitle.Size = UDim2.new(1, 0, 0, 40)
    KeyTitle.Font = Enum.Font.GothamBold
    KeyTitle.Text = "🔐 Key System"
    KeyTitle.TextSize = 24
    KeyTitle.ZIndex = 2
    
    task.spawn(function()
        while KeyTitle and KeyTitle.Parent do
            KeyTitle.TextColor3 = GetRGBColor()
            wait()
        end
    end)
    
    local KeySubtitle = Instance.new("TextLabel")
    KeySubtitle.Parent = KeyFrame
    KeySubtitle.BackgroundTransparency = 1
    KeySubtitle.Position = UDim2.new(0, 0, 0, 65)
    KeySubtitle.Size = UDim2.new(1, 0, 0, 30)
    KeySubtitle.Font = Enum.Font.Gotham
    KeySubtitle.Text = "Enter your key to continue"
    KeySubtitle.TextColor3 = Color3.fromRGB(180, 180, 190)
    KeySubtitle.TextSize = 14
    KeySubtitle.ZIndex = 2
    
    local KeyInput = Instance.new("TextBox")
    KeyInput.Parent = KeyFrame
    KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    KeyInput.BorderSizePixel = 0
    KeyInput.Position = UDim2.new(0, 50, 0, 115)
    KeyInput.Size = UDim2.new(0, 300, 0, 40)
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.PlaceholderText = "Enter Key Here..."
    KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14
    KeyInput.ClearTextOnFocus = false
    KeyInput.ZIndex = 2
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = KeyInput
    
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Parent = KeyFrame
    SubmitButton.BackgroundColor3 = Color3.fromRGB(40, 150, 255)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Position = UDim2.new(0, 50, 0, 170)
    SubmitButton.Size = UDim2.new(0, 300, 0, 40)
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.Text = "Submit Key"
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.TextSize = 14
    SubmitButton.AutoButtonColor = false
    SubmitButton.ZIndex = 2
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = SubmitButton
    
    local GetKeyButton = Instance.new("TextButton")
    GetKeyButton.Parent = KeyFrame
    GetKeyButton.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
    GetKeyButton.BorderSizePixel = 0
    GetKeyButton.Position = UDim2.new(0, 50, 0, 220)
    GetKeyButton.Size = UDim2.new(0, 300, 0, 35)
    GetKeyButton.Font = Enum.Font.GothamMedium
    GetKeyButton.Text = "Get Key (Discord)"
    GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyButton.TextSize = 13
    GetKeyButton.AutoButtonColor = false
    GetKeyButton.ZIndex = 2
    
    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 8)
    GetKeyCorner.Parent = GetKeyButton
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Parent = KeyFrame
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Position = UDim2.new(0, 0, 0, 265)
    StatusLabel.Size = UDim2.new(1, 0, 0, 25)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    StatusLabel.TextSize = 12
    StatusLabel.ZIndex = 2
    
    local validKey = "EPSTEIN2026"
    local keySubmitted = false
    
    SubmitButton.MouseButton1Click:Connect(function()
        if keySubmitted then return end
        
        local enteredKey = KeyInput.Text
        
        if enteredKey == validKey then
            keySubmitted = true
            StatusLabel.Text = "✓ Key Valid! Loading..."
            StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            
            TweenService:Create(KeyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
                BackgroundTransparency = 1
            }):Play()
            
            for _, child in pairs(KeyFrame:GetChildren()) do
                if child:IsA("TextLabel") or child:IsA("TextBox") or child:IsA("TextButton") then
                    TweenService:Create(child, TweenInfo.new(0.5), {
                        TextTransparency = 1,
                        BackgroundTransparency = 1
                    }):Play()
                end
            end
            
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
        TweenService:Create(SubmitButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 160, 255)}):Play()
    end)
    
    SubmitButton.MouseLeave:Connect(function()
        TweenService:Create(SubmitButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 150, 255)}):Play()
    end)
    
    GetKeyButton.MouseEnter:Connect(function()
        TweenService:Create(GetKeyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 190, 110)}):Play()
    end)
    
    GetKeyButton.MouseLeave:Connect(function()
        TweenService:Create(GetKeyButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 180, 100)}):Play()
    end)
    
    while not keySubmitted do
        wait(0.1)
    end
    
    return keySubmitted
end

--[[ GUI CREATION ]]--

local function CreateGUI()
    if game.CoreGui:FindFirstChild("EpsteinsEulogyGUI") then
        game.CoreGui:FindFirstChild("EpsteinsEulogyGUI"):Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "EpsteinsEulogyGUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- RGB Animation (slower, smoother)
    local hue = 0
    local function GetRGBColor()
        hue = hue + 0.0003
        if hue > 1 then hue = 0 end
        return Color3.fromHSV(hue, 0.7, 1)
    end
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 700, 0, 450)
    MainFrame.ZIndex = 1
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Parent = MainFrame
    MainStroke.Thickness = 2
    MainStroke.Transparency = 0.3
    
    task.spawn(function()
        while MainStroke and MainStroke.Parent do
            MainStroke.Color = GetRGBColor()
            wait()
        end
    end)
    
    -- Gradient overlay for depth
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
    }
    Gradient.Rotation = 45
    Gradient.Parent = MainFrame
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.ZIndex = 2
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    local TitleBarBottom = Instance.new("Frame")
    TitleBarBottom.Parent = TitleBar
    TitleBarBottom.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    TitleBarBottom.BorderSizePixel = 0
    TitleBarBottom.Position = UDim2.new(0, 0, 1, -12)
    TitleBarBottom.Size = UDim2.new(1, 0, 0, 12)
    TitleBarBottom.ZIndex = 2
    
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
    
    local Title = Instance.new("TextLabel")
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(0, 300, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "Epstein's Eulogy"
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextSize = 16
    Title.ZIndex = 3
    
    task.spawn(function()
        while Title and Title.Parent do
            Title.TextColor3 = GetRGBColor()
            wait()
        end
    end)
    
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Parent = TitleBar
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0, 155, 0, 0)
    Subtitle.Size = UDim2.new(0, 200, 1, 0)
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "v1 BETA"
    Subtitle.TextColor3 = Color3.fromRGB(150, 150, 160)
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.TextSize = 11
    Subtitle.ZIndex = 3
    
    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = TitleBar
    MinBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
    MinBtn.BorderSizePixel = 0
    MinBtn.Position = UDim2.new(1, -70, 0.5, -10)
    MinBtn.Size = UDim2.new(0, 20, 0, 20)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(20, 20, 28)
    MinBtn.TextSize = 18
    MinBtn.AutoButtonColor = false
    MinBtn.ZIndex = 3
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(1, 0)
    MinCorner.Parent = MinBtn
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = TitleBar
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -10)
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 18
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 3
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(1, 0)
    CloseCorner.Parent = CloseBtn
    
    MinBtn.MouseEnter:Connect(function()
        TweenService:Create(MinBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 210, 70)}):Play()
    end)
    
    MinBtn.MouseLeave:Connect(function()
        TweenService:Create(MinBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 200, 50)}):Play()
    end)
    
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}):Play()
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
    end)
    
    local MinimizeIcon = Instance.new("TextButton")
    MinimizeIcon.Parent = ScreenGui
    MinimizeIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    MinimizeIcon.BorderSizePixel = 0
    MinimizeIcon.Position = UDim2.new(0, 10, 0, 10)
    MinimizeIcon.Size = UDim2.new(0, 50, 0, 50)
    MinimizeIcon.Font = Enum.Font.GothamBold
    MinimizeIcon.Text = "📋"
    MinimizeIcon.TextSize = 24
    MinimizeIcon.Visible = false
    MinimizeIcon.AutoButtonColor = false
    MinimizeIcon.ZIndex = 10
    
    local MinIconCorner = Instance.new("UICorner")
    MinIconCorner.CornerRadius = UDim.new(0, 10)
    MinIconCorner.Parent = MinimizeIcon
    
    local MinIconStroke = Instance.new("UIStroke")
    MinIconStroke.Parent = MinimizeIcon
    MinIconStroke.Thickness = 2
    MinIconStroke.Transparency = 0.3
    
    task.spawn(function()
        while MinIconStroke and MinIconStroke.Parent do
            MinIconStroke.Color = GetRGBColor()
            wait()
        end
    end)
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundTransparency = 1
    TabContainer.Position = UDim2.new(0, 0, 0, 45)
    TabContainer.Size = UDim2.new(1, 0, 0, 45)
    TabContainer.ZIndex = 2
    
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 10, 0, 100)
    ContentContainer.Size = UDim2.new(1, -20, 1, -110)
    ContentContainer.ZIndex = 2
    
    local pages = {}
    
    local function CreateToggle(parent, labelText, position, settingKey)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Parent = parent
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        ToggleFrame.BorderSizePixel = 0
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
        ToggleLabel.Size = UDim2.new(0, 220, 1, 0)
        ToggleLabel.Font = Enum.Font.GothamMedium
        ToggleLabel.Text = labelText
        ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
        ToggleLabel.TextSize = 13
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.ZIndex = 4
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Parent = ToggleFrame
        ToggleButton.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(60, 60, 70)
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Position = UDim2.new(1, -50, 0.5, -10)
        ToggleButton.Size = UDim2.new(0, 40, 0, 20)
        ToggleButton.Text = ""
        ToggleButton.AutoButtonColor = false
        ToggleButton.ZIndex = 4
        
        local ToggleBtnCorner = Instance.new("UICorner")
        ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
        ToggleBtnCorner.Parent = ToggleButton
        
        local ToggleIndicator = Instance.new("Frame")
        ToggleIndicator.Parent = ToggleButton
        ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleIndicator.BorderSizePixel = 0
        ToggleIndicator.Position = Settings[settingKey] and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
        ToggleIndicator.ZIndex = 5
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(1, 0)
        IndicatorCorner.Parent = ToggleIndicator
        
        ToggleButton.MouseButton1Click:Connect(function()
            Settings[settingKey] = not Settings[settingKey]
            
            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(100, 200, 255) or Color3.fromRGB(60, 60, 70)
            }):Play()
            
            TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                Position = Settings[settingKey] and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }):Play()
            
            SaveConfig()
        end)
        
        return ToggleFrame
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
        Button.TextSize = 13
        Button.AutoButtonColor = false
        Button.ZIndex = 3
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 8)
        ButtonCorner.Parent = Button
        
        Button.MouseButton1Click:Connect(callback)
        
        Button.MouseEnter:Connect(function()
            local h, s, v = color:ToHSV()
            local brighterColor = Color3.fromHSV(h, s, math.min(v + 0.1, 1))
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = brighterColor}):Play()
        end)
        
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        end)
        
        return Button
    end
    
    local function CreateSlider(parent, labelText, position, settingKey, minValue, maxValue, increment)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Parent = parent
        SliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        SliderFrame.BorderSizePixel = 0
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
        SliderLabel.Size = UDim2.new(0, 150, 0, 20)
        SliderLabel.Font = Enum.Font.GothamMedium
        SliderLabel.Text = labelText
        SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
        SliderLabel.TextSize = 13
        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        SliderLabel.ZIndex = 4
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Parent = SliderFrame
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Position = UDim2.new(1, -60, 0, 5)
        ValueLabel.Size = UDim2.new(0, 50, 0, 20)
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.Text = tostring(Settings[settingKey])
        ValueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
        ValueLabel.TextSize = 13
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.ZIndex = 4
        
        local SliderBar = Instance.new("Frame")
        SliderBar.Parent = SliderFrame
        SliderBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        SliderBar.BorderSizePixel = 0
        SliderBar.Position = UDim2.new(0, 10, 0, 32)
        SliderBar.Size = UDim2.new(0, 280, 0, 6)
        SliderBar.ZIndex = 4
        
        local BarCorner = Instance.new("UICorner")
        BarCorner.CornerRadius = UDim.new(1, 0)
        BarCorner.Parent = SliderBar
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Parent = SliderBar
        SliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
        SliderFill.BorderSizePixel = 0
        SliderFill.Size = UDim2.new((Settings[settingKey] - minValue) / (maxValue - minValue), 0, 1, 0)
        SliderFill.ZIndex = 5
        
        local FillCorner = Instance.new("UICorner")
        FillCorner.CornerRadius = UDim.new(1, 0)
        FillCorner.Parent = SliderFill
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Parent = SliderBar
        SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SliderButton.BorderSizePixel = 0
        SliderButton.Position = UDim2.new((Settings[settingKey] - minValue) / (maxValue - minValue), -8, 0.5, -8)
        SliderButton.Size = UDim2.new(0, 16, 0, 16)
        SliderButton.Text = ""
        SliderButton.AutoButtonColor = false
        SliderButton.ZIndex = 6
        
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
        
        RunService.RenderStepped:Connect(function()
            if dragging then
                local mousePos = UserInputService:GetMouseLocation().X
                local barPos = SliderBar.AbsolutePosition.X
                local barSize = SliderBar.AbsoluteSize.X
                
                local relativePos = math.clamp((mousePos - barPos) / barSize, 0, 1)
                local value = math.floor((minValue + (maxValue - minValue) * relativePos) / increment) * increment
                
                Settings[settingKey] = value
                ValueLabel.Text = tostring(value)
                
                SliderButton.Position = UDim2.new(relativePos, -8, 0.5, -8)
                SliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
                
                SaveConfig()
            end
        end)
        
        return SliderFrame
    end
    
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
    WelcomeLabel.Text = "Welcome to Epstein's Eulogy"
    WelcomeLabel.TextSize = 24
    WelcomeLabel.ZIndex = 3
    
    task.spawn(function()
        while WelcomeLabel and WelcomeLabel.Parent do
            WelcomeLabel.TextColor3 = GetRGBColor()
            wait()
        end
    end)
    
    local DescLabel = Instance.new("TextLabel")
    DescLabel.Parent = HomePage
    DescLabel.BackgroundTransparency = 1
    DescLabel.Position = UDim2.new(0, 0, 0, 55)
    DescLabel.Size = UDim2.new(1, 0, 0, 30)
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.Text = '"He Didn\'t Kill Himself Nga..."'
    DescLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    DescLabel.TextSize = 16
    DescLabel.ZIndex = 3
    
    local InfoBox = Instance.new("Frame")
    InfoBox.Parent = HomePage
    InfoBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    InfoBox.BorderSizePixel = 0
    InfoBox.Position = UDim2.new(0, 0, 0, 100)
    InfoBox.Size = UDim2.new(1, 0, 0, 150)
    InfoBox.ZIndex = 3
    
    local InfoCorner = Instance.new("UICorner")
    InfoCorner.CornerRadius = UDim.new(0, 10)
    InfoCorner.Parent = InfoBox
    
    local InfoTitle = Instance.new("TextLabel")
    InfoTitle.Parent = InfoBox
    InfoTitle.BackgroundTransparency = 1
    InfoTitle.Position = UDim2.new(0, 15, 0, 10)
    InfoTitle.Size = UDim2.new(1, -30, 0, 25)
    InfoTitle.Font = Enum.Font.GothamBold
    InfoTitle.Text = "🎮 GUI Information"
    InfoTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    InfoTitle.TextSize = 16
    InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
    InfoTitle.ZIndex = 4
    
    local InfoText = Instance.new("TextLabel")
    InfoText.Parent = InfoBox
    InfoText.BackgroundTransparency = 1
    InfoText.Position = UDim2.new(0, 15, 0, 40)
    InfoText.Size = UDim2.new(1, -30, 1, -50)
    InfoText.Font = Enum.Font.Gotham
    InfoText.Text = [[This is a clean slate GUI framework ready for your mods!

• Navigate between tabs using the buttons at the top
• Check the Status page for system information
• Configure settings in the Settings tab
• All features have been removed - ready to build!]]
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
    StatusTitle.Position = UDim2.new(0, 0, 0, 5)
    StatusTitle.Size = UDim2.new(1, 0, 0, 30)
    StatusTitle.Font = Enum.Font.GothamBold
    StatusTitle.Text = "📊 System Status"
    StatusTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
    StatusTitle.TextSize = 18
    StatusTitle.TextXAlignment = Enum.TextXAlignment.Left
    StatusTitle.ZIndex = 3
    
    local function CreateStatusLabel(parent, labelText, position)
        local label = Instance.new("TextLabel")
        label.Parent = parent
        label.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        label.BorderSizePixel = 0
        label.Position = position
        label.Size = UDim2.new(0, 320, 0, 30)
        label.Font = Enum.Font.GothamMedium
        label.Text = labelText
        label.TextColor3 = Color3.fromRGB(200, 200, 210)
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 3
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = label
        
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 10)
        padding.Parent = label
        
        return label
    end
    
    CreateStatusLabel(StatusPage, "📌 Player: " .. LocalPlayer.Name, UDim2.new(0, 0, 0, 45))
    CreateStatusLabel(StatusPage, "🎮 Status: Idle", UDim2.new(0, 0, 0, 85))
    CreateStatusLabel(StatusPage, "⚙️ Version: v1 BETA", UDim2.new(0, 0, 0, 125))
    
    -- SETTINGS PAGE
    local SettingsPage = Instance.new("Frame")
    SettingsPage.Parent = ContentContainer
    SettingsPage.BackgroundTransparency = 1
    SettingsPage.Size = UDim2.new(1, 0, 1, 0)
    SettingsPage.Visible = false
    pages["Settings"] = SettingsPage
    
    -- Anti-AFK Toggle
    CreateToggle(SettingsPage, "Anti-AFK", UDim2.new(0, 10, 0, 5), "AntiAFK")
    
    -- Server Buttons
    CreateButton(SettingsPage, "🔄 Rejoin", UDim2.new(0, 10, 0, 50), UDim2.new(0, 145, 0, 35), Color3.fromRGB(60, 120, 200), function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
    
    CreateButton(SettingsPage, "🎲 Random Server", UDim2.new(0, 165, 0, 50), UDim2.new(0, 145, 0, 35), Color3.fromRGB(100, 150, 50), function()
        local TeleportService = game:GetService("TeleportService")
        local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for _, server in pairs(servers.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                break
            end
        end
    end)
    
    CreateButton(SettingsPage, "👥 Small Server", UDim2.new(0, 10, 0, 95), UDim2.new(0, 145, 0, 35), Color3.fromRGB(150, 100, 200), function()
        local TeleportService = game:GetService("TeleportService")
        local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        local smallest = nil
        local smallestCount = 9999
        for _, server in pairs(servers.data) do
            if server.id ~= game.JobId and server.playing < smallestCount and server.playing < server.maxPlayers then
                smallest = server
                smallestCount = server.playing
            end
        end
        if smallest then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, smallest.id, LocalPlayer)
        end
    end)
    
    -- Config Buttons
    CreateButton(SettingsPage, "💾 Save Config", UDim2.new(0, 165, 0, 95), UDim2.new(0, 145, 0, 35), Color3.fromRGB(39, 174, 96), function()
        SaveConfig()
        Notify("Config", "Settings saved!")
    end)
    
    CreateButton(SettingsPage, "📁 Load Config", UDim2.new(0, 10, 0, 140), UDim2.new(0, 145, 0, 35), Color3.fromRGB(52, 152, 219), function()
        if LoadConfig() then
            Notify("Config", "Settings loaded!")
        else
            Notify("Config", "No saved config found")
        end
    end)
    
    -- Create tabs
    local tabs = {"Home", "Status", "Settings"}
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
        
        -- Active indicator line
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
        
        -- RGB animation for active indicator
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
        
        -- Hover effect
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

print("[EULOGY] Loading Epstein's Eulogy v1 BETA...")

ShowIntro()

wait(7) -- Wait for intro to finish

-- Show key system
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
