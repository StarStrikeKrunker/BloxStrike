--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║                    ORBITAL FARM GUI                       ║
    ║              Universal BloxStrike Farm System             ║
    ║                   Version 1.0.0                          ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local Orbital = {}
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Configuration
local Config = {
    KeySystem = {
        Enabled = true,
        CorrectKey = "ORBITAL2024",
        KeyLink = "https://example.com/getkey" -- Replace with your key link
    },
    Colors = {
        Primary = Color3.fromRGB(45, 45, 60),
        Secondary = Color3.fromRGB(35, 35, 50),
        Accent = Color3.fromRGB(100, 100, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(50, 255, 100),
        Error = Color3.fromRGB(255, 50, 50)
    },
    Farm = {
        AutoFarm = false,
        AutoCollect = false,
        FarmSpeed = 1,
        TargetMobs = {},
        SafeMode = true
    }
}

-- RGB Animation
local function createRGBAnimation(object, property)
    spawn(function()
        local hue = 0
        while object and object.Parent do
            hue = (hue + 1) % 360
            local color = Color3.fromHSV(hue / 360, 1, 1)
            if object and object.Parent then
                object[property] = color
            end
            wait(0.03)
        end
    end)
end

-- Create GUI
local function createMainGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OrbitalGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    return ScreenGui
end

-- Intro Animation
local function createIntro(parent)
    local IntroFrame = Instance.new("Frame")
    IntroFrame.Name = "IntroFrame"
    IntroFrame.Size = UDim2.new(1, 0, 1, 0)
    IntroFrame.Position = UDim2.new(0, 0, 0, 0)
    IntroFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    IntroFrame.BorderSizePixel = 0
    IntroFrame.ZIndex = 1000
    IntroFrame.Parent = parent
    
    -- Orbital Logo
    local LogoFrame = Instance.new("Frame")
    LogoFrame.Name = "LogoFrame"
    LogoFrame.Size = UDim2.new(0, 300, 0, 300)
    LogoFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
    LogoFrame.BackgroundTransparency = 1
    LogoFrame.Parent = IntroFrame
    
    -- Outer Circle (RGB Border)
    local OuterCircle = Instance.new("ImageLabel")
    OuterCircle.Name = "OuterCircle"
    OuterCircle.Size = UDim2.new(1, 0, 1, 0)
    OuterCircle.Position = UDim2.new(0, 0, 0, 0)
    OuterCircle.BackgroundTransparency = 1
    OuterCircle.Image = "rbxassetid://3570695787"
    OuterCircle.ImageColor3 = Color3.fromRGB(255, 255, 255)
    OuterCircle.Parent = LogoFrame
    
    createRGBAnimation(OuterCircle, "ImageColor3")
    
    -- Inner Circle
    local InnerCircle = Instance.new("ImageLabel")
    InnerCircle.Name = "InnerCircle"
    InnerCircle.Size = UDim2.new(0.7, 0, 0.7, 0)
    InnerCircle.Position = UDim2.new(0.15, 0, 0.15, 0)
    InnerCircle.BackgroundTransparency = 1
    InnerCircle.Image = "rbxassetid://3570695787"
    InnerCircle.ImageColor3 = Color3.fromRGB(100, 100, 255)
    InnerCircle.Parent = LogoFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 400, 0, 80)
    Title.Position = UDim2.new(0.5, -200, 0.7, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "ORBITAL"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 48
    Title.TextTransparency = 1
    Title.Parent = IntroFrame
    
    createRGBAnimation(Title, "TextColor3")
    
    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(0, 400, 0, 40)
    Subtitle.Position = UDim2.new(0.5, -200, 0.75, 50)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Text = "Universal Farm System"
    Subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    Subtitle.TextSize = 20
    Subtitle.TextTransparency = 1
    Subtitle.Parent = IntroFrame
    
    -- Loading Bar Background
    local LoadingBG = Instance.new("Frame")
    LoadingBG.Name = "LoadingBG"
    LoadingBG.Size = UDim2.new(0, 300, 0, 4)
    LoadingBG.Position = UDim2.new(0.5, -150, 0.85, 0)
    LoadingBG.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    LoadingBG.BorderSizePixel = 0
    LoadingBG.BackgroundTransparency = 1
    LoadingBG.Parent = IntroFrame
    
    local LoadingBar = Instance.new("Frame")
    LoadingBar.Name = "LoadingBar"
    LoadingBar.Size = UDim2.new(0, 0, 1, 0)
    LoadingBar.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    LoadingBar.BorderSizePixel = 0
    LoadingBar.Parent = LoadingBG
    
    createRGBAnimation(LoadingBar, "BackgroundColor3")
    
    -- Animate Intro
    local fadeIn = TweenService:Create(Title, TweenInfo.new(0.8), {TextTransparency = 0})
    local fadeInSub = TweenService:Create(Subtitle, TweenInfo.new(0.8), {TextTransparency = 0})
    local fadeInLoad = TweenService:Create(LoadingBG, TweenInfo.new(0.5), {BackgroundTransparency = 0})
    local loadBar = TweenService:Create(LoadingBar, TweenInfo.new(2), {Size = UDim2.new(1, 0, 1, 0)})
    
    wait(0.5)
    fadeIn:Play()
    wait(0.2)
    fadeInSub:Play()
    wait(0.3)
    fadeInLoad:Play()
    wait(0.3)
    loadBar:Play()
    
    -- Rotation Animation
    spawn(function()
        while IntroFrame.Parent do
            OuterCircle.Rotation = OuterCircle.Rotation + 1
            InnerCircle.Rotation = InnerCircle.Rotation - 1.5
            wait(0.03)
        end
    end)
    
    wait(2.5)
    
    local fadeOut = TweenService:Create(IntroFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
    fadeOut:Play()
    wait(0.5)
    IntroFrame:Destroy()
    
    return true
end

-- Key System
local function createKeySystem(parent)
    local KeyFrame = Instance.new("Frame")
    KeyFrame.Name = "KeyFrame"
    KeyFrame.Size = UDim2.new(0, 400, 0, 300)
    KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    KeyFrame.BackgroundColor3 = Config.Colors.Primary
    KeyFrame.BorderSizePixel = 0
    KeyFrame.ZIndex = 100
    KeyFrame.Parent = parent
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = KeyFrame
    
    -- RGB Border
    local Border = Instance.new("UIStroke")
    Border.Name = "RGBBorder"
    Border.Thickness = 2
    Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Border.Parent = KeyFrame
    
    createRGBAnimation(Border, "Color")
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🔐 KEY SYSTEM"
    Title.TextColor3 = Config.Colors.Text
    Title.TextSize = 24
    Title.Parent = KeyFrame
    
    -- Key Input
    local KeyInput = Instance.new("TextBox")
    KeyInput.Name = "KeyInput"
    KeyInput.Size = UDim2.new(0.85, 0, 0, 45)
    KeyInput.Position = UDim2.new(0.075, 0, 0.3, 0)
    KeyInput.BackgroundColor3 = Config.Colors.Secondary
    KeyInput.BorderSizePixel = 0
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.PlaceholderText = "Enter Key..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Config.Colors.Text
    KeyInput.TextSize = 16
    KeyInput.Parent = KeyFrame
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 8)
    InputCorner.Parent = KeyInput
    
    -- Get Key Button
    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Name = "GetKeyBtn"
    GetKeyBtn.Size = UDim2.new(0.85, 0, 0, 40)
    GetKeyBtn.Position = UDim2.new(0.075, 0, 0.55, 0)
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
    GetKeyBtn.BorderSizePixel = 0
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.Text = "📋 Get Key"
    GetKeyBtn.TextColor3 = Config.Colors.Text
    GetKeyBtn.TextSize = 16
    GetKeyBtn.Parent = KeyFrame
    
    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 8)
    GetKeyCorner.Parent = GetKeyBtn
    
    -- Submit Button
    local SubmitBtn = Instance.new("TextButton")
    SubmitBtn.Name = "SubmitBtn"
    SubmitBtn.Size = UDim2.new(0.85, 0, 0, 45)
    SubmitBtn.Position = UDim2.new(0.075, 0, 0.75, 0)
    SubmitBtn.BackgroundColor3 = Config.Colors.Accent
    SubmitBtn.BorderSizePixel = 0
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.Text = "✓ Submit Key"
    SubmitBtn.TextColor3 = Config.Colors.Text
    SubmitBtn.TextSize = 18
    SubmitBtn.Parent = KeyFrame
    
    local SubmitCorner = Instance.new("UICorner")
    SubmitCorner.CornerRadius = UDim.new(0, 8)
    SubmitCorner.Parent = SubmitBtn
    
    local SubmitBorder = Instance.new("UIStroke")
    SubmitBorder.Thickness = 2
    SubmitBorder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    SubmitBorder.Parent = SubmitBtn
    
    createRGBAnimation(SubmitBorder, "Color")
    
    -- Event Handlers
    GetKeyBtn.MouseButton1Click:Connect(function()
        setclipboard(Config.KeySystem.KeyLink)
        GetKeyBtn.Text = "✓ Link Copied!"
        wait(2)
        GetKeyBtn.Text = "📋 Get Key"
    end)
    
    SubmitBtn.MouseButton1Click:Connect(function()
        if KeyInput.Text == Config.KeySystem.CorrectKey then
            SubmitBtn.Text = "✓ Correct Key!"
            SubmitBtn.BackgroundColor3 = Config.Colors.Success
            wait(0.5)
            KeyFrame:Destroy()
            return true
        else
            SubmitBtn.Text = "✗ Invalid Key"
            SubmitBtn.BackgroundColor3 = Config.Colors.Error
            wait(1)
            SubmitBtn.Text = "✓ Submit Key"
            SubmitBtn.BackgroundColor3 = Config.Colors.Accent
        end
    end)
    
    return KeyFrame
