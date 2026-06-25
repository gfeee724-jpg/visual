local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Safe CoreGui integration for executor environment
local targetGui = gethui and gethui() or CoreGui

local VisualClient = {}
VisualClient.Loaded = false

function VisualClient:Load()
    -- Create ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = HttpService:GenerateGUID(false)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = targetGui
    
    -- Main background frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 300, 0, 100)
    MainFrame.BackgroundTransparency = 1 -- Start transparent
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(80, 120, 255)
    UIStroke.Thickness = 1.5
    UIStroke.Transparency = 1
    UIStroke.Parent = MainFrame
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 0, 0, 15)
    Title.Size = UDim2.new(1, 0, 0, 24)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "VisualClient"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 20
    Title.TextTransparency = 1
    
    -- Status Text
    local Status = Instance.new("TextLabel")
    Status.Parent = MainFrame
    Status.BackgroundTransparency = 1
    Status.Position = UDim2.new(0, 0, 0, 45)
    Status.Size = UDim2.new(1, 0, 0, 16)
    Status.Font = Enum.Font.GothamMedium
    Status.Text = "Preparing to load..."
    Status.TextColor3 = Color3.fromRGB(180, 180, 180)
    Status.TextSize = 13
    Status.TextTransparency = 1
    
    -- Loading Bar Background
    local BarBg = Instance.new("Frame")
    BarBg.Parent = MainFrame
    BarBg.AnchorPoint = Vector2.new(0.5, 0)
    BarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    BarBg.Position = UDim2.new(0.5, 0, 1, -20)
    BarBg.Size = UDim2.new(0, 260, 0, 4)
    BarBg.BackgroundTransparency = 1
    
    local BarBgCorner = Instance.new("UICorner")
    BarBgCorner.CornerRadius = UDim.new(1, 0)
    BarBgCorner.Parent = BarBg
    
    -- Loading Bar Fill
    local BarFill = Instance.new("Frame")
    BarFill.Parent = BarBg
    BarFill.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundTransparency = 1
    
    local BarFillCorner = Instance.new("UICorner")
    BarFillCorner.CornerRadius = UDim.new(1, 0)
    BarFillCorner.Parent = BarFill
    
    -- Animations Setup
    local fadeInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    -- 1. Fade In
    TweenService:Create(MainFrame, fadeInfo, {BackgroundTransparency = 0}):Play()
    TweenService:Create(UIStroke, fadeInfo, {Transparency = 0.5}):Play()
    TweenService:Create(Title, fadeInfo, {TextTransparency = 0}):Play()
    TweenService:Create(Status, fadeInfo, {TextTransparency = 0}):Play()
    TweenService:Create(BarBg, fadeInfo, {BackgroundTransparency = 0}):Play()
    TweenService:Create(BarFill, fadeInfo, {BackgroundTransparency = 0}):Play()
    
    task.wait(0.6)
    
    -- Progress function
    local function updateProgress(text, percent, duration)
        Status.Text = text
        local tw = TweenService:Create(BarFill, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(percent, 0, 1, 0)})
        tw:Play()
        tw.Completed:Wait()
        task.wait(0.05)
    end
    
    -- 2. Mock / Real Loading Sequence
    updateProgress("Loading utilities...", 0.3, 0.4)
    -- local Theme = loadstring('return ' .. readfile('VisualClient/Utils/Theme.lua'))() 
    
    updateProgress("Loading modules...", 0.7, 0.5)
    -- Load ESP, Chams, TargetHUD...
    
    updateProgress("Starting Main GUI...", 1, 0.4)
    
    task.wait(0.3)
    Status.Text = "Done!"
    task.wait(0.3)
    
    -- 3. Fade Out
    TweenService:Create(MainFrame, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(UIStroke, fadeInfo, {Transparency = 1}):Play()
    TweenService:Create(Title, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(Status, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(BarBg, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarFill, fadeInfo, {BackgroundTransparency = 1}):Play()
    
    task.wait(0.6)
    ScreenGui:Destroy()
    
    self.Loaded = true
    
    -- Finally call Main.lua
    print("[VisualClient] Successfully loaded!")
end

VisualClient:Load()
return VisualClient