end

-- Main GUI
local function createMainInterface(parent)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
    MainFrame.BackgroundColor3 = Config.Colors.Primary
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = parent
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    -- RGB Border
    local Border = Instance.new("UIStroke")
    Border.Name = "RGBBorder"
    Border.Thickness = 3
    Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Border.Parent = MainFrame
    
    createRGBAnimation(Border, "Color")
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BackgroundColor3 = Config.Colors.Secondary
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    HeaderCorner.Parent = Header
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 300, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "⚡ ORBITAL FARM"
    Title.TextColor3 = Config.Colors.Text
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header
    
    createRGBAnimation(Title, "TextColor3")
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -50, 0, 10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Config.Colors.Text
    CloseBtn.TextSize = 20
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = Header
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        parent:Destroy()
    end)
    
    -- Tabs Container
    local TabsFrame = Instance.new("Frame")
    TabsFrame.Size = UDim2.new(1, -40, 0, 50)
    TabsFrame.Position = UDim2.new(0, 20, 0, 75)
    TabsFrame.BackgroundTransparency = 1
    TabsFrame.Parent = MainFrame
    
    -- Content Frame
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -40, 1, -150)
    ContentFrame.Position = UDim2.new(0, 20, 0, 135)
    ContentFrame.BackgroundColor3 = Config.Colors.Secondary
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Parent = MainFrame
    
    local ContentCorner = Instance.new("UICorner")
    ContentCorner.CornerRadius = UDim.new(0, 10)
    ContentCorner.Parent = ContentFrame
    
    -- Create Tabs
    local function createTab(name, position)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 120, 1, 0)
        TabBtn.Position = UDim2.new(0, position * 130, 0, 0)
        TabBtn.BackgroundColor3 = Config.Colors.Secondary
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.Text = name
        TabBtn.TextColor3 = Config.Colors.Text
        TabBtn.TextSize = 14
        TabBtn.BorderSizePixel = 0
        TabBtn.Parent = TabsFrame
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 8)
        TabCorner.Parent = TabBtn
        
        return TabBtn
    end
    
    local FarmTab = createTab("🎯 Farm", 0)
    local SettingsTab = createTab("⚙️ Settings", 1)
    local MiscTab = createTab("📦 Misc", 2)
    local CreditsTab = createTab("👤 Credits", 3)
    
    -- Farm Content
    local function createFarmContent()
        local FarmContent = Instance.new("ScrollingFrame")
        FarmContent.Size = UDim2.new(1, -20, 1, -20)
        FarmContent.Position = UDim2.new(0, 10, 0, 10)
        FarmContent.BackgroundTransparency = 1
        FarmContent.BorderSizePixel = 0
        FarmContent.ScrollBarThickness = 6
        FarmContent.CanvasSize = UDim2.new(0, 0, 0, 500)
        FarmContent.Parent = ContentFrame
        
        local function createToggle(text, yPos, callback)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
            ToggleFrame.Position = UDim2.new(0, 0, 0, yPos)
            ToggleFrame.BackgroundColor3 = Config.Colors.Primary
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = FarmContent
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 8)
            ToggleCorner.Parent = ToggleFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.7, 0, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.Gotham
            Label.Text = text
            Label.TextColor3 = Config.Colors.Text
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame
            
            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size = UDim2.new(0, 50, 0, 25)
            ToggleBtn.Position = UDim2.new(1, -60, 0.5, -12.5)
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            ToggleBtn.Text = ""
            ToggleBtn.BorderSizePixel = 0
            ToggleBtn.Parent = ToggleFrame
            
            local ToggleBtnCorner = Instance.new("UICorner")
            ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
            ToggleBtnCorner.Parent = ToggleBtn
            
            local ToggleIndicator = Instance.new("Frame")
            ToggleIndicator.Size = UDim2.new(0, 19, 0, 19)
            ToggleIndicator.Position = UDim2.new(0, 3, 0.5, -9.5)
            ToggleIndicator.BackgroundColor3 = Config.Colors.Text
            ToggleIndicator.BorderSizePixel = 0
            ToggleIndicator.Parent = ToggleBtn
            
            local IndicatorCorner = Instance.new("UICorner")
            IndicatorCorner.CornerRadius = UDim.new(1, 0)
            IndicatorCorner.Parent = ToggleIndicator
            
            local enabled = false
            
            ToggleBtn.MouseButton1Click:Connect(function()
                enabled = not enabled
                
                if enabled then
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Config.Colors.Success}):Play()
                    TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -22, 0.5, -9.5)}):Play()
                else
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
                    TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -9.5)}):Play()
                end
                
                if callback then
                    callback(enabled)
                end
            end)
            
            return ToggleFrame
        end
        
        createToggle("⚡ Auto Farm", 10, function(enabled)
            Config.Farm.AutoFarm = enabled
            print("Auto Farm:", enabled)
        end)
        
        createToggle("💎 Auto Collect Rewards", 65, function(enabled)
            Config.Farm.AutoCollect = enabled
            print("Auto Collect:", enabled)
        end)
        
        createToggle("🛡️ Safe Mode (Anti-Kick)", 120, function(enabled)
            Config.Farm.SafeMode = enabled
            print("Safe Mode:", enabled)
        end)
        
        createToggle("🎯 Auto Select Best Target", 175, function(enabled)
            print("Auto Target:", enabled)
        end)
        
        -- Status Label
        local StatusLabel = Instance.new("TextLabel")
        StatusLabel.Size = UDim2.new(1, 0, 0, 60)
        StatusLabel.Position = UDim2.new(0, 0, 0, 240)
        StatusLabel.BackgroundColor3 = Config.Colors.Primary
        StatusLabel.BorderSizePixel = 0
        StatusLabel.Font = Enum.Font.GothamBold
        StatusLabel.Text = "✓ Ready to Farm"
        StatusLabel.TextColor3 = Config.Colors.Success
        StatusLabel.TextSize = 16
        StatusLabel.Parent = FarmContent
        
        local StatusCorner = Instance.new("UICorner")
        StatusCorner.CornerRadius = UDim.new(0, 8)
        StatusCorner.Parent = StatusLabel
        
        createRGBAnimation(StatusLabel, "TextColor3")
    end
    
    createFarmContent()
    
    return MainFrame
end

-- Initialize
local function Initialize()
    local ScreenGui = createMainGUI()
    ScreenGui.Parent = PlayerGui
    
    -- Show Intro
    createIntro(ScreenGui)
    wait(3)
    
    -- Show Key System if enabled
    if Config.KeySystem.Enabled then
        local keyFrame = createKeySystem(ScreenGui)
        repeat wait() until not keyFrame.Parent
    end
    
    -- Show Main Interface
    createMainInterface(ScreenGui)
    
    print("✓ Orbital Farm GUI Loaded Successfully!")
end

-- Execute
Initialize()

return Orbital
